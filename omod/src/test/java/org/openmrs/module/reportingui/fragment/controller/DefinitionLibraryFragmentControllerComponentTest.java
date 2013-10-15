package org.openmrs.module.reportingui.fragment.controller;

import org.junit.Test;
import org.openmrs.module.appui.TestUiUtils;
import org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition;
import org.openmrs.module.reporting.definition.library.AllDefinitionLibraries;
import org.openmrs.module.reporting.definition.library.LibraryDefinitionSummary;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.web.test.BaseModuleWebContextSensitiveTest;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;

/**
 *
 */
public class DefinitionLibraryFragmentControllerComponentTest extends BaseModuleWebContextSensitiveTest {

    @Autowired
    private AllDefinitionLibraries allDefinitionLibraries;

    @Test
    public void testGetResources() throws Exception {
        DefinitionLibraryFragmentController controller = new DefinitionLibraryFragmentController();
        List<SimpleObject> definitions = controller.getDefinitions(PatientDataDefinition.class.getName(), new TestUiUtils(), allDefinitionLibraries);

        List<LibraryDefinitionSummary> expected = allDefinitionLibraries.getDefinitionSummaries(PatientDataDefinition.class);
        assertThat(definitions.size(), is(expected.size()));
    }

}
