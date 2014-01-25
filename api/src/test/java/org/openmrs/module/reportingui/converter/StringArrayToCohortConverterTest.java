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

package org.openmrs.module.reportingui.converter;

import org.junit.Test;
import org.openmrs.Cohort;
import org.openmrs.module.reporting.common.ReportingMatchers;

import static org.junit.Assert.assertThat;

public class StringArrayToCohortConverterTest {

    @Test
    public void testConvert() throws Exception {
        Cohort cohort = new StringArrayToCohortConverter().convert(new String[]{"1", "2", "3,4,5"});
        assertThat(cohort, ReportingMatchers.isCohortWithExactlyIds(1, 2, 3, 4, 5));
    }

    @Test(expected = NumberFormatException.class)
    public void testConvertIllegal() throws Exception {
        Cohort cohort = new StringArrayToCohortConverter().convert(new String[]{"1", "2", "null"});
    }
}
