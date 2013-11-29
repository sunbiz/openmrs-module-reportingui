window.adHocAnalysis = {
    queryPromises: {},
    queryResults: {},

    fetchData: function($http, target, type) {
        var promise = $http.get(emr.fragmentActionLink('reportingui', 'definitionLibrary', 'getDefinitions', { type: type })).
            success(function(data, status, headers, config) {
                _.each(data, function(item) {
                    item.label = item.name + ' (' + item.description + ')';
                });
                target.queryResults[type] = data;
            });
        target.queryPromises[type] = promise;
    }
}

var app = angular.module('adHocAnalysis', ['ui.bootstrap']).

    run(function($http) {
        window.adHocAnalysis.fetchData($http, window.adHocAnalysis, 'org.openmrs.module.reporting.cohort.definition.CohortDefinition');
        window.adHocAnalysis.fetchData($http, window.adHocAnalysis, 'org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition');
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

    controller('AdHocAnalysisController', ['$scope', '$http', function($scope, $http) {

        $scope.parameters = [
            {
                "name": "startDate",
                "type": "java.util.Date",
                "collectionType": null
            },
            {
                "name": "endDate",
                "type": "java.util.Date",
                "collectionType": null
            }
        ];

        $scope.currentView = 'timeframe';

        $scope.rowQueries = [];

        $scope.columns = [];

        $scope.results = null;

        $scope.maxDay = moment().startOf('day').toDate();

        $scope.openStartDatePicker = function() {
            $scope.isStartDatePickerOpen = true;
        };

        $scope.openEndDatePicker = function() {
            $scope.isEndDatePickerOpen = true;
        };

        var swap = function(array, idx1, idx2) {
            if (idx1 < 0 || idx2 < 0 || idx1 >= array.length || idx2 >= array.length) {
                return;
            }
            var temp = array[idx1];
            array[idx1] = array[idx2];
            array[idx2] = temp;
        }

        $scope.getFormattedStartDate = function() {
            if($scope.parameters[0].value == null) { return; }
            return moment($scope.parameters[0].value).format("DD MMM YYYY");
        }

        $scope.getFormattedEndDate = function() {
            if($scope.parameters[1].value == null) { return; }
            return moment($scope.parameters[1].value).format("DD MMM YYYY");
        }

        $scope.getDefinitions = function() {
            var originalCriterias = window.adHocAnalysis.queryResults['org.openmrs.module.reporting.cohort.definition.CohortDefinition'];
            var returnCriterias = originalCriterias && originalCriterias.slice(0);
            
            for(indexOriginal in originalCriterias) {
                for(indexSelected in $scope.rowQueries) {
                    if(originalCriterias[indexOriginal].key == $scope.rowQueries[indexSelected].key) {
                        var index = returnCriterias.indexOf($scope.rowQueries[indexSelected]);
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

        $scope.next = function() {
            if($scope.currentView == 'timeframe') {
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
                $scope.currentView = 'timeframe';
            }

            else if($scope.currentView == 'columns') {
                $scope.currentView = 'searches';
            }

            else if($scope.currentView == 'preview') {
                $scope.currentView = 'columns';
            }
        }

        $scope.addRow = function(definition) {
            if(jq.inArray(definition, $scope.rowQueries) < 0) {
                $scope.rowQueries.push(definition);
            }
        }

        $scope.removeRow = function(idx) {
            $scope.rowQueries.splice(idx, 1);
        }

        $scope.addColumn = function(definition) {
            if(jq.inArray(definition, $scope.columns) < 0) {
                $scope.columns.push(definition);
            }
        }

        $scope.removeColumn = function(idx) {
            $scope.columns.splice(idx, 1);
        }

        $scope.moveColumnUp = function(idx) {
            swap($scope.columns, idx - 1, idx);
        }

        $scope.moveColumnDown = function(idx) {
            swap($scope.columns, idx, idx + 1);
        }

        $scope.preview = function() {
            $scope.results = null;

            $http.get(emr.fragmentActionLink('reportingui', 'adHocAnalysis', 'preview',
                    {
                        rowQueries: angular.toJson($scope.rowQueries),
                        columns: angular.toJson($scope.columns)
                    })).
                success(function(data, status, headers, config) {
                    $scope.results = data;
                });
        }

    }]);