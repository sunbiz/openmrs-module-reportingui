package org.openmrs.module.reportingui.fragment.controller;

import org.openmrs.api.context.Context;
import org.openmrs.module.reporting.definition.library.AllDefinitionLibraries;
import org.openmrs.module.reporting.definition.library.LibraryDefinitionSummary;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

/**
 *
 */
public class DefinitionLibraryFragmentController {

    public List<SimpleObject> getDefinitions(@RequestParam("type") String type,
                                             UiUtils ui,
                                             @SpringBean AllDefinitionLibraries allDefinitionLibraries) throws Exception {
        Class clazz = Context.loadClass(type);
        List<LibraryDefinitionSummary> definitions = allDefinitionLibraries.getDefinitionSummaries(clazz);
        return simplify(ui, definitions);
    }

    private List<SimpleObject> simplify(UiUtils ui, List<LibraryDefinitionSummary> definitions) {
        List<SimpleObject> simplified = SimpleObject.fromCollection(definitions, ui, "type", "key", "name:message", "description:message", "parameters.name", "parameters.label:message", "parameters.type", "parameters.collectionType");
        return simplified;
    }

}
