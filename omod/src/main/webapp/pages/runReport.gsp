<%
    ui.decorateWith("appui", "standardEmrPage")

    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeJavascript("mirebalaisreports", "runReport.js")

    def interactiveClass = context.loadClass("org.openmrs.module.reporting.report.renderer.InteractiveReportRenderer")
    def isInteractive = {
        interactiveClass.isInstance(it.renderer)
    }
%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.message("mirebalaisreports.home.title") }", link: "${ ui.pageLink("mirebalaisreports", "home") }" },
        { label: "${ ui.format(reportDefinition) }", link: "${ ui.thisUrl() }" }
    ];

    window.reportDefinition = {
        uuid: '${ reportDefinition.uuid}'
    };
</script>

<style type="text/css">
    .report-list {
        margin-bottom: 1em;
    }

    .report-list ul {
        vertical-align: top;
    }

    .report-list li {
        padding: 5px;
    }

    .report-list li:nth-child(even) {
        background-color: #e0e0e0;
    }

    .block {
        vertical-align: top;
        display: inline-block;
    }

    .block label {
        text-decoration: underline;
    }

    .requested, .parameters, .status {
        width: 25%;
    }

    .download {
        text-align: center;
    }

    #run-report {
        width: 50%;
    }
</style>

<div ng-app="runReportApp">
    <div ng-controller="RunReportController" ng-init="refreshHistory()">

    <h1>${ reportDefinition.name }</h1>
    <h3>${ reportDefinition.description }</h3>

    <fieldset ng-show="queue" class="report-list">
        <legend>Queue</legend>
        <ul>
            <li ng-repeat="request in queue">
                <span class="requested block">
                    <label>Requested</label> <br/>
                    by {{request.requestedBy}} <br/>
                    on {{request.requestDate}}
                </span>
                <span class="parameters block" ng-show="request.reportDefinition.mappings">
                    <label>Parameters</label> <br/>
                    <span ng-repeat="param in request.reportDefinition.mappings">
                        {{ param.value }} <br/>
                    </span>
                </span>
                <span class="status block">
                    <label>Status</label> <br/>
                    {{request.status}} <br/>
                    {{request.evaluateCompleteDatetime}}
                    Priority: {{request.priority}}
                </span>
                <span class="block">
                    <img src="${ ui.resourceLink("uicommons", "images/spinner.gif") }"/>
                </span>
            </li>
        </ul>
    </fieldset>

    <fieldset ng-show="completed" class="report-list">
        <legend>Available Results</legend>
        <ul>
            <li ng-repeat="request in completed">
                <span class="requested block">
                    <label>Requested</label> <br/>
                    by {{request.requestedBy}} <br/>
                    on {{request.requestDate}}
                </span>
                <span class="parameters block" ng-show="request.reportDefinition.mappings">
                    <label>Parameters</label> <br/>
                    <span ng-repeat="param in request.reportDefinition.mappings">
                        {{ param.value }} <br/>
                    </span>
                </span>
                <span class="status block">
                    <label>Status</label> <br/>
                    {{request.status}} <br/>
                    {{request.evaluateCompleteDatetime}}
                </span>
                <span class="download block" ng-show="request.status == 'COMPLETED' || request.status == 'SAVED'">
                    <a class="button big" href="${ ui.pageLink("mirebalaisreports", "viewReportRequest") }?request={{ request.uuid }}">
                        <span ng-show="request.renderingMode.interactive">
                            <i class="icon-eye-open"></i>
                            View
                        </span>
                        <span ng-hide="request.renderingMode.interactive">
                            <i class="icon-download"></i>
                            Download
                        </span>
                    </a>
                </span>
            </li>
        </ul>
    </fieldset>

    <fieldset>
        <legend>Run the report</legend>

        <form method="post" action="runReport.page?reportDefinition=${ reportDefinition.uuid }" id="run-report">
            <% reportDefinition.parameters.each { %>
                <p>
                    <% if (it.collectionType) { %>
                        Parameters of type = collection are not yet implemented
                    <% } else { %>
                        <% if (it.type == java.util.Date) { %>
                            ${ ui.includeFragment("uicommons", "field/datetimepicker", [
                                    formFieldName: "parameterValues[" + it.name + "]",
                                    label: it.label,
                                    useTime: false,
                                    defaultDate: it.defaultValue
                            ])}
                        <% } else { %>
                            Unknown parameter type: ${ it.type }
                        <% } %>
                    <% } %>
                </p>
            <% } %>
            ${ ui.includeFragment("uicommons", "field/dropDown", [
                    formFieldName: "renderingMode",
                    label: "Output format",
                    hideEmptyLabel: true,
                    options: renderingModes
                            .findAll {
                                !isInteractive(it)
                            }
                            .collect {
                                [ value: it.descriptor, label: ui.message(it.label) ]
                            }
            ]) }

            <button type="submit" class="confirm right">
                <i class="icon-play"></i>
                Run
            </button>
        </form>
    </fieldset>

    </div>

</div>