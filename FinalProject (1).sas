/*Handling the spacing and special character issues in the headers if the columns*/
OPTIONS validvarname =V7;

/*Importing the CSV file into SAS*/
PROC IMPORT DATAFILE= "/home/u63569331/BAN110_Labs_Assignments/FinalProject/adult.csv" 
OUT= WORK.Adult_Census
DBMS=CSV
REPLACE;
GETNAMES=YES;
RUN;

proc contents data=work.adult_census;
run;

/*Extract relevant data from the original dataset*/
data adult_census_copy;
set adult_census(drop=fnlwgt relationship marital_status);
run;

data adult_census_copy;
set adult_missingvalues (rename= education_num = education_num1);

run;

proc format;
	value ageFormat low-18 = 'Under18'
	           18-30 ='Young'
	           30-45= 'MiddleAged'
	           45-65= 'Senior'
	           65-high='Above65';
run;

data adult_census_new_column;
set adult_census_copy (rename= education_num = education_num1);;
/* Create a new column 'HighIncome' to indicate if an adult earns more than $50,000 annually */
if income = '>50K' then HighIncome = 1; /* Assign 1 if income is greater than $50,000 */
else HighIncome = 0; /* Assign 0 if income is less than or equal to $50,000 */

Capital_Gain_Loss = capital_gain - capital_loss;
education_num = put(education_num1, $2.);
drop capital_gain capital_loss education_num1;

ageCategory=put(age,ageFormat.);

run;

data adult_census_missing;
set adult_census_new_column;

/*Replacing the ? from teh dataset with missing values for data cleaning*/
if workclass = '?' then workclass = ' ';
if education = '?' then education = ' ';
if occupation = '?' then occupation = ' ';
if race = '?' then race = ' ';
if sex = '?' then sex = ' ';
if native_country = '?' then native_country = ' ';
if income = '?' then income = ' ';

run;

data adult_census_missing;
set adult_census_new_column;
array Chars[*] _char_;
do i = 1 to dim(Chars);
if Chars[i] = '?' then Chars[i] = ' ';
end;
drop i;
run;



/* Looking at the target variables
Categorical - Workclass education native_country income
Numerical - capital_gain_loss age */


/* the data seems heavily skewed to US as a native_country, which may not be fair as incomes are higher */
/* the workclass is skewed to have more 'Private' occupations, which may not be fair when comparing */
/*target variable code to add */

proc freq data=adult_census_missing;
table workclass education native_country income sex race occupation;
run;

proc means data=adult_census_missing mean max min;
var age capital_gain_loss hours_per_week highincome;
run;

/*Target Variables*/
proc freq data=adult_census_missing;
table income workclass occupation;
run;

proc means data=adult_census_missing mean max min;
var age capital_gain_loss hours_per_week highincome;
run;


title "Shape of the distribution of the Target Variable";
proc sgplot data=adult_census_missing;
histogram age;density age;
run;

proc sgplot data=adult_census_missing;
histogram capital_gain_loss;density capital_gain_loss;
run;

title 'Number of observations in top and bottom 10%';
proc univariate data=adult_census_missing noprint;
	var hours_per_week;
	output out=TMP pctlpts=5 95 pctlpre=Percent_;
run;


title 'Histogram for Number of hours';
proc sgplot data=adult_census_missing ;
	histogram hours_per_week; density hours_per_week;
run;

data adult_census_new;
set adult_census_missing;

run;

/* Treating missing values through imputation with the mode.*/
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

proc sql;
create table mode_nativecountry as
select native_country, count(*) as freq
from adult_census_new
group by native_country
order by freq desc; /* Arranges the mode on top */

/* Retrieve the mode value */
select native_country into :mode_nativecountry
from mode_nativecountry
; /* Select the mode value */

quit;

data adult_census_new;
set adult_census_new;
/* Replace missing values with mode */
if missing(workclass) then workclass = "&mode_workclass";
if missing(occupation) then occupation = "&mode_occupation";
if missing(native_country) then native_country = "&mode_nativecountry";

run;

/*Creation of derived variables*/
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



data adult_census_derived;
set adult_census_derived;

if age < 18 or age > 100 then delete;

run;

proc sql;
 select count(*) from adult_census_derived 
 where hours_per_week not between 10 and 80;
quit; *result is 666;
 
/*Delete extreme values ie, greter than 80 and less than 10*/
data adult_census_derived;
set adult_census_derived;
if hours_per_week gt 80 or hours_per_week lt 10 then delete;
run;



/*Outlier detection */
/*distribution of 'hours_per_week' */

title "Distribution of hours_per_Week";
proc sgplot data=adult_census_derived;
histogram hours_per_week;density hours_per_week;
run;

/*distribution of 'age' */
title "Distribution of age";
proc sgplot data=adult_census_derived;
histogram age;density age;
run;

title "Box plot to detect outliers of hours_per_Week";
proc sgplot data=adult_census_range;
vbox hours_per_Week;
run;

/*distribution of 'age' */
title "Box plot to detect outliers of age";
proc sgplot data=adult_census_range;
vbox age;
run;

/*Detecting Outliers : Age*/
proc means data=adult_census_derived;
   var age;
   output out=Age_Mean_Std(drop=_:) mean=age_mean std=age_std;
run;

proc means data=adult_census_derived;
var capital_gain_loss;
output out=Mean_Std (drop=_type_ _freq_)
mean =
std = / autoname
;

/*Removal of Outliers : Standard deviation*/
data null;
set adult_census_range;
if _n_ = 1 then set Age_Mean_Std;
if age le age_mean - 2 * age_std or age ge age_mean + 2 * age_std then
put "Possible Outlier Value of Age is " age;
run;


data adult_census_age_outlier;
set adult_census_range;
if _n_ = 1 then set Age_Mean_Std;
if age ge age_mean - 2 * age_std and age le age_mean + 2 * age_std;
run;


/*Detecting Outliers : hours_per_week*/
proc means data=adult_census_range;
   var age;
   output out=Age_Mean_Std(drop=_:) mean=age_mean std=age_std;
run;

data null;
set adult_census_range;
if _n_ = 1 then set Age_Mean_Std;
if age le age_mean - 2 * age_std or age ge age_mean + 2 * age_std then
put "Possible Outlier Value of Age is " age;
run;


data adult_census_age_outlier;
set adult_census_range;
if _n_ = 1 then set Age_Mean_Std;
if age ge age_mean - 2 * age_std and age le age_mean + 2 * age_std;
run;

/* Detecting Outliers for 'hours_per_week' */
proc means data=adult_census_range;
   var hours_per_week;
   output out=Hours_Mean_Std(drop=_:) mean=hours_mean std=hours_std;
run;

data null;
set adult_census_age_outlier;
if _n_ = 1 then set Hours_Mean_Std;
if hours_per_week le hours_mean - 2 * hours_std or hours_per_week ge hours_mean + 2 * hours_std then
put "Possible Outlier Value of hours_per_week is " hours_per_week;
run;

data adult_census_hours_outlier;
set adult_census_age_outlier;
if _n_ = 1 then set Hours_Mean_Std;
if hours_per_week ge hours_mean - 2 * hours_std and hours_per_week le hours_mean + 2 * hours_std;
run;

proc means data=adult_census_hours_outlier;
var capital_gain_loss;
output out=Mean_Std (drop=_type_ _freq_)
mean =
std = / autoname
;

data _null_;
file print;
set adult_census_hours_outlier;
if _n_ = 1 then set Mean_Std;
if capital_gain_loss le capital_gain_loss_mean - 2*capital_gain_loss_stddev and not missing(capital_gain_loss) 
or 
capital_gain_loss ge capital_gain_loss_mean + 2*capital_gain_loss_stddev then
put "Possible Outlier Value of Capital_Gain_Loss is " capital_gain_loss;
run;

/* as capital gains has a high standard deviation, we use the Std to find outliers */


data adult_census_hours_outlier;
set adult_census_hours_outlier;
if _n_ = 1 then set Mean_Std;
if capital_gain_loss ge capital_gain_loss_mean - 2*capital_gain_loss_stddev
and capital_gain_loss le capital_gain_loss_mean + 2*capital_gain_loss_stddev ;
run;

data adult_census_final;
set adult_census_hours_outlier;
run;

/* Shapiro-Wilk test for 'Age' */
proc univariate data=adult_census_final normal;
   var Age;
   qqplot Age / normal(mu=est sigma=est);
   histogram Age / normal(mu=est sigma=est);
   ods select QQPlot Histogram NormalityTests;
run;

/* Shapiro-Wilk test for 'hours_per_week' */
proc univariate data=adult_census_final normal;
   var hours_per_week;
   qqplot hours_per_week / normal(mu=est sigma=est);
   histogram hours_per_week / normal(mu=est sigma=est);
   ods select QQPlot Histogram NormalityTests;
run;

proc univariate data=adult_census_final;
var capital_gain_loss;
   qqplot capital_gain_loss / normal(mu=est sigma=est);
   histogram capital_gain_loss / normal(mu=est sigma=est);
   ods select QQPlot Histogram NormalityTests;
run;




/* Log transformation for 'Age' */
data adult_census_transformed_age;
    set adult_census_final;
    log_Age = log(Age);
run;

/* Log transformation for 'hours_per_week' */
data adult_census_transformed_hours;
    set adult_census_final;
    log_hours_per_week = log(hours_per_week);
run;

data adult_census_transformed_capital;
    set adult_census_final;
    log_capital_gain_loss = log(capital_gain_loss);
run;

/* Shapiro-Wilk test and plots for log-transformed 'Age' */
proc univariate data=adult_census_transformed_age normal;
   var log_Age;
   qqplot log_Age / normal(mu=est sigma=est);
   histogram log_Age / normal(mu=est sigma=est);
   ods select QQPlot Histogram NormalityTests;
run;

/* Shapiro-Wilk test and plots for log-transformed 'hours_per_week' */
proc univariate data=adult_census_transformed_hours normal;
   var log_hours_per_week;
   qqplot log_hours_per_week / normal(mu=est sigma=est);
   histogram log_hours_per_week / normal(mu=est sigma=est);
   ods select QQPlot Histogram NormalityTests;
run;

proc univariate data=adult_census_transformed_hours normal;
   var log_capital_gain_loss;
   qqplot log_capital_gain_loss / normal(mu=est sigma=est);
   histogram log_capital_gain_loss / normal(mu=est sigma=est);
   ods select QQPlot Histogram NormalityTests;
run;

/* Age and Occupation_type based on income
* h=Workclass vs hoursper week
*How age affects capital gain orloss*/

/*BUSINESS QUESTION 1: Considering the distribution of age for different income groups,
 which age group should our financial advisory firm market towards to maximise our return on advertising spend?*/

proc freq data=adult_census_final;
    tables AgeGroup*income / nocum nopercent;
run;

















