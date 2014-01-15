<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "moment.min.js")
    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeCss("reportingui", "adHocReport.css")
    ui.includeJavascript("mirebalaisreports", "ui-bootstrap-tpls-0.6.0.min.js")
%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.escapeJs(ui.message("reportingui.adHocAnalysis.label")) }", link: "${ ui.escapeJs(ui.thisUrl()) }" }
    ];
</script>

<h1>Ad Hoc Exports</h1>

<div class="report-header">
    <h3>Patient Data Sets</h3>

    <a class="button confirm" href="${ui.pageLink("reportingui", "adHocAnalysis", [ definitionClass: "org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition" ]) }">
        <i class="icon-plus"></i>
        New data set
    </a>
</div>

<table class="manage-adhoc-reports">
    <thead>
        <tr>
            <th>Name</th>
            <th>Description</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
    <% exports.findAll { it.type == "PatientDataSetDefinition" } .each { %>
        <tr>
            <th>${ it.name }</th>
            <th>${ it.description }</th>
            <th>
                <a href="adHocRun.page?dataset=${ it.uuid }"><i class="icon-play"></i></a>
                <a href="adHocAnalysis.page?definition=${ it.uuid }"><i class="icon-pencil"></i></a>
            </th>
        </tr>
    <% } %>
    </tbody>
</table>