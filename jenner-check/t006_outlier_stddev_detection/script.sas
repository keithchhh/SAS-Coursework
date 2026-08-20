/* Adapted from "Data Preparation /FinalProject.sas" (keithchhh/SAS-Coursework):
   the standard-deviation outlier-detection pattern for Age (PROC MEANS to
   capture mean/std into a one-row summary dataset, then a DATA step that
   uses "if _n_ = 1 then set <summary>" to broadcast those two scalars onto
   every row and flag/filter values beyond mean +/- 2*std). Original runs
   against adult.csv from a hardcoded student path; a small inline sample
   stands in for that file so the detection logic runs unmodified. (The
   original script names its filtered output "adult_census_range", which the
   script never actually creates -- this bundle threads the same detection
   logic against the derived dataset it was clearly meant to consume.) */

data adult_census_derived;
	input age;
	datalines;
25
30
28
150
33
41
19
22
-5
36
;
run;

proc means data=adult_census_derived;
   var age;
   output out=Age_Mean_Std(drop=_:) mean=age_mean std=age_std;
run;

data _null_;
set adult_census_derived;
if _n_ = 1 then set Age_Mean_Std;
if age le age_mean - 2 * age_std or age ge age_mean + 2 * age_std then
put "Possible Outlier Value of Age is " age;
run;

data adult_census_age_outlier;
set adult_census_derived;
if _n_ = 1 then set Age_Mean_Std;
if age ge age_mean - 2 * age_std and age le age_mean + 2 * age_std;
run;

proc print data=adult_census_age_outlier;
run;
