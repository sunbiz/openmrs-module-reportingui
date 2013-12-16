<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "moment.min.js")
    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeJavascript("reportingui", "adHocAnalysis.js")
    ui.includeJavascript("mirebalaisreports", "ui-bootstrap-tpls-0.6.0.min.js")
    ui.includeCss("reportingui", "runReport.css")
    ui.includeCss("mirebalaisreports", "dailyReport.css")
%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.message("mirebalaisreports.home.title") }", link: "${ ui.pageLink("mirebalaisreports", "home") }" },
        { label: "${ ui.message("mirebalaisreports.adhocreport") }", link: "${ ui.escapeJs(ui.thisUrl()) }" }
    ];
</script>

<div class="ad-hoc-report" ng-app="adHocAnalysis" ng-controller="AdHocAnalysisController">
    <h1>${ ui.message("reportingui.adHocReport.title") }</h1>

    <div class="summary">
        <span ng-show="parameters[0].value == null && parameters[1].value == null" class="summary-parameter">
            <span class="disabled">${ ui.message("reportingui.adHocReport.timeframe.label") }</span>
        </span>
        <span ng-show="parameters[0].value != null || parameters[1].value != null" class="summary-parameter">
            <strong>${ ui.message("reportingui.adHocReport.timeframe.label") }</strong>
            <div ng-show="parameters[0].value != null" >
                ${ ui.message("reportingui.adHocReport.timeframe.startDate") }
                <span>{{ getFormattedStartDate() }}</span>
            </div>
            <div ng-show="parameters[1].value != null" >
                ${ ui.message("reportingui.adHocReport.timeframe.endDate") }
                <span>{{ getFormattedEndDate() }}</span>
            </div>
        </span>
        
        <span ng-show="rowQueries.length == 0" class="summary-parameter">
            <span class="disabled">${ ui.message("reportingui.adHocReport.searches") }</span>
        </span>
        <span ng-show="rowQueries.length > 0" class="summary-parameter">
            <strong>${ ui.message("reportingui.adHocReport.searches") }</strong>
            <ul>
                <li ng-repeat="rowQuery in rowQueries">
                    {{ rowQuery.name }}
                </li>
            </ul>
        </span>
        <span ng-show="columns.length == 0" class="summary-parameter">
            <span class="disabled">${ ui.message("reportingui.adHocReport.columns") }</span>
        </span>
        <span ng-show="columns.length > 0" class="summary-parameter">
            <strong>${ ui.message("reportingui.adHocReport.columns") }</strong>
            <ul>
                <li ng-repeat="col in columns">
                    {{ col.name }}
                </li>
            </ul>
        </span>
    </div>

    <div ng-show="currentView == 'timeframe'">
        <h2>${ ui.message("reportingui.adHocReport.timeframe.label") }</h2>
        <div class="angular-datepicker">
            <div class="form-horizontal">
                <input type="text" class="datepicker-input" datepicker-popup="dd-MMMM-yyyy" ng-model="parameters[0].value" is-open="isStartDatePickerOpen" max="maxDay" date-disabled="disabled(date, mode)" ng-required="true" show-weeks="false" placeholder="${ ui.message('reportingui.adHocReport.timeframe.startDateLabel')}" />
                <button class="btn" ng-click="openStartDatePicker()"><i class="icon-calendar"></i></button>
            </div>
        </div>

        <div class="angular-datepicker">
            <div class="form-horizontal">
                <input type="text" class="datepicker-input" datepicker-popup="dd-MMMM-yyyy" ng-model="parameters[1].value" is-open="isEndDatePickerOpen" min="parameters[0].value" max="maxDay" date-disabled="disabled(date, mode)" ng-required="true" show-weeks="false" placeholder="${ ui.message('reportingui.adHocReport.timeframe.endDateLabel')}" />
                <button class="btn" ng-click="openEndDatePicker()"><i class="icon-calendar"></i></button>
            </div>
        </div>

        <div class="navigation">
            <button ng-click="next()">${ ui.message("reportingui.adHocReport.next") }</button>
        </div>
    </div>

    <div ng-show="currentView == 'searches'">

        <h2>${ ui.message("reportingui.adHocReport.searchCriteria")}</h2>
        <input type="text" id="row-search" placeholder="${ ui.message('reportingui.adHocReport.addSearchCriteria') }" definitionsearch action="addRow"
               definition-type="org.openmrs.module.reporting.cohort.definition.CohortDefinition" />

        <a class="view-all view-all-criteria" href="javascript:void(0)">${ ui.message('reportingui.adHocReport.viewAllCriteria') }</a>

        <ul>
            <li class="item" ng-repeat="rowQuery in rowQueries">
                <label>{{ \$index + 1 }}.</label>
                {{ rowQuery.name }}
                <span class="actions">
                    <a ng-click="removeRow(\$index)"><i class="icon-remove"></i></a>
                </span>
            </li>
        </ul>

        <div class="navigation">
            <button ng-click="back()">${ ui.message("reportingui.adHocReport.back") }</button>
            <button ng-click="next()">${ ui.message("reportingui.adHocReport.next") }</button>
        </div>
    </div>
    <div ng-show="currentView == 'columns'">
        <h2>${ ui.message("reportingui.adHocReport.columns") }</h2>

        <input type="text" id="column-search" placeholder="${ ui.message('reportingui.adHocReport.addColumns') }" definitionsearch action="addColumn"
               definition-type="org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition" />

        <a class="view-all view-all-columns" href="javascript:void(0)">${ ui.message('reportingui.adHocReport.viewAllColumns') }</a>

        <ul>
            <div ng-repeat="col in columns">
                <li class="item">
                    <label>
                        {{ \$index + 1 }}.
                    </label>
                    {{ col.name }}

                    <span class="actions">
                        <a ng-hide="\$last" ng-click="moveColumnDown(\$index)"><i class="icon-chevron-down"></i></a>
                        <a ng-hide="\$first" ng-click="moveColumnUp(\$index)"><i class="icon-chevron-up"></i></a>
                        <a ng-click="removeColumn(\$index)"><i class="icon-remove"></i></a>
                    </span>
                </li>
            </div>
        </ul>

        <div class="navigation">
            <button ng-click="back()">${ ui.message("reportingui.adHocReport.back") }</button>
            <button class="confirm" ng-click="next()">${ ui.message("reportingui.adHocReport.preview") }</button>
        </div>
    </div>

    <div ng-show="currentView == 'preview'">
        <img ng-show="results.loading" />
        <div class="no-results" ng-show="results == null || results.allRows.length == 0"> 
            <div class="no-results-message">${ ui.message("reportingui.adHocReport.noResults") }</div>
            <button ng-click="back()">${ ui.message("reportingui.adHocReport.back") }</button>
        </div>
        <div ng-show="results.allRows.length > 0">
            <label>
                ${ ui.message("reportingui.adHocReport.resultsPreview") }
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

            <div class="navigation">
                <button ng-click="back()">${ ui.message("reportingui.adHocReport.back") }</button>
                <button class="confirm" ng-click="preview()">${ ui.message("reportingui.adHocReport.download") }</button>
            </div>
        </div>
    </div>
    <div id="search-criteria-dialog" class="dialog" style="display: none">
        <div class="dialog-header">
            <h3>${ ui.message("reportingui.adHocReport.addSearchCriteria") }</h3>
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
            <h3>${ ui.message("reportingui.adHocReport.addColumns") }</h3>
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

    jq('.view-all-criteria').click(function() {
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