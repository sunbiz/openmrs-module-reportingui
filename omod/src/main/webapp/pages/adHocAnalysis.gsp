<%
    ui.decorateWith("appui", "standardEmrPage")

    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeJavascript("reportingui", "adHocAnalysis.js")
%>

<style type="text/css">
    fieldset {
        margin-top: 0.5em;
        margin-bottom: 0.5em;
    }
    .item {
        border: 1px black solid;
        margin: 5px;
        padding: 5px;
        border-radius: 5px;
    }

    .item label {
        padding-right: 10px;
    }

    .item .actions {
        float: right;
    }

    .actions a {
        cursor: pointer;
    }
</style>

<div ng-app="adHocAnalysis" ng-controller="AdHocAnalysisController">

    <fieldset>
        <legend>Which Patients?</legend>

        <input type="text" id="row-search" placeholder="Add a patient search" definitionsearch action="addRow"
               definition-type="org.openmrs.module.reporting.cohort.definition.CohortDefinition" />

        <ul>
            <li class="item" ng-repeat="rowQuery in rowQueries">
                <label>{{ \$index + 1 }}.</label>
                {{ rowQuery.name }}
                <span class="actions">
                    <a ng-click="removeRow(\$index)">X</a>
                </span>
            </li>
        </ul>
    </fieldset>

    <fieldset>
        <legend>Which Columns?</legend>

        <input type="text" id="column-search" placeholder="Add a column" definitionsearch action="addColumn"
               definition-type="org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition" />

        <ul>
            <li class="item" ng-repeat="col in columns">
                <label>
                    {{ \$index + 1 }}.
                </label>
                {{ col.name }}

                <span class="actions">
                    <a ng-hide="\$first" ng-click="moveColumnUp(\$index)">Move up</a>
                    <a ng-hide="\$last" ng-click="moveColumnDown(\$index)">Move down</a>
                    <a ng-click="removeColumn(\$index)">X</a>
                </span>
            </li>
        </ul>
    </fieldset>

    <button ng-click="preview()">
        Preview
    </button>

    <fieldset ng-show="results">
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
    </fieldset>

</div>