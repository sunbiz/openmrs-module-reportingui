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

package org.openmrs.module.reportingui.adhoc;

import org.apache.commons.beanutils.PropertyUtils;
import org.codehaus.jackson.annotate.JsonIgnoreProperties;
import org.codehaus.jackson.annotate.JsonProperty;
import org.openmrs.module.reporting.cohort.definition.DefinitionLibraryCohortDefinition;
import org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition;
import org.openmrs.module.reporting.dataset.definition.RowPerObjectDataSetDefinition;
import org.openmrs.module.reporting.definition.library.AllDefinitionLibraries;
import org.openmrs.module.reporting.evaluation.Definition;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;
import org.openmrs.module.reporting.query.Query;

@JsonIgnoreProperties({"label", "value", "name", "description", "parameters"})
public class AdHocRowFilter {

    @JsonProperty
    private String type;

    @JsonProperty
    private String key;

    public AdHocRowFilter() {
    }

    public AdHocRowFilter(String key) {
        this.key = key;
    }

    public AdHocRowFilter(Mapped<? extends Definition> query) {
        try {
            this.key = (String) PropertyUtils.getProperty(query.getParameterizable(), "definitionKey");
            this.type = query.getParameterizable().getClass().getName();
        } catch (Exception e) {
            throw new IllegalArgumentException("query does not have a definitionKey property");
        }
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public Query toQuery(Class<? extends RowPerObjectDataSetDefinition> dsdClass, AllDefinitionLibraries definitionLibraries) {
        if (PatientDataSetDefinition.class.isAssignableFrom(dsdClass)) {
            DefinitionLibraryCohortDefinition query = new DefinitionLibraryCohortDefinition();
            query.setDefinitionKey(key);
            query.loadParameters(definitionLibraries);
            return query;
        }
        else {
            throw new IllegalArgumentException("Don't know how to convert to query for " + dsdClass);
        }
    }
}
