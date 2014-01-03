window.adHocAnalysis = {
    queryPromises: {},
    queryResults: {},

    fetchData: function($http, target, type, afterSuccess) {
        var promise = $http.get(emr.fragmentActionLink('reportingui', 'definitionLibrary', 'getDefinitions', { type: type })).
            success(function(data, status, headers, config) {
                _.each(data, function(item) {
                    item.label = item.name + ' (' + item.description + ')';
                });
                target.queryResults[type] = data;
                if (afterSuccess) {
                    afterSuccess.call();
                }
            });
        target.queryPromises[type] = promise;
    }
}

var app = angular.module('adHocAnalysis', ['ui.bootstrap']).

    filter('translate', function() {
        return function(input, prefix) {
            if (input && input.uuid) {
                input = input.uuid;
            }
            var code = prefix ? prefix + input : input;
            return emr.message(code, input);
        }
    }).

    directive('definitionsearch', function($compile) {
        // expect { type: ..., key: ..., name: ..., description: ..., parameters: [ ... ] }

        return function(scope, element, attrs) {
            var allowedParameters = _.pluck(scope.parameters, 'name');
            var onSelectAction = scope[attrs['action']];
            element.autocomplete({
                source: [ 'Loading...' ],
                select: function(event, ui) {
                    scope.$apply(function() {
                        onSelectAction(ui.item);
                    });
                    element.val('');
                    return false;
                },
                response: function(event, ui) {
                    var i = ui.content.length - 1;
                    while (i >= 0) {
                        var paramNames = _.pluck(ui.content[i].parameters, 'name');
                        var notAllowed = _.without(paramNames, allowedParameters);
                        if (notAllowed.length > 0) {
                            ui.content.splice(i, 1);
                        }
                        --i;
                    }
                },
                change: function(event, ui) {
                    element.val('');
                    return false;
                }
            });
            var definitionType = attrs['definitionType'];
            window.adHocAnalysis.queryPromises[definitionType].success(function() {
                element.autocomplete( "option", "source", window.adHocAnalysis.queryResults[definitionType] );
            });
        };
    }).

    controller('AdHocAnalysisController', ['$scope', '$http', '$timeout', function($scope, $http, $timeout) {

        // ----- private helper functions ----------

        function swap(array, idx1, idx2) {
            if (idx1 < 0 || idx2 < 0 || idx1 >= array.length || idx2 >= array.length) {
                return;
            }
            var temp = array[idx1];
            array[idx1] = array[idx2];
            array[idx2] = temp;
        }

        function filterAvailable(allDefinitions, currentDefinitions) {
            return _.filter(allDefinitions, function(candidate) {
                // skip items whose parameters are incompatible
                if (!$scope.isAllowed(candidate)) {
                    return false;
                }
                // skip anything we already have selected
                // (when we start supporting parameterized things, this needs to change)
                return ! _.findWhere(currentDefinitions, { key: candidate.key });
            });
        }

        function setDirty() {
            $scope.dirty = true;
        }

        // ----- Model ----------

        $scope.dataExport = window.adHocDataExport; // initialized in the gsp on page load

        var initialSetup = $scope.dataExport.initialSetup;
        delete $scope.dataExport.initialSetup;

        $scope.dirty = !window.adHocDataExport.uuid;

        $scope.dataExport.parameters = [];

        $scope.dataExport.rowFilters = [];

        $scope.dataExport.columns = [];

        if (initialSetup) {
            $scope.dataExport.uuid = initialSetup.uuid;
            $scope.dataExport.name = initialSetup.name;
            $scope.dataExport.description = initialSetup.description;
            $scope.dataExport.parameters = initialSetup.parameters;
            _.each($scope.dataExport.parameters, function(item) {
                if (item.type == "java.util.Date") {
                    item.value = moment().startOf('day').toDate();
                }
            });
        }
        else {
            $scope.dataExport.parameters = [
                {
                    name: "startDate",
                    label: "reportingui.adHocReport.timeframe.startDateLabel",
                    type: "java.util.Date",
                    collectionType: null,
                    value: moment().startOf('day').toDate()
                },
                {
                    name: "endDate",
                    label: "reportingui.adHocReport.timeframe.endDateLabel",
                    type: "java.util.Date",
                    collectionType: null,
                    value: moment().startOf('day').toDate()
                }
            ];
        }

        $scope.initialRowSetup = function() {
            if (initialSetup) {
                _.each(initialSetup.rowFilters, function(item) {
                    console.log(item);
                    var rowFilter = _.findWhere(window.adHocAnalysis.queryResults['org.openmrs.module.reporting.cohort.definition.CohortDefinition'], { key: item.key });
                    if (rowFilter) {
                        $scope.addRow(rowFilter);
                        $scope.dirty = false;
                    } else {
                        console.log("Could not find row: " + item.key);
                    }
                });
            }
        }

        $scope.initialColumnSetup = function() {
            if (initialSetup) {
                _.each(initialSetup.columns, function(item) {
                    var column = _.findWhere(window.adHocAnalysis.queryResults['org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition'], { key: item.key });
                    if (column) {
                        $scope.addColumn(column);
                        $scope.dirty = false;
                    } else {
                        console.log("Could not find column: " + item.key);
                    }
                });
            }
        }

        window.adHocAnalysis.fetchData($http, window.adHocAnalysis, 'org.openmrs.module.reporting.cohort.definition.CohortDefinition', $scope.initialRowSetup);
        window.adHocAnalysis.fetchData($http, window.adHocAnalysis, 'org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition', $scope.initialColumnSetup);

        $scope.dataExport.valid = function() {
            return $scope.dataExport.name && $scope.dataExport.rowFilters.length > 0 && $scope.dataExport.columns.length > 0;
        }

        $scope.addRow = function(definition) {
            if(jq.inArray(definition, $scope.dataExport.rowFilters) < 0) {
                $scope.dataExport.rowFilters.push(definition);
                setDirty();
            }
        }

        $scope.removeRow = function(idx) {
            $scope.dataExport.rowFilters.splice(idx, 1);
            setDirty();
        }

        $scope.addColumn = function(definition) {
            if(jq.inArray(definition, $scope.columns) < 0) {
                $scope.dataExport.columns.push(definition);
                setDirty();
            }
        }

        $scope.removeColumn = function(idx) {
            $scope.dataExport.columns.splice(idx, 1);
            setDirty();
        }

        $scope.moveColumnUp = function(idx) {
            swap($scope.dataExport.columns, idx - 1, idx);
            setDirty();
        }

        $scope.moveColumnDown = function(idx) {
            swap($scope.dataExport.columns, idx, idx + 1);
            setDirty();
        }


        // ----- View and ViewModel ----------

        $scope.currentView = 'parameters';

        $scope.maxDay = moment().startOf('day').toDate();

        $scope.results = null;

        $scope.focusFirstElement = function() {
            $timeout(function() {
                $('#' + $scope.currentView + ' .focus-first').focus();
            });
        }

        $scope.$watch('currentView', $scope.focusFirstElement);

        $scope.openStartDatePicker = function() {
            $timeout(function() {
                $scope.isStartDatePickerOpen = true;
            });
        };

        $scope.openEndDatePicker = function() {
            $timeout(function() {
                $scope.isEndDatePickerOpen = true;
            });
        };

        // TODO remove this
        $scope.getFormattedStartDate = function() {
            if($scope.dataExport.parameters[0].value == null) { return; }
            return moment($scope.dataExport.parameters[0].value).format("DD MMM YYYY");
        }

        // TODO remove this
        $scope.getFormattedEndDate = function() {
            if($scope.dataExport.parameters[1].value == null) { return; }
            return moment($scope.dataExport.parameters[1].value).format("DD MMM YYYY");
        }

        $scope.availableSearches = function() {
            return filterAvailable(window.adHocAnalysis.queryResults['org.openmrs.module.reporting.cohort.definition.CohortDefinition'], $scope.rowFilters);
            var originalCriterias = window.adHocAnalysis.queryResults['org.openmrs.module.reporting.cohort.definition.CohortDefinition'];
            var returnCriterias = originalCriterias && originalCriterias.slice(0);

            for(indexOriginal in originalCriterias) {
                for(indexSelected in $scope.rowFilters) {
                    if(originalCriterias[indexOriginal].key == $scope.rowFilters[indexSelected].key) {
                        var index = returnCriterias.indexOf($scope.rowFilters[indexSelected]);
                        returnCriterias.splice(index, 1);
                    }
                }
            }

            return returnCriterias;
        }

        $scope.getColumns = function() {
            var originalColumns = window.adHocAnalysis.queryResults['org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition'];
            var returnColumns = originalColumns && originalColumns.slice(0);

            for(indexOriginal in originalColumns) {
                for(indexSelected in $scope.columns) {
                    if(originalColumns[indexOriginal].key == $scope.columns[indexSelected].key) {
                        var index = returnColumns.indexOf($scope.columns[indexSelected]);
                        returnColumns.splice(index, 1);
                    }
                }
            }

            return returnColumns;
        }

        $scope.isAllowed = function(definition) {
            var allowedParameters = _.pluck($scope.dataExport.parameters, 'name');
            var paramNames = _.pluck(definition.parameters, 'name');
            var notAllowed = _.without(paramNames, allowedParameters);
            return notAllowed.length == 0;
        }

        $scope.next = function() {
            if($scope.currentView == 'parameters') {
                $scope.currentView = 'searches';
            }

            else if($scope.currentView == 'searches') {
                $scope.currentView = 'columns';
            }

            else if($scope.currentView == 'columns') {
                $scope.currentView = 'preview';
                $scope.preview();
            }
        }

        $scope.back = function() {
            if($scope.currentView == 'searches') {
                $scope.currentView = 'parameters';
            }

            else if($scope.currentView == 'columns') {
                $scope.currentView = 'searches';
            }

            else if($scope.currentView == 'preview') {
                $scope.currentView = 'columns';
            }
        }

        $scope.preview = function() {
            $scope.results = { loading: true };

            var parameterValues = {};
            _.each($scope.dataExport.parameters, function(item) {
                parameterValues[item.name] = item.value;
            });

            $http.get(emr.fragmentActionLink('reportingui', 'adHocAnalysis', 'preview',
                    {
                        rowQueries: angular.toJson($scope.dataExport.rowFilters),
                        columns: angular.toJson($scope.dataExport.columns),
                        parameterValues: angular.toJson(parameterValues)
                    })).
                success(function(data, status, headers, config) {
                    $scope.results = data;
                });
        }

        $scope.canSave = function() {
            return $scope.dataExport.valid();
        }

        $scope.saveDataExport = function() {
            $scope.dirty = { saving: true };
            $http.post(emr.fragmentActionLink('reportingui', 'adHocAnalysis', 'saveDataExport',
                    {
                        dataSet: angular.toJson($scope.dataExport)
                    })).
                success(function(data, status, headers, config) {
                    $scope.dataExport.uuid = data.uuid;
                    $scope.dataExport.name = data.name;
                    $scope.dataExport.description = data.description;
                    $scope.dirty = false;
                });
        }

        $scope.canRun = function() {
            return $scope.dataExport.uuid && !$scope.dirty;
        }

        $scope.runDataExport = function() {
            var data = {
                reportDefinition: $scope.dataExport.uuid
            };
            _.each($scope.parameters, function(item) {
                data["parameterValues[" + item.name + "]"] = item.value;
            });
            location.href = emr.pageLink('reportingui', 'adHocHome', data);

        }
    }]);

