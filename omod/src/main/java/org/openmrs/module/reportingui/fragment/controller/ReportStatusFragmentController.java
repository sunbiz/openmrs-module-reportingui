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

package org.openmrs.module.reportingui.fragment.controller;

import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.evaluation.parameter.Parameterizable;
import org.openmrs.module.reporting.report.ReportRequest;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.reporting.report.definition.service.ReportDefinitionService;
import org.openmrs.module.reporting.report.renderer.InteractiveReportRenderer;
import org.openmrs.module.reporting.report.service.ReportService;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 *
 */
public class ReportStatusFragmentController {

    public List<SimpleObject> getQueuedRequests(@RequestParam(value = "reportDefinition", required = false) String reportDefinitionUuid,
                                                @SpringBean ReportDefinitionService reportDefinitionService,
                                                @SpringBean ReportService reportService,
                                                UiUtils ui) {

        ReportDefinition reportDefinition = null;
        if (reportDefinitionUuid != null) {
            reportDefinitionService.getDefinitionByUuid(reportDefinitionUuid);
        }
        List<ReportRequest> requests = reportService.getReportRequests(reportDefinition, null, null, ReportRequest.Status.REQUESTED, ReportRequest.Status.PROCESSING);

        return simplify(ui, requests);

    }

    public List<SimpleObject> getCompletedRequests(@RequestParam(value = "reportDefinition", required = false) String reportDefinitionUuid,
                                                   @SpringBean ReportDefinitionService reportDefinitionService,
                                                   @SpringBean ReportService reportService,
                                                   UiUtils ui) {
        ReportDefinition reportDefinition = null;
        if (reportDefinitionUuid != null) {
            reportDefinitionService.getDefinitionByUuid(reportDefinitionUuid);
        }

        List<ReportRequest> requests = reportService.getReportRequests(reportDefinition, null, null, 10, ReportRequest.Status.FAILED, ReportRequest.Status.COMPLETED, ReportRequest.Status.SAVED);

        return simplify(ui, requests);
    }

    public List<SimpleObject> simplify(UiUtils ui, List<ReportRequest> requests) {
        List<SimpleObject> ret = new ArrayList<SimpleObject>();
        for (ReportRequest request : requests) {
            ret.add(simplify(ui, request));
        }

        return ret;
    }

    private SimpleObject simplify(UiUtils ui, ReportRequest request) {
        SimpleObject simple = SimpleObject.fromObject(request, ui,
                "uuid", "renderingMode.label", "priority", "schedule",
                "requestedBy", "requestDate", "status",
                "evaluateStartDatetime", "evaluateCompleteDatetime", "renderCompleteDatetime");

        ((SimpleObject) simple.get("renderingMode")).put("interactive", request.getRenderingMode().getRenderer() instanceof InteractiveReportRenderer);
        simple.put("reportDefinition", simplify(ui, request.getReportDefinition()));
        simple.put("baseCohort", simplify(ui, request.getBaseCohort()));

        return simple;
    }

    public class ParamValue {
        private String name;
        private String value;

        public ParamValue(String name, String value) {
            this.name = name;
            this.value = value;
        }

        public String getName() {
            return name;
        }

        public String getValue() {
            return value;
        }
    }

    private SimpleObject simplify(UiUtils ui, Mapped<? extends Parameterizable> mapped) {
        if (mapped == null) {
            return null;
        }

        List<ParamValue> parameterMappings = new ArrayList<ParamValue>();
        for (Map.Entry<String, Object> entry : mapped.getParameterMappings().entrySet()) {
            parameterMappings.add(new ParamValue(entry.getKey(), ui.format(entry.getValue())));
        }

        SimpleObject simple = new SimpleObject();
        simple.put("mappings", parameterMappings);
        if (mapped.getParameterizable() != null) {
            simple.put("name", mapped.getParameterizable().getName());
            simple.put("description", mapped.getParameterizable().getDescription());
        }
        return simple;
    }

}
