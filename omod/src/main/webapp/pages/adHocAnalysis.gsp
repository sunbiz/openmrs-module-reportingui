<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeJavascript("reportingui", "adHocAnalysis.js")
    ui.includeCss("reportingui", "runReport.css")
%>

<div class="ad-hoc-report" ng-app="adHocAnalysis" ng-controller="AdHocAnalysisController">
    <h1>Patient Ad Hoc Report</h1>

    <div class="summary">
        <span ng-show="parameters.length > 0" class="summary-parameter">
            <strong>Timeframe</strong>
            <div>
                Start date
                <span>20 April 2013</span>
            </div>
            <div>
                End date
                <span>23 April 2013</span>
            </div>
        </span>
        <span ng-show="rowQueries.length > 0" class="summary-parameter">
            <strong>Searches</strong>
            <ul>
                <li ng-repeat="rowQuery in rowQueries">
                    {{ rowQuery.name }}
                </li>
            </ul>
        </span>
        <span ng-show="columns.length > 0" class="summary-parameter">
            <strong>Columns</strong>
            <ul>
                <li ng-repeat="col in columns">
                    {{ col.name }}
                </li>
            </ul>
        </span>
    </div>

    <div ng-show="currentView == 'timeframe'">
        <h2>Timeframe</h2>
        ${ ui.includeFragment("uicommons", "field/datetimepicker", [
            id: "startDate",
            label: "Start Date",
            formFieldName: "startDate",
            useTime: false
        ])}
        ${ ui.includeFragment("uicommons", "field/datetimepicker", [
            id: "endDate",
            label: "End Date",
            formFieldName: "endDate",
            useTime: false
        ])}

        <button ng-click="next()">Next</button>
    </div>

    <div ng-show="currentView == 'searches'">
        <h2>Search Criteria</h2>
        <input type="text" id="row-search" placeholder="add search criteria" definitionsearch action="addRow"
               definition-type="org.openmrs.module.reporting.cohort.definition.CohortDefinition" />

        <a class="view-all view-all-criterias" href="javascript:void(0)">view all search criterias</a>

        <ul>
            <li class="item" ng-repeat="rowQuery in rowQueries">
                <label>{{ \$index + 1 }}.</label>
                {{ rowQuery.name }}
                <span class="actions">
                    <a ng-click="removeRow(\$index)"><i class="icon-remove"></i></a>
                </span>
            </li>
        </ul>

        <button ng-click="back()">Back</button>
        <button ng-click="next()">Next</button>
    </div>
    <div ng-show="currentView == 'columns'">
        <h2>Columns</h2>

        <input type="text" id="column-search" placeholder="add a column" definitionsearch action="addColumn"
               definition-type="org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition" />

        <a class="view-all view-all-columns" href="javascript:void(0)">view all columns</a>

        <ul>
            <div ng-repeat="col in columns">
                <li class="item">
                    <label>
                        {{ \$index + 1 }}.
                    </label>
                    {{ col.name }}

                    <span class="actions">
                        <a ng-hide="\$first" ng-click="moveColumnUp(\$index)"><i class="icon-chevron-up"></i></a>
                        <a ng-hide="\$last" ng-click="moveColumnDown(\$index)"><i class="icon-chevron-down"></i></a>
                        <a ng-click="removeColumn(\$index)"><i class="icon-remove"></i></a>
                    </span>
                </li>
            </div>
        </ul>

        <button ng-click="back()">Back</button>
        <button ng-click="next()">Next</button>
    </div>

    <div ng-show="currentView == 'preview'">
        <div class="no-results" ng-show="results == null || results.allRows.length == 0"> 
            No results were found. Please review your search criteria.
            <button ng-click="back()">Back</button>
        </div>
        <div ng-show="results.allRows.length > 0">
            <label>
                Preview of {{ results.allRows.length }} results
            </label>

            <table>
                <thead>
                    <tr>
                        <th ng-repeat="colName in results.columnNames">{{ colName }}</th>
                    </tr>
                </thead>
                <tbody>
                    <tr ng-repeat="row in results.data">
                        <td ng-repeat="col in row">{{ col }}</td>
                    </tr>
                </tbody>
            </table>

            <button ng-click="back()">Back</button>
            <button class="confirm" ng-click="preview()">Download Report</button>
        </div>
    </div>
    <div id="search-criteria-dialog" class="dialog" style="display: none">
        <div class="dialog-header">
            <h3>Select a search criteria to add</h3>
            <i class="icon-remove"></i>
        </div>
        <div class="dialog-content form">
            <ul>
                <a ng-click="addRow(criteria)" ng-repeat="criteria in getDefinitions()">{{ criteria.name }}</a>
            </ul>
        </div>
    </div>
    <div id="columns-dialog" class="dialog" style="display: none">
        <div class="dialog-header">
            <h3>Select columns to add</h3>
            <i class="icon-remove"></i>
        </div>
        <div class="dialog-content form">
            <ul>
                <a ng-click="addColumn(column)" ng-repeat="column in getColumns()">{{ column.name }}</a>
            </ul>
        </div>
    </div>
</div>

<script type="text/javascript">
    criteriasDialog = null;
    columnsDialog = null;

    jq(function() {
        criteriasDialog = emr.setupConfirmationDialog({
            selector: '#search-criteria-dialog'
        });

        columnsDialog = emr.setupConfirmationDialog({
            selector: '#columns-dialog'
        });
    });

    jq('.view-all-criterias').click(function() {
        criteriasDialog.show();
    })

    jq('.view-all-columns').click(function() {
        columnsDialog.show();
    })

    jq('.dialog .icon-remove').click(function() {
        criteriasDialog.close();
        columnsDialog.close();
    });
</script>