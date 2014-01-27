<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "moment.min.js")
    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeCss("reportingui", "adHocReport.css")
    ui.includeJavascript("uicommons", "angular-ui/ui-bootstrap-tpls-0.6.0.min.js")
%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.escapeJs(ui.message("reportingui.adHocAnalysis.label")) }", link: "${ ui.escapeJs(ui.thisUrl()) }" }
    ];
</script>

<h1>${ ui.message("reportingui.adHocManage.title") }</h1>

<div class="report-header">
    <h3>${ ui.message("reportingui.adHocManage.group.title.org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition") }</h3>

    <a class="button confirm" href="${ui.pageLink("reportingui", "adHocAnalysis", [ definitionClass: "org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition" ]) }">
        <i class="icon-plus"></i>
        ${ ui.message("reportingui.adHocManage.new") }
    </a>
</div>

<table class="manage-adhoc-reports">
    <thead>
        <tr>
            <th>${ ui.message("reportingui.adHocReport.name") }</th>
            <th>${ ui.message("reportingui.adHocReport.description") }</th>
            <th>${ ui.message("reportingui.adHocManage.actions") }</th>
        </tr>
    </thead>
    <tbody>
    <% exports.findAll { it.type == "PatientDataSetDefinition" } .each { %>
        <tr>
            <th>${ it.name }</th>
            <th>${ it.description ?: "" }</th>
            <th>
                <a href="adHocRun.page?dataset=${ it.uuid }"><i class="icon-play small"></i></a>
                <a href="adHocAnalysis.page?definition=${ it.uuid }"><i class="icon-pencil small"></i></a>
            </th>
        </tr>
    <% } %>
    </tbody>
</table>