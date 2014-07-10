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

import org.openmrs.module.reporting.report.ReportRequest;
import org.openmrs.module.reporting.report.renderer.RenderingMode;
import org.openmrs.module.reporting.report.service.ReportService;
import org.openmrs.module.reporting.web.renderers.WebReportRenderer;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.page.FileDownload;
import org.springframework.web.bind.annotation.RequestParam;

/**
 *
 */
public class ViewReportRequestPageController {

    public Object get(@SpringBean ReportService reportService,
                      @RequestParam("request") String requestUuid) {
        ReportRequest req = reportService.getReportRequestByUuid(requestUuid);
        if (req == null) {
            throw new IllegalArgumentException("ReportRequest not found");
        }

        RenderingMode renderingMode = req.getRenderingMode();
        String linkUrl = "/module/reporting/reports/reportHistoryOpen";

        if (renderingMode.getRenderer() instanceof WebReportRenderer) {
            /*
            WebReportRenderer webRenderer = (WebReportRenderer) renderingMode.getRenderer();
            linkUrl = webRenderer.getLinkUrl(req.getReportDefinition().getParameterizable());
            linkUrl = request.getContextPath() + (linkUrl.startsWith("/") ? "" : "/") + linkUrl;
            if (req != null) {
                ReportData reportData = getReportService().loadReportData(req);
                if (reportData != null) {
                    request.getSession().setAttribute(ReportingConstants.OPENMRS_REPORT_DATA, reportData);
                    request.getSession().setAttribute(ReportingConstants.OPENMRS_REPORT_ARGUMENT, renderingMode.getArgument());
                    request.getSession().setAttribute(ReportingConstants.OPENMRS_LAST_REPORT_URL, linkUrl);
                }
            }
            return new ModelAndView(new RedirectView(linkUrl));
            */
            throw new IllegalStateException("Web Renderers not yet implemented");
        }
        else {
            String filename = renderingMode.getRenderer().getFilename(req).replace(" ", "_");
            String contentType = renderingMode.getRenderer().getRenderedContentType(req);
            byte[] data = reportService.loadRenderedOutput(req);

            if (data == null) {
                throw new IllegalStateException("Error retrieving the report");
            } else {
                return new FileDownload(filename, contentType, data);
            }
        }
    }

}
