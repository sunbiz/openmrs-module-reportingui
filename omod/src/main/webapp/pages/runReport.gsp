<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeCss("reportingui", "runReport.css")

    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeJavascript("reportingui", "runReport.js")

    def interactiveClass = context.loadClass("org.openmrs.module.reporting.report.renderer.InteractiveReportRenderer")
    def isInteractive = {
        interactiveClass.isInstance(it.renderer)
    }
%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        <% if (breadcrumb) { %>
            ${ breadcrumb },
        <% } %>
        { label: "${ ui.format(reportDefinition) }", link: "${ ui.escapeJs(ui.thisUrl()) }" }
    ];

    window.reportDefinition = {
        uuid: '${ reportDefinition.uuid}'
    };
</script>

${ ui.includeFragment("appui", "translations", [ codes:
        [ "reporting.status.PROCESSING", "reporting.status.COMPLETED", "reporting.status.SCHEDULE_COMPLETED",
                "reporting.status.SAVED", "reporting.status.FAILED" ] ])}

<div ng-app="runReportApp" ng-controller="RunReportController" ng-init="refreshHistory()">

    <h1>${ reportDefinition.name }</h1>
    <h3>${ reportDefinition.description }</h3>

    <div class="past-reports">
        <fieldset class="report-list">
            <legend>${ ui.message("reportingui.runReport.completed.legend") }</legend>
            <span ng-hide="completed">
                ${ ui.message("emr.none") }
            </span>
            <table ng-show="completed">
                <thead>
                    <tr>
                        <th>${ ui.message("reporting.reportRequest.status") }</th>
                        <th>${ ui.message("reporting.reportRequest.parameters") }</th>
                        <th>${ ui.message("reportingui.ReportRequest.requested") }</th>
                        <th>${ ui.message("reporting.reportRequest.actions") }</th>
                    </tr>
                </thead>
                <tbody>
                    <tr ng-repeat="request in completed">
                        <td>
                            {{request.status | translate:'reporting.status.'}} <br/>
                            {{request.evaluateCompleteDatetime}}
                        </td>
                        <td>
                            <span ng-repeat="param in request.reportDefinition.mappings">
                                {{ param.value }} <br/>
                            </span>
                        </td>
                        <td>
                            {{request.requestedBy}} <br/>
                            {{request.requestDate}}
                        </td>
                        <td>
                            <span class="download" ng-show="request.status == 'COMPLETED' || request.status == 'SAVED'">
                                <a class="button" href="${ ui.pageLink("reportingui", "viewReportRequest") }?request={{ request.uuid }}">
                                    <span ng-show="request.renderingMode.interactive">
                                        <i class="icon-eye-open"></i>
                                        ${ ui.message("reporting.reportHistory.open") }
                                    </span>
                                    <span ng-hide="request.renderingMode.interactive">
                                        <i class="icon-download"></i>
                                        ${ ui.message("uicommons.downloadButtonLabel") }
                                    </span>
                                </a>
                            </span>
                        </td>
                    </tr>
                </tbody>
            </table>
        </fieldset>
    </div>

    <div class="running-reports">
        <fieldset ng-show="queue" class="report-list">
            <legend>${ ui.message("reportingui.runReport.queue.legend") }</legend>
            <table ng-show-"queue">
                <thead>
                    <tr>
                        <th>${ ui.message("reporting.reportRequest.status") }</th>
                        <th>${ ui.message("reporting.reportRequest.parameters") }</th>
                    </tr>
                </thead>
                <tbody>
                    <tr ng-repeat="request in queue">
                        <td>
                            {{request.status | translate:'reporting.status.'}}
                            <img class="right small" ng-show="request.status=='PROCESSING' || request.status=='REQUESTED'" src="${ ui.resourceLink("uicommons", "images/spinner.gif") }"/>
                            <br/>
                            <span ng-show="request.status=='REQUESTED'">
                                ${ ui.message("reporting.reportRequest.priority") }: {{request.priority | translate:'reporting.ReportRequest.Priority.'}} <br/>
                            </span>
                            {{request.requestedBy}} <br/>
                            {{request.requestDate}}
                        </td>
                        <td>
                            <span ng-repeat="param in request.reportDefinition.mappings">
                                {{ param.value }} <br/>
                            </span>
                        </td>
                    </tr>
                </tbody>
            </table>
        </fieldset>

        <fieldset>
            <legend>${ ui.message("reportingui.runReport.run.legend") }</legend>

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
                        label: ui.message("reporting.reportRequest.outputFormat"),
                        hideEmptyLabel: true,
                        options: renderingModes.findAll {
                                    !isInteractive(it)
                                }
                                .collect {
                                    [ value: it.descriptor, label: ui.message(it.label) ]
                                }
                ]) }

                <button type="submit" class="confirm right">
                    <i class="icon-play"></i>
                    ${ ui.message("reportingui.runButtonLabel") }
                </button>
            </form>
        </fieldset>
    </div>

</div>