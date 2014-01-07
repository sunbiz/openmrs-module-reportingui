<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "moment.min.js")
    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeJavascript("reportingui", "adHocAnalysis.js")
    ui.includeJavascript("mirebalaisreports", "ui-bootstrap-tpls-0.6.0.min.js")
    ui.includeCss("reportingui", "adHocReport.css")
    ui.includeCss("mirebalaisreports", "dailyReport.css")

    def jsString = {
        it ? """ "${ ui.escapeJs(it) }" """ : "null"
    }
%>

<%= ui.includeFragment("appui", "messages", [ codes: [
        "reportingui.adHocReport.timeframe.startDateLabel",
        "reportingui.adHocReport.timeframe.endDateLabel"
].flatten()
]) %>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.message("mirebalaisreports.home.title") }", link: "${ ui.pageLink("mirebalaisreports", "home") }" },
        { label: "${ ui.message("mirebalaisreports.adhocreport") }", link: "${ ui.escapeJs(ui.thisUrl()) }" }
    ];

    window.adHocDataExport = {
        type: "org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition",
        name: ${ jsString(definition.name) },
        description: ${ jsString(definition.description) },
        uuid: ${ jsString(definition.uuid) }
    };
    <% if (initialStateJson) { %>
        window.adHocDataExport.initialSetup = ${ initialStateJson };
    <% } %>
</script>

<div id="ad-hoc-report" class="ad-hoc-report" ng-app="adHocAnalysis" ng-controller="AdHocAnalysisController" ng-init="focusFirstElement()">
   
    <div class="summary">
        <span class="summary-parameter done" ng-click="currentView = 'description'" data-step="description">
            <span>${ ui.message("reportingui.adHocReport.description.label") }</span>
        </span>
        <span class="summary-parameter" ng-click="currentView = 'parameters'" data-step="parameters">
            <span>${ ui.message("reportingui.adHocReport.parameters.label") }</span>
            {{ dataExport.parameters.length }}
        </span>

        <span class="summary-parameter" ng-click="currentView = 'searches'" data-step="searches">
            <span>${ ui.message("reportingui.adHocReport.searches") }</span>
            {{ dataExport.rowFilters.length }}
        </span>

        <span class="summary-parameter" ng-click="currentView = 'columns'" data-step="columns">
            <span>${ ui.message("reportingui.adHocReport.columns") }</span>
            {{ dataExport.columns.length }}
        </span>

        <span class="summary-parameter" data-step="preview">
            <span>${ ui.message("reportingui.adHocReport.preview") }</span>
        </span>
    </div>

    <div id="description" class="step" ng-show="currentView == 'description'">
        <h2>${ ui.message("reportingui.adHocReport.description.label") }</h2>
        <p>
            <label>Data Set Name</label>
            <input ng-model="dataExport.name" ng-change="dirty = true"/>
        </p>
        <p>
            <label>Description</label>
            <input ng-model="dataExport.description" ng-change="dirty = true" size="40"/>
        </p>
        <div class="navigation">
            <button ng-click="next()">${ ui.message("reportingui.adHocReport.next") }</button>
        </div>
    </div>

    <div id="parameters" class="step" ng-show="currentView == 'parameters'">
        <h2>${ ui.message("reportingui.adHocReport.parameters.label") }</h2>

        <ul>
            <li class="item" ng-repeat="parameter in dataExport.parameters">
                {{ parameter.label | translate }}:
                <span ng-show="parameter.collectionType">{{ parameter.collectionType }} of </span>
                {{ parameter.type }}
            </li>
        </ul>

        <div class="navigation">
            <button ng-click="back()">${ ui.message("reportingui.adHocReport.back") }</button>
            <button class="focus-first" ng-click="next()">${ ui.message("reportingui.adHocReport.next") }</button>
        </div>
    </div>

    <div id="searches" class="step"  ng-show="currentView == 'searches'">
        <h2>${ ui.message("reportingui.adHocReport.searchCriteria")}</h2>
        <span>Select the values bellow to add Search Criterias</span>
        
        <div>
            <ul>
                <div class="ul-header"><input type="text" class="focus-first" id="row-search" placeholder="${ ui.message('reportingui.adHocReport.addSearchCriteria') }" definitionsearch action="addRow"
                definition-type="org.openmrs.module.reporting.cohort.definition.CohortDefinition" /></div>
                <li ng-click="addRow(criteria)" ng-repeat="criteria in availableSearches()" ng-show="isAllowed(criteria)" class="option">
                    <span>{{ criteria.name }}</span>
                    <small class="definition-description">{{ criteria.description }}</small>
                </li>
            </ul>
            <i class="icon-chevron-right"></i>
            <ul>
                <div ng-show="dataExport.rowFilters.length > 0" class="ul-header selected"><strong>{{ dataExport.rowFilters.length }}</strong>selected search criterias</div>
                <li class="item" ng-repeat="rowQuery in dataExport.rowFilters">
                    <label>{{ \$index + 1 }}.</label>
                    <span class="definition-name">
                        {{ rowQuery.name }}
                    </span>
                    <span class="actions">
                        <i ng-click="removeRow(\$index)"class="icon-remove"></i>
                    </span>
                </li>
            </ul>
            
        </div>
        <div class="navigation">
            <button ng-click="back()">${ ui.message("reportingui.adHocReport.back") }</button>
            <button ng-click="next()">${ ui.message("reportingui.adHocReport.next") }</button>
        </div>
    </div>

    <div id="columns" class="step"  ng-show="currentView == 'columns'">
        <h2>${ ui.message("reportingui.adHocReport.columns") }</h2>
        <span>Select the values bellow to add Columns</span>

        <div>
            <ul>
                <div class="ul-header"><input type="text" class="focus-first" id="column-search" placeholder="${ ui.message('reportingui.adHocReport.addColumns') }" definitionsearch action="addColumn"
                definition-type="org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition" /></div>
                <li ng-click="addColumn(column)" ng-repeat="column in getColumns()" ng-show="isAllowed(column)" class="option">
                    <span>{{ column.name }}</span>
                    <small class="definition-description">{{ column.description }}</small>
                </li>
            </ul>
            <i class="icon-chevron-right"></i>
            <ul>
                <div ng-show="dataExport.columns.length > 0" class="ul-header selected"><strong>{{ dataExport.columns.length }}</strong>selected columns</div>
                <li ng-repeat="col in dataExport.columns" class="item">
                    <label>
                        {{ \$index + 1 }}.
                    </label>
                    {{ col.name }}

                    <span class="actions">
                        <i ng-hide="\$last" ng-click="moveColumnDown(\$index)"class="icon-chevron-down"></i>
                        <i ng-hide="\$first" ng-click="moveColumnUp(\$index)" class="icon-chevron-up"></i>
                        <i ng-click="removeColumn(\$index)" class="icon-remove"></i>
                    </span>
                </li>
            </ul>
        </div>

        <div class="navigation">
            <button ng-click="back()">${ ui.message("reportingui.adHocReport.back") }</button>
            <button class="confirm" ng-click="next()">${ ui.message("reportingui.adHocReport.preview") }</button>
        </div>
    </div>

    <div class="step" ng-show="currentView == 'preview'">
        <h2>
            Preview
        </h2>
        <p class="angular-datepicker">
            <div class="form-horizontal">
                <label>{{ dataExport.parameters[0].label | translate }}</label>
                <input type="text" class="datepicker-input" datepicker-popup="dd-MMMM-yyyy" ng-model="dataExport.parameters[0].value" is-open="isStartDatePickerOpen" max="maxDay" date-disabled="disabled(date, mode)" ng-required="true" show-weeks="false" placeholder="${ ui.message('reportingui.adHocReport.timeframe.startDateLabel')}" />
                <i class="icon-calendar btn" ng-click="openStartDatePicker()"></i>
            </div>
        </p>

        <p class="angular-datepicker">
            <div class="form-horizontal">
                <label>{{ dataExport.parameters[1].label | translate }}</label>
                <input type="text" class="datepicker-input" datepicker-popup="dd-MMMM-yyyy" ng-model="dataExport.parameters[1].value" is-open="isEndDatePickerOpen" min="dataExport.parameters[0].value" max="maxDay" date-disabled="disabled(date, mode)" ng-required="true" show-weeks="false" placeholder="${ ui.message('reportingui.adHocReport.timeframe.endDateLabel')}" />
                <i ng-click="openEndDatePicker()" class="icon-calendar btn"></i>
            </div>
        </p>

        <h3>
            ${ ui.message("reportingui.adHocReport.resultsPreview") }
        </h3>
        <img ng-show="results.loading" src="${ ui.resourceLink("uicommons", "images/spinner.gif") }"/>
        <div class="no-results" ng-show="results.allRows.length == 0">
            <div class="no-results-message">${ ui.message("reportingui.adHocReport.noResults") }</div>
            <button ng-click="back()">${ ui.message("reportingui.adHocReport.back") }</button>
        </div>
        <div ng-show="results.allRows.length > 0">
            The full export would have {{ results.allRows.length }} row(s).
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th ng-repeat="colName in results.columnNames">{{ colName }}</th>
                    </tr>
                </thead>
                <tbody>
                    <tr ng-repeat="row in results.data">
                        <td>{{ \$index + 1 }}</td>
                        <td ng-repeat="col in row">{{ col }}</td>
                    </tr>
                </tbody>
            </table>

            <div class="navigation">
                <button ng-click="back()">${ ui.message("reportingui.adHocReport.back") }</button>
                <span ng-show="dirty">
                <strong>Modified</strong>
                <ul>
                    <li ng-show="dirty.saving">
                        Saving...
                    </li>
                    <li ng-hide="dirty.saving">
                        <button ng-click="saveDataExport()" ng-show="canSave()">
                            <i class="icon-save"></i>
                            Save
                        </button>
                    </li>
                </ul>
            </span>
            <span ng-hide="dirty">
                <button ng-click="runDataExport()" ng-disabled="!canRun()">
                    <i class="icon-run"></i>
                    Run
                </button>
            </span>
            </div>
        </div>
    </div>
</div>