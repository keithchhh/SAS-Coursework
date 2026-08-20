/* Adapted from "Data Preparation /FinalProject.sas" (keithchhh/SAS-Coursework):
   the derived-variable pass building AgeGroup and Occupation_Type buckets,
   plus a custom $workClassFormat collapsing the raw workclass levels into
   Government/Self-employed/Not-employed groups. Original runs against
   adult.csv from a hardcoded student path; here a small inline sample with
   the same column shape stands in for that file so the derivation logic
   runs unmodified. */

data adult_census_new;
	length workclass $20 occupation $20;
	input age workclass $ occupation $;
	datalines;
17 Private Adm-clerical
25 Federal-gov Exec-managerial
33 Self-emp-not-inc Prof-specialty
45 Local-gov Farming-fishing
61 Never-worked Sales
70 State-gov Tech-support
38 Self-emp-inc Priv-house-serv
;
run;

proc format;
	value $workClassFormat 'Federal-gov','Local-gov','State-gov' = 'Government'
							'Self-emp-inc','Self-emp-not-inc' ='Self-employed'
							'Never-worked','Without-pay'= 'Not-employed';
run;

data adult_census_derived;
set adult_census_new;

length AgeGroup $7. Occupation_Type $30.;

/* Derived Variable 1: AgeGroup */
if age < 30 then AgeGroup = 'Young';
else if age>=30 and age < 60 then AgeGroup = 'Adult';
else if age >=60 then  AgeGroup = 'Senior';

/* Derived Variable 2: Occupation_Type */
if occupation in ('Exec-managerial', 'Prof-specialty', 'Tech-support') then Occupation_Type = 'Professional';
else if occupation in  ('Adm-clerical', 'Handlers-cleaners', 'Farming-fishing') then Occupation_Type = 'Service';
else if occupation in  ('Sales', 'Protective-serv', 'Priv-house-serv') then Occupation_Type = 'Sales';
else Occupation_Type = 'Others';

format workClass $workClassFormat.;

run;

proc print data=adult_census_derived;
run;

proc freq data=adult_census_derived;
table AgeGroup Occupation_Type workClass;
run;
