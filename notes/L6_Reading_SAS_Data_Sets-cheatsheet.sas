/****************************************************
 Reading SAS Data Sets cheatsheet - a collection of snippets

from Summary of Lesson 6: Reading SAS Data Sets
*****************************************************/

/****************************
1. Reading a SAS Data Set */

/* Subsetting Observations in the DATA Step */
proc print data=orion.sales; /* examine data set*/
run;

data work.subset1;   /*create a new temporary dataset 'subset1' in 'work' libref from an existing dataset */
   set orion.sales; /* use the two-level name of the data set (libref.filename) to be read*/
   where Country='AU' and
         Job_Title contains 'Rep'; /*define subset conditions */
run;

proc print data=work.subset1; /* print the new subset */
run;

/****************************
1. Creating a New Variable */

/* Subsetting Observations and Creating a New Variable */
data work.subset1;
   set orion.sales;
   where Country='AU' and
         Job_Title contains 'Rep' and
         Hire_Date<'01jan2000'd; /* use a SAS Date constant template - ddmonyyyy'd*/
   Bonus=Salary*.10; /* create new variable = 10% of salary */
run;

proc print data=work.subset1 noobs;
   var First_name Last_Name Salary
       Job_Title Bonus Hire_Date;
   format Hire_Date date9.;
run;

/* Subsetting Variables in a DATA Step: DROP and KEEP */
data work.subset1;
   set orion.sales;
   where Country='AU' and
         Job_Title contains 'Rep';
   Bonus=Salary*.10;
   drop Employee_ID Gender Country Birth_Date;
run;

proc print data=work.subset1;
run;

data work.subset1;
   set orion.sales;
   where Country='AU' and
         Job_Title contains 'Rep';
   Bonus=Salary*.10;
   keep First_Name Last_Name Salary Job_Title Hire_Date Bonus;
run;

proc print data=work.subset1;
run;

/* Selecting Observations by Using the Subsetting IF Statement */
data work.auemps;
   set orion.sales;
   where Country='AU';
   Bonus=Salary*.10;
   if Bonus>=3000;
run;

proc print data=work.auemps;
run;

/* Adding Permanent Labels to a SAS Data Set */

data work.subset1;
   set orion.sales;
   where Country='AU' and
         Job_Title contains 'Rep';
   Bonus=Salary*.10;
   label Job_Title='Sales Title'
         Hire_Date='Date Hired';
   drop Employee_ID Gender Country Birth_Date;
run;

proc contents data=work.subset1;
run;

proc print data=work.subset1 label;
run;

/* Adding Permanent Formats to a SAS Data Set */
data work.subset1;
   set orion.sales;
   where Country='AU' and
         Job_Title contains 'Rep';
   Bonus=Salary*.10;
   label Job_Title='Sales Title'
         Hire_Date='Date Hired';
   format Salary Bonus dollar12.
          Hire_Date ddmmyy10.;
   drop Employee_ID Gender Country Birth_Date;
run;


proc contents data=work.subset1;
run;

proc print data=work.subset1 label;
run;
