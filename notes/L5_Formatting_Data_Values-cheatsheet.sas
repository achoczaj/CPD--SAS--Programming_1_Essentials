/****************************************************
Formatting Data Values cheatsheet - a collection of snippets

from Summary of Lesson 5: Formatting Data Values
*****************************************************/

/****************************
1. Using SAS Formats */

/* PROC PRINT w/o Formats */
PROC PRINT DATA=orion.sales LABEL noobs;
   WHERE Country='AU' and
         Job_Title contains 'Rep';
   LABEL Job_Title='Sales Title'
         Hire_Date='Date Hired';
   VAR Last_Name First_Name Country Job_Title
       Salary Hire_Date; /* date has a SAS numeric value */
RUN;

/* Applying Temporary Formats */
PROC PRINT DATA=orion.sales LABEL noobs;
   WHERE Country='AU' and
         Job_Title contains 'Rep';
   LABEL Job_Title='Sales Title'
         Hire_Date='Date Hired';
   FORMAT Hire_Date mmddyy10. Salary dollar8.; /* added formats */
   VAR Last_Name First_Name Country Job_Title
       Salary Hire_Date;
RUN;

/* Specifying a Format for a Text Variables */
PROC PRINT DATA=orion.sales noobs;
    FORMAT First_Name Last_Name $upcase.  /* display all letters as UPCASE / CAPS LOCK */
          Job_Title $quote.;  /* display values in '...' */
    VAR Employee_ID First_Name Last_Name Job_Title;
run;


/* Specifying a User-Defined Format for a Character Variable */
PROC FORMAT; /* create User-Defined Format */
    /* Character formats begin with a dollar sign and must be followed by a letter or underscore */
    VALUE $ctryfmt 'AU'='Australia' /* format name max 32 char, use $ as first letter in the name fo character formt */
                  'US'='United States' /* can using value-or-range-or-list */
                  other='Miscoded'; /* if do not match defined values */
    /* VALUE $oth_fmt ...  add next User-Defined Format within one PROC FORMAT */
RUN;

PROC PRINT DATA=orion.sales label;
   VAR Employee_ID Job_Title Salary
       Country Birth_Date Hire_Date;
   LABEL Employee_ID='Sales ID'
         Job_Title='Job Title'
         Salary='Annual Salary'
         Birth_Date='Date of Birth'
         Hire_Date='Date of Hire';
   FORMAT Salary dollar10. /* use SAS Number Format */
          Birth_Date Hire_Date monyy7. /* use SAS Date Format (with 7 digit date) */
          Country $ctryfmt.; /* apply SAS User-Defined Format */
RUN;

/* Specifying a User-Defined Format for a Numeric Variable */
PROC FORMAT;
    /* Number formats begin with a letter and must be followed by a letter or underscore */
    VALUE tiers   LOW-<50000='Tier1' /* exclude last value using '<' after '-' */
                  50000-100000='Tier2' /* include both values using only - */
                  100000<-HIGH='Tier3'; /* exclude first value using '<' before '-' */
                  /*use keywords LOW and HIGH (!LOW for numeric val does not incl missing values(they are showed with '.' value))*/
RUN;

PROC PRINT DATA=orion.sales;
   VAR Employee_ID Job_Title Salary
       Country Birth_Date Hire_Date;
   FORMAT Birth_Date Hire_Date monyy7.
          Salary tiers.; /* apply SAS User-Defined Format */
RUN;

/* Specifying a User-Defined Format for a Character and a Numeric Variable */
DATA q1birthdays;
   SET orion.employee_payroll;
   BirthMonth=month(Birth_Date);
   IF BirthMonth le 3;
RUN;

PROC FORMAT;
   VALUE $gender  /* User-Defined Format for a Character Variable */
         'F'='Female'
         'M'='Male';
   VALUE mname  /* User-Defined Format for a Numeric Variable */
         1='January'
         2='February'
         3='March';
RUN;

TITLE1 'Employees with Birthdays in Q1';
PROC PRINT DATA=q1birthdays;
   VAR Employee_ID Employee_Gender
       BirthMonth;
   FORMAT Employee_Gender $gender. /* apply SAS User-Defined Format */
          BirthMonth mname.; /* apply SAS User-Defined Format */
RUN;
TITLE;


/*Defining Ranges in User-Defined Formats*/
PROC FORMAT;
   VALUE $gender
          'F'='Female'
          'M'='Male'
          other='Invalid code';  /* use other for errors */

   VALUE salrange
          .='Missing salary' /* label missing values '.'='...' */
          20000-<100000='Below $100,000'
          100000-500000='$100,000 or more'
          other='Invalid salary';  /* use other for errors */
RUN;

TITLE1 'Salary and Gender Values';
TITLE2 'for Non-Sales Employees';

PROC PRINT DATA=orion.nonsales;
   VAR Employee_ID Job_Title Salary Gender;
   FORMAT Salary salrange.
          Gender $gender.;
RUN;
TITLE;
