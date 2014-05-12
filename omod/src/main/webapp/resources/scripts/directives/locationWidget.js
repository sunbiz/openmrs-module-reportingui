angular.module('reportingui')
    .directive('locationWidget', ['LocationService', function(LocationService) {

        var uniqueId = 0;

        function link(scope, element, attrs) {
            scope.uniqueId = 'locationWidget' + ++uniqueId;
            scope.template = 'widgetTemplates/locationWidget' + (attrs.multiple ? 'Multiple' : '') + '.page';
            scope.locations = [];
            LocationService.getLocations().then(function(result) {
                scope.locations = result;
            });
        };

        return {
            restrict: 'E',
            scope: {
                target: '='
            },
            controller: function($scope) {
                $scope.collectValues = function() {
                    $scope.selected = _.where($scope.locations, { selected: true });
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