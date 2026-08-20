/* Adapted from "Data Preparation /FinalProject.sas" (keithchhh/SAS-Coursework),
   the array-based '?' -> missing cleanup pass (the ARRAY Chars[*] _char_ loop).
   Original reads adult.csv from a hardcoded student path; here a small inline
   sample carrying the same '?' sentinel values used by the UCI Adult dataset
   stands in for that file so the cleanup logic runs unmodified. */

data adult_census_missing_raw;
	length workclass $20 education $12 native_country $20 income $6;
	input age workclass $ education $ native_country $ income $;
	datalines;
25 Private Bachelors United-States <=50K
41 ? HS-grad ? <=50K
33 Self-emp-not-inc Masters United-States >50K
50 ? ? Mexico <=50K
29 State-gov Some-college United-States >50K
;
run;

data adult_census_missing;
set adult_census_missing_raw;
array Chars[*] _char_;
do i = 1 to dim(Chars);
if Chars[i] = '?' then Chars[i] = ' ';
end;
drop i;
run;

proc print data=adult_census_missing;
run;

proc freq data=adult_census_missing;
table workclass education native_country;
run;
