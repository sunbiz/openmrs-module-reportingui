/*
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */

package org.openmrs.module.reportingui.page.controller;

import org.openmrs.api.context.Context;
import org.openmrs.module.reporting.report.ReportRequest;
import org.openmrs.module.reporting.report.renderer.RenderingMode;
import org.openmrs.module.reporting.report.renderer.ReportRenderer;
import org.openmrs.module.reporting.report.service.ReportService;
import org.openmrs.module.reportingui.adhoc.AdHocExportManager;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.text.SimpleDateFormat;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AdHocHomePageController {

    public void get(@SpringBean AdHocExportManager adHocExportManager,
                    PageModel model) {
        List<AdHocExportManager.AdHocDataSet> exports = adHocExportManager.getAdHocDataSets(Context.getAuthenticatedUser());
        model.addAttribute("exports", exports);
    }

    public Object post(@RequestParam("dataset") List<String> dsdUuids,
                       @RequestParam("outputFormat") String outputFormat,
                       //@MethodParam("getParamValues") Map<String, Object> paramValues, // UIFR-137
                       HttpServletRequest req,
                       @SpringBean AdHocExportManager adHocExportManager,
                       @SpringBean ReportService reportService,
                       UiUtils ui) throws Exception {
        if (dsdUuids.size() == 0) {
            return "redirect:" + ui.pageLink("reportingui", "home");
        }

        RenderingMode mode = new RenderingMode((ReportRenderer) Context.loadClass(outputFormat).newInstance(), outputFormat, null, 0);

        Map<String, Object> paramValues = getParamValues(req);
        ReportRequest reportRequest = adHocExportManager.buildExportRequest(dsdUuids, paramValues, mode);
        reportRequest.setDescription("[Ad Hoc Export]");
        reportRequest = reportService.queueReport(reportRequest);
        reportService.processNextQueuedReports();

        return SimpleObject.create("uuid", reportRequest.getUuid());
    }

    private Map<String, Object> getParamValues(HttpServletRequest request) {
        Map<String, Object> paramValues = new HashMap<String, Object>();
        for (Enumeration<String> e = request.getParameterNames(); e.hasMoreElements(); ) {
            String name = e.nextElement();
            if (name.startsWith("param[")) {
                Object value = request.getParameter(name);
                name = name.substring(name.indexOf("[") + 1, name.lastIndexOf("]"));
                try {
                    value = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse((String) value);
                } catch (Exception e1) {
                    // pass
                }
                paramValues.put(name, value);
            }
        }
        return paramValues;
    }

}
