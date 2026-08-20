/* Adapted from "Data Preparation /FinalProject.sas" (keithchhh/SAS-Coursework):
   the PROC SQL mode-imputation pass -- compute the modal workclass/occupation
   via a GROUP BY + ORDER BY freq DESC, capture it into a macro variable with
   SELECT ... INTO :macro, then use that macro variable to fill missing
   values in a later DATA step. Original runs against adult.csv from a
   hardcoded student path; here a small inline sample (with blank workclass/
   occupation standing in for the missing() cases) stands in for that file. */

data adult_census_new;
	length workclass $20 occupation $20;
	input age workclass $ occupation $;
	datalines;
25 Private Adm-clerical
41 Private Craft-repair
33 Private Exec-managerial
50 . .
29 State-gov Prof-specialty
38 Private Adm-clerical
45 Private Craft-repair
;
run;

proc sql;
    /* Calculate mode for workclass */
create table mode_workclass as
select workclass, count(*) as freq
from adult_census_new
group by workclass
order by freq desc; /* Arranges the mode on top */

/* Retrieve the mode value */
select workclass into :mode_workclass
from mode_workclass
; /* Select the mode value */

quit;

proc sql;
create table mode_occupation as
select occupation, count(*) as freq
from adult_census_new
group by occupation
order by freq desc; /* Arranges the mode on top */

/* Retrieve the mode value */
select occupation into :mode_occupation
from mode_occupation
; /* Select the mode value */

quit;

data adult_census_new;
set adult_census_new;
/* Replace missing values with mode */
if missing(workclass) then workclass = "&mode_workclass";
if missing(occupation) then occupation = "&mode_occupation";

run;

proc print data=adult_census_new;
run;
