/****************************************************
Producing Detail Reports cheatsheet - a collection of snippets

from Summary of Lesson 4: Producing Detail Reports
*****************************************************/


/****************************
 1. Subsetting Report Data */

/* Basic Subsetting Your Report */
PROC PRINT DATA=orion.sales;
   VAR Last_Name First_Name Salary; /* specify the variables to include and list them in the order in which they are to be displayed */
   SUM Salary; /* calculate and display report totals for the requested numeric variables */
RUN;

/* Selecting Observations */
PROC PRINT DATA=orion.sales noobs;
   VAR Last_Name First_Name Salary Country;
   WHERE Country='AU' and Salary<25500; /* subsets the observations in a report,  the output contains only the observations that meet the conditions */
RUN;

/* Using the CONTAINS Operator */
PROC PRINT DATA=orion.sales noobs;
   VAR Last_Name First_Name Country Job_Title;
   WHERE Country='AU' and Job_Title CONTAINS 'Rep';
RUN;

/* Using the IN Operator */
PROC PRINT DATA=orion.sales noobs;
   VAR Last_Name First_Name Country Job_Title;
   WHERE Country IN ('AU','UK','US');
RUN;

/* Subsetting Observations and Replacing the Obs Column */
PROC PRINT DATA=orion.customer_dim;
   WHERE Customer_Age=21;
   ID Customer_ID; /*  specify a variable to print at the beginning of the row instead of an observation number */
   VAR Customer_Name
       Customer_Gender Customer_Country
       Customer_Group Customer_Age_Group
       Customer_Type;
RUN;


/*************************************
 2. Sorting and Grouping Report Data */

/* Sorting a Data Set BY One variable*/
PROC SORT DATA=orion.sales
          OUT=work.sales_sort; /* specify an output data set */
   BY Salary; /* variables in the input data set whose values are used to sort the data; by default, SAS sorts in ascending order */
RUN;

PROC PRINT DATA=work.sales_sort;
RUN;

/* Sorting a Data Set by Multiple Variables */
PROC SORT DATA=orion.sales
          OUT=work.sales2;
   BY Country descending Salary; /*  sort by Country ASC, and by Salary DESC */
RUN;

PROC PRINT DATA=work.sales2;
RUN;

/* Grouping Observations in Reports */
PROC SORT DATA=orion.sales
          OUT=work.sales2;
   BY Country descending Salary;
RUN;

PROC PRINT DATA=work.sales2;
   BY Country; /* display observations grouped by a particular variable or variables */
RUN;


/***********************
3. Enhancing Reports */

/* Displaying Titles and Footnotes in a Report */
TITLE1 'Orion Star Sales Staff'; /* title - line 1; up to 10 lines of titles */
TITLE2 'Salary Report';
FOOTNOTE1 'Confidential'; /* footnote - line 1; up to 10 lines of footnotes */

PROC PRINT DATA=orion.sales;
   VAR Employee_ID Last_Name Salary;
RUN;

PROC PRINT DATA=orion.sales;
   VAR Employee_ID First_Name Last_Name Job_Title Hire_Date;
RUN;

/* Changing and Canceling Titles and Footnotes */
TITLE1 'Orion Star Sales Staff';
TITLE2 'Salary Report';
FOOTNOTE1 'Confidential';

PROC PRINT DATA=orion.sales;
   VAR Employee_ID Last_Name Salary;
RUN;

TITLE1 'Employee Information';
PROC PRINT DATA=orion.sales;
   VAR Employee_ID First_Name Last_Name Job_Title Hire_Date;
RUN;

/* Displaying Labels in a Report */
TITLE1 'Orion Star Sales Staff';
TITLE2 'Salary Report';
FOOTNOTE1 'Confidential';

PROC PRINT DATA=orion.sales label;
   VAR Employee_ID Last_Name Salary;
   LABEL Employee_ID = 'Sales ID' /* define temporary labels to display in the report instead of variable names */
         Last_Name = 'Last Name'
         Salary = 'Annual Salary';
RUN;
TITLE; /*  use a null TITLE statement to cancel all titles */
FOOTNOTE; /*  use a null FOOTNOTE statement to cancel all titles */

/* Displaying Split Labels for Columns in a Report */
TITLE1 'Orion Star Sales Staff';
TITLE2 'Salary Report';
FOOTNOTE1 'Confidential';

PROC PRINT DATA=orion.sales SPLIT='*';
   VAR Employee_ID Last_Name Salary;
   LABEL Employee_ID = 'Sales ID' /* define temporary labels to display in the report instead of variable names */
         Last_Name = 'Last Name'
         Salary = 'Annual*Salary'; /* add split char '*' (line brake), use for long labels to line brakes */
RUN;
TITLE; /*  use a null TITLE statement to cancel all titles */
FOOTNOTE; /*  use a null FOOTNOTE statement to cancel all titles */
