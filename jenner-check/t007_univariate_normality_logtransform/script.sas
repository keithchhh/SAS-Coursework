/* Adapted from "Data Preparation /FinalProject.sas" (keithchhh/SAS-Coursework):
   the normality-testing pass for Age -- PROC UNIVARIATE with the Shapiro-Wilk
   test plus QQ/histogram plots, followed by a log transform and a second
   PROC UNIVARIATE pass on the transformed variable. Original runs against
   adult.csv from a hardcoded student path; a small inline sample stands in
   for that file so the same statistical logic runs unmodified. */

data adult_census_final;
	input age;
	datalines;
25
30
28
33
41
19
22
36
45
52
29
38
;
run;

/* Shapiro-Wilk test for 'Age' */
proc univariate data=adult_census_final normal;
   var Age;
   qqplot Age / normal(mu=est sigma=est);
   histogram Age / normal(mu=est sigma=est);
   ods select QQPlot Histogram NormalityTests;
run;

/* Log transformation for 'Age' */
data adult_census_transformed_age;
    set adult_census_final;
    log_Age = log(Age);
run;

/* Shapiro-Wilk test and plots for log-transformed 'Age' */
proc univariate data=adult_census_transformed_age normal;
   var log_Age;
   qqplot log_Age / normal(mu=est sigma=est);
   histogram log_Age / normal(mu=est sigma=est);
   ods select QQPlot Histogram NormalityTests;
run;
