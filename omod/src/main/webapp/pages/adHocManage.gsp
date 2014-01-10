<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "moment.min.js")
    ui.includeJavascript("uicommons", "angular.min.js")
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

    <ul>
        <li>
            <a class="button" href="${ui.pageLink("reportingui", "adHocAnalysis", [ definitionClass: "org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition" ]) }">
                <i class="icon-plus"></i>
                New
            </a>
        </li>

        <% exports.findAll { it.type == "PatientDataSetDefinition" } .each { %>
            <li>
                ${ it.name }
                <em>${ it.description }</em>
                <a href="adHocAnalysis.page?definition=${ it.uuid }">
                    <i class="icon-pencil"></i>
                    Edit
                </a>
                <a href="adHocRun.page?dataset=${ it.uuid }">
                    <i class="icon-play"></i>
                    Run
                </a>
            </li>
        <% } %>
    </ul>
</fieldset>