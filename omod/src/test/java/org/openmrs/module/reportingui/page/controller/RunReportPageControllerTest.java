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

import org.junit.Before;
import org.junit.Test;
import org.openmrs.module.reporting.report.definition.ReportDefinition;
import org.openmrs.module.reporting.report.definition.service.ReportDefinitionService;
import org.openmrs.module.reporting.report.renderer.RenderingMode;
import org.openmrs.module.reporting.report.service.ReportService;
import org.openmrs.ui.framework.page.PageModel;

import java.util.ArrayList;
import java.util.List;

import static org.hamcrest.CoreMatchers.is;
import static org.junit.Assert.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 *
 */
public class RunReportPageControllerTest {

    private String reportDefinitionUuid;
    private ReportDefinition reportDefinition;
    private List<RenderingMode> renderingModes;
    private ReportDefinitionService reportDefinitionService;
    private ReportService reportService;

    @Before
    public void setUp() throws Exception {
        reportDefinitionUuid = "uuid-of-report-definition";
        reportDefinition = new ReportDefinition();
        renderingModes = new ArrayList<RenderingMode>();

        reportDefinitionService = mock(ReportDefinitionService.class);
        when(reportDefinitionService.getDefinitionByUuid(reportDefinitionUuid)).thenReturn(reportDefinition);

        reportService = mock(ReportService.class);
        when(reportService.getRenderingModes(reportDefinition)).thenReturn(renderingModes);
    }

    @Test
    public void testGet() throws Exception {
        PageModel model = new PageModel();
        RunReportPageController controller = new RunReportPageController();
        String breadcrumb = "breadcrumb";
        controller.get(reportDefinitionService, reportService, reportDefinitionUuid, breadcrumb, model);

        assertThat((ReportDefinition) model.getAttribute("reportDefinition"), is(reportDefinition));
        assertThat((List<RenderingMode>) model.getAttribute("renderingModes"), is(renderingModes));
        assertThat((String) model.getAttribute("breadcrumb"), is(breadcrumb));
    }

}
