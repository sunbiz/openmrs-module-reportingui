package org.openmrs.module.reportingui.page.controller;

import org.openmrs.module.reporting.definition.library.AllDefinitionLibraries;
import org.openmrs.module.reporting.evaluation.Definition;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.page.PageModel;

import java.util.Set;

/**
 *
 */
public class AllDefinitionLibrariesPageController {

    public void get(@SpringBean AllDefinitionLibraries allDefinitionLibraries,
                    PageModel model) {
        Set<Class<? extends Definition>> allTypes = allDefinitionLibraries.getAllDefinitionTypes();
        model.put("allTypes", allTypes);
        model.put("allDefinitionLibraries", allDefinitionLibraries);
    }

}
