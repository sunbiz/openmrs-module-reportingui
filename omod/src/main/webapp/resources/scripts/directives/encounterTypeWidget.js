angular.module('reportingui')
    .directive('encounterTypeWidget', ['EncounterTypeService', function(EncounterTypeService) {

        var uniqueId = 0;

        function link(scope, element, attrs) {
            scope.uniqueId = 'encTypeWidget' + ++uniqueId;
            scope.template = 'widgetTemplates/encounterTypeWidget' + (attrs.multiple ? 'Multiple' : '') + '.page';
            scope.encounterTypes = [];
            EncounterTypeService.getEncounterTypes().then(function(result) {
                scope.encounterTypes = result;
            });
        };

        return {
            restrict: 'E',
            scope: {
                target: '='
            },
            controller: function($scope) {
                $scope.collectValues = function() {
                    $scope.selected = _.where($scope.encounterTypes, { selected: true });
                    $scope.target = _.map($scope.selected, function(item) {
                        var obj = angular.copy(item);
                        delete obj.selected;
                        return obj;
                    });
                }
            },
            template: '<div ng-include="template"></div>',
            link: link
        };
    }]);