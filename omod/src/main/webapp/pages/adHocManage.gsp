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

<fieldset>
    <legend>
        <i class="icon-user"></i>
        Patient
    </legend>

    <ul class="manage-adhoc-reports">
        <li>
            <a class="button confirm" href="${ui.pageLink("reportingui", "adHocAnalysis", [ definitionClass: "org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition" ]) }">
                <i class="icon-plus"></i>
                New data set
            </a>
        </li>

        <% exports.findAll { it.type == "PatientDataSetDefinition" } .each { %>
            <li>
                <a href="adHocRun.page?dataset=${ it.uuid }"><i class="icon-play"></i></a>
                <a href="adHocAnalysis.page?definition=${ it.uuid }"><i class="icon-pencil"></i></a>
                ${ it.name }
                <em>${ it.description }</em>
            </li>
        <% } %>
    </ul>
</fieldset>