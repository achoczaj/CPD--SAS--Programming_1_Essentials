/****************************************************
Creating Summary Reports cheatsheet - a collection of snippets

from Summary of Lesson 11: Creating Summary Reports
- produce one-way and two-way frequency tables by using the FREQ procedure
- enhance frequency tables by using options
- use PROC FREQ to validate data in a SAS data set
- calculate summary statistics and multilevel summaries by using the MEANS procedure
- enhance summary tables by using options
- identify extreme and missing values by using the UNIVARIATE procedure
- define the Output Delivery System and ODS destinations
- use ODS statements to direct report output to various ODS destinations
- specify a style definition by using the STYLE= option
- create report output that can be viewed in Microsoft Excel
*****************************************************/

/**********************************************
1. Using PROC FREQ to Create Summary Reports */

/* 1.1 Creating a One-Way Frequency Report */
PROC FREQ DATA=orion.sales;
   TABLES Gender;
   WHERE Country='AU';
RUN;

/* One-Way Frequency Report
shows the four statistics that PROC FREQ displays by default.

The FREQ Procedure
Gender  |Frequency  |Percent |CumulativeFrequency |CumulativePercent
F	      |27	        |42.86	 |27	                |42.86
M	      |36	        |57.14	 |63	                |100.00
*/

/* 1.2 Suppress one or more of the statistics of One-Way Table */
/* Suppress one or more of the statistics
by specifying options:
    TABLES Gender/NOCUM;
NOCUM - suppresses the display of cumulative
frequency and cumulative percentages
    TABLES Gender/NOPRECENT;
NOPRECENT - suppresses the display of all percentages.
    TABLES Gender/NOCUM NOPRECENT; /*used together*/
in the TABLES statement */

/* Selecting variables for a FREQ Summary Report
Frequency distributions work best
with following variables:
First, the values of the variable are categorical (fall into few categories).
Second, the values are best summarized by counts instead of averages.
e.g. gender, country, sizes (M/L/XL/..)
Variables that have continuous numeric values,
such as dollar amounts, age and dates,
can be grouped into artificial categories (tiers)
by applying SAS or user-defined formats [descriptive labels to data vales].

/* 1.3 Using TIERS format in PROC FREQ*/
PROC FORMAT;
   VALUE Tiers low-25000='Tier1'
               25000<-50000='Tier2'
               50000<-100000='Tier3'
               100000<-high='Tier4';
RUN;
PROC FREQ DATA=orion.sales;
   TABLES Salary;
   FORMAT Salary Tiers.; /*apply TIERS format to Salary*/
RUN;


/* 2. Listing Multiple Variables on a TABLES Statement */
PROC FREQ DATA=orion.sales;
   TABLES Gender Country; /*add more variables*/
RUN;

/* 2.2 Listing Multiple Variables
with a separate analysis for each group */
PROC SORT DATA=orion.sales
   OUT=sorted; /*use new data set for sorted data */
   BY Country; /*the sorting variable*/
RUN;
PROC FREQ DATA=sorted;
   TABLES Gender;
   BY Country; /*add the sorting variable*/
RUN;


/* 3. Creating a Crosstabulation Table */
/* Crosstabulation Table is a single table
with statistics for each distinct combination of
values of the selected variables.*/
PROC FREQ DATA=orion.sales;
   TABLES Gender*Country; /*use '*' between variables*/
RUN;
/* A crosstabulation table summarizes data
for two or more categorical variables
by showing the number of observations
for each combination of variable values.

The simplest crosstabulation table is a two-way table.
The first variable specifies the table rows
and the second variable specifies the table columns.*/

/* 3.2 Suppress one or more of the statistics
for a Crosstabulation Table */
/* Suppress one or more of the statistics
by specifying options:
    TABLES Gender*Country/NOPRECENT;
NOPRECENT - suppresses the display of all percentages.
    TABLES Gender*Country/NOFREQ;
NOFREQ - suppresses the display of cell frequencies
    TABLES Gender*Country/NOROW;
NOROW - suppresses the display of row percentages
    TABLES Gender*Country/NOCOL;
NOCOL - suppresses the display of column  percentages
    TABLES Gender*Country/NOROW NOCOL; /*used together*/
in the TABLES statement */

/* 3.3. Simplify the format of a Crosstabulation Table */
/* Simplify the format of a Crosstabulation Table
by specifying options:
    TABLES Gender*Country/LIST;
LIST - display crosstabulation table in list format
    TABLES Gender*Country/CROSSLIST ;
CROSSLIST - display crosstabulation table in crosslist format
in the TABLES statement */

/* 3.3. Specifying a format (e.g. width of column) for Frequencies
in a Crosstabulation Table (in the default format, not LIST or CROSSLIST) */
/* Apply a FORMAT= to display variables with alternate text,
and the text wraps to the next line in your output.
Add another option to the TABLES statement, the FORMAT= option.
This option allows you to format the frequency value
and to change the width of the column.

    TABLES Gender*Country/FORMAT=12.;
    /*specify any standard SAS numeric format
    or a user-defined numeric format.
    The format length cannot exceed 24.*/
*/

/*--- PRACTICE 1 ---*/
/* Producing Frequency Reports with PROC FREQ */
PROC FORMAT;
   VALUE ordertypes
         1='Retail'
         2='Catalog'
         3='Internet';
RUN;

TITLE 'Order Summary by Year and Type';
PROC FREQ DATA data=orion.orders ;
   TABLES Order_Date; /*tab 1*/
   TABLES Order_Type/nocum; /*tab 2*/
   TABLES Order_Date*Order_Type/nopercent
          norow nocol; /*tab 3*/
   FORMAT Order_Date year4. Order_Type ordertypes.;
RUN;
TITLE;


/* 4. Examining Your Data with PROC FREQ reports*/

/* Examining Your Data with PROC PRINT trying to identify observations
that do not meet data requirements */
PROC PRINT DATA=orion.nonsales2 (obs=20); /*PRINT only the first 20 observations*/
RUN;

/* 4.1 Use PROC FREQ to find missing values*/
The FREQ procedure lists all discrete values
for a variable and reports missing values.*/
PROC FREQ DATA=orion.nonsales2;
   TABLES Gender Country/nocum nopercent;
   /* report shows missing values*/
RUN;

/* 4.2 Using PROC FREQ Options to find duplicate values */
PROC FREQ DATA=orion.nonsales2 ORDER=freq; /*to find duplicate values*/
   /*use the ORDER=FREQ option to display the results
   in descending frequency order -> duplicate values>1 */
   TABLES Employee_ID/nocum nopercent;
RUN;

/* 4.2.1. Using PROC FREQ nlevels option to find duplicate values */
/* Another option for validating unique values
is to use the NLEVELS option*/
PROC FREQ DATA=orion.nonsales2 nlevels;
   TABLES Gender Country Employee_ID/nocum nopercent;
RUN;
/* When you specify NLEVELS, PROC FREQ displays a table
of the distinct values—or levels—for each variable in the TABLES statement. */

/* If you only want to see the Number of Variable Levels table
and not the individual frequency tables,
you can add the NOPRINT option to the TABLES statement.*/
PROC FREQ DATA=orion.nonsales2 nlevels;
   TABLES Gender Country Employee_ID/nocum nopercent noprint;
   /*noprint = show only the Number of Variable Levels table*/
RUN;

/* 5. Using PROC PRINT to display the observations
containing the invalid values */
PROC PRINT DATA=orion.nonsales2;
   WHERE Gender not in ('F','M') OR /*define the invalid values as options*/
         Country not in ('AU','US') OR
         Job_Title is null OR
         Salary not between 24000 and 500000 OR
         Employee_ID is missing OR
         Employee_ID=120108; /*duplicate value*/
RUN;
/* All of the invalid data, or data that doesn’t meet
our data requirements are in one report.
This make a task of cleaning the data a lot easier.*/


/* 6. Creating a Summary Report with PROC MEANS */
/*PROC MEANS produces summary reports with descriptive statistics.*/
PROC MEANS DATA=orion.sales;
   VAR Salary;
RUN;
/*By default, PROC MEANS reports the number of nonmissing values
of the analysis variable (N)*/

/* 6.1 Grouping Observations by using the CLASS Statement */
/* Creating a PROC MEANS Report with Grouped Data
(statistics grouped by other variables) */
PROC MEANS DATA=orion.sales;
   VAR Salary;
   CLASS Gender Country; /*class variables*/
RUN;
/* reports statistics for each class level,
so there's a row for each combination of class variable values */

/* 6.2 Requesting Specific or Additional Statistics in PROC MEANS */
PROC MEANS DATA=orion.sales n nmiss min max range mean; /*Requesting Specific Statistics*/
   VAR Salary;
   *class Gender Country;
RUN;
/*output includes the statistics that you specify, in the order that you specify them.*/


/* 7. Validating Data Using PROC UNIVARIATE
to detect Data Outliers and Missing Values */
PROC UNIVARIATE DATA=orion.nonsales2;
   VAR Salary;
RUN;
/*The Extreme Observations table shows the five lowest
and the five highest values of the variable.
The Obs values indicate the observation number (record ID),
not the count of observations with that value.*/

/*To specify the number of extreme observations
that PROCUNIVARIATE lists use the NEXTROBS= option
in the PROC UNIVARIATE statement*/
PROC UNIVARIATE DATA=orion.nonsales2 nextrobs=3;/*show 3 obs*/
   VAR Salary;
RUN;

/* Show the observation ID (e.g. employee IDs)
that correspond to the observation numbers
in the Extreme Observations table */
Use ID To display the e.g. Employee_ID column in the table
now, and you can easily determine
which employees have salaries that are below the*/
PROC UNIVARIATE DATA=orion.nonsales2 nextrobs=3;
   VAR Salary;
   ID Employee_ID;
RUN;

/* Using the SAS Output Delivery System
/*Use a filepath to a location where you have Write access.*/
ods pdf file="c:/output/salaries.pdf";

proc means data=orion.sales min max sum;
   var Salary;
   class Gender Country;
RUN;

ods pdf close;

ods csv file="c:/output/salarysummary.csv";

proc means data=orion.sales min max sum;
   var Salary;
   class Gender Country;
RUN;

ods csv close;
