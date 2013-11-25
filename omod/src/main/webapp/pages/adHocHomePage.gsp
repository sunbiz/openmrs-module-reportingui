<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeJavascript("reportingui", "adHocAnalysis.js")
    ui.includeCss("reportingui", "runReport.css")
%>

<div class="ad-hock-report">
	<h1>Ad Hock Report Analysis</h1>
	<em>Create you own custom report and export it.</em>
	<h6>Choose one of the following:</h6>
	<ul>
		<li>
			<a class="button" href="${ui.pageLink("reportingui", "adHocAnalysis") }">
			<i class="icon-user"></i>
			Patients
			</a>
		</li>
		<li>
			<a class="button" href="${ui.pageLink("reportingui", "adHocAnalysis") }">
			<i class="icon-paste"></i>
			Encounters
			</a>
		</li>
	</ul>
</div>