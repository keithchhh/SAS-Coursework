/* Adapted from "Data Preparation /FinalProject.sas" (keithchhh/SAS-Coursework):
   the target-variable summary pass (PROC FREQ on the categorical variables
   income/workclass/occupation, PROC MEANS on the numeric variables
   age/capital_gain_loss/hours_per_week/highincome). Original runs against
   adult.csv from a hardcoded student path; here a small inline sample with
   the same column shape (post-derivation: highincome and capital_gain_loss
   already computed, as in the original pipeline) stands in for that file. */

data adult_census_missing;
	length workclass $20 occupation $20 income $6;
	input age income $ workclass $ occupation $ capital_gain_loss hours_per_week highincome;
	datalines;
25 <=50K Private Adm-clerical 0 40 0
41 <=50K Private Craft-repair 1500 45 0
33 >50K Self-emp-not-inc Exec-managerial 3000 60 1
50 <=50K Private Machine-op 0 35 0
29 >50K State-gov Prof-specialty 5000 50 1
38 <=50K Private Sales -200 40 0
45 >50K Federal-gov Exec-managerial 8000 55 1
;
run;

/*Target Variables*/
proc freq data=adult_census_missing;
table income workclass occupation;
run;

proc means data=adult_census_missing mean max min;
var age capital_gain_loss hours_per_week highincome;
run;
