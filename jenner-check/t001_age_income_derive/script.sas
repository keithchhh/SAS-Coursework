/* Adapted from "Data Preparation /FinalProject.sas" (keithchhh/SAS-Coursework).
   Original reads adult.csv via PROC IMPORT from a hardcoded student path
   (/home/u63569331/BAN110_Labs_Assignments/FinalProject/adult.csv); here a
   small inline sample with the same column shape stands in for that file so
   the derived-variable logic (ageFormat, HighIncome, Capital_Gain_Loss,
   ageCategory) runs unmodified. */

data adult_census_copy;
	length income $6 workclass $20;
	input age income $ capital_gain capital_loss education_num;
	datalines;
17 <=50K 0 0 6
22 <=50K 0 0 9
29 >50K 5000 0 13
34 >50K 0 0 10
41 <=50K 0 1200 9
52 >50K 15000 0 14
63 <=50K 0 0 5
71 <=50K 0 0 9
19 <=50K 0 0 10
38 >50K 7688 0 13
;
run;

proc format;
	value ageFormat low-18 = 'Under18'
	           18-30 ='Young'
	           30-45= 'MiddleAged'
	           45-65= 'Senior'
	           65-high='Above65';
run;

data adult_census_new_column;
set adult_census_copy;
/* Create a new column 'HighIncome' to indicate if an adult earns more than $50,000 annually */
if income = '>50K' then HighIncome = 1; /* Assign 1 if income is greater than $50,000 */
else HighIncome = 0; /* Assign 0 if income is less than or equal to $50,000 */

Capital_Gain_Loss = capital_gain - capital_loss;

ageCategory=put(age,ageFormat.);

run;

proc print data=adult_census_new_column;
run;

proc freq data=adult_census_new_column;
table ageCategory HighIncome;
run;
