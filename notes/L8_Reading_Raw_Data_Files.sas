/****************************************************
Reading Raw Data Files cheatsheet - a collection of snippets

from Summary of Lesson 8: Reading Raw Data Files
*****************************************************/

/************************************
1. Reading Standard Delimited Data */

/* Creating a SAS Data Set from a Delimited Raw Data File */
/*  */
DATA work.sales1;
   INFILE "&path/sales.csv" DLM=',';  /* identify the name and location of the input file, use the DLM= option if the file has a delimiter other than a blank space */
   INPUT Employee_ID First_Name $     /* specify the name and type for each variable to be created. The dollar sign indicates a character variable. */
         Last_Name $ Gender $ Salary
         Job_Title $ Country $;
RUN;
/* Truncation often occurs with list input, because character variables
are created with a length of 8 bytes, by default. */
PROC PRINT DATA=work.sales1;
RUN;

/* Specifying the Lengths of Variables Explicitly to avoid Truncation*/
DATA work.sales2;
    /* Explicitly define the length of character variables using '$ number'.
      Numeric variables can be included in the LENGTH statement
      to preserve the order of variables, but you need to specify
      a length of 8 for each numeric variable. */
    LENGTH  First_Name $ 12 Last_Name $ 18
            Gender $ 1 Job_Title $ 25
            Country $ 2;
    INFILE  "&path/sales.csv" DLM=',';
    INPUT   Employee_ID First_Name $ Last_Name $
            Gender $ Salary Job_Title $ Country $;
RUN;
PROC CONTENTS data=work.sales2;
RUN;
PROC PRINT DATA=work.sales2;
RUN;

/* Specifying the order of variables in The LENGTH Statement to match raw file input  */
DATA work.sales2;
   LENGTH Employee_ID 8 First_Name $ 12 /* always add the length 8 for the Numeric variables*/
          Last_Name $ 18 Gender $ 1
          Salary 8 Job_Title $ 25
          Country $ 2;
   INFILE "&path/sales.csv" DLM=',';
   INPUT  Employee_ID First_Name $ Last_Name $
          Gender $ Salary Job_Title $ Country $;
RUN;

PROC CONTENTS data=work.sales2 varnum; /* varnum option - display variables in their creation order*/
RUN;
PROC PRINT DATA=work.sales2;
RUN;

/**************************************
2. Reading Nonstandard Delimited Data */

/* Specifying Informats (info how to read a value) in the INPUT Statement */
DATA work.sales2;
   INFILE "&path/sales.csv" DLM=',';

   /* An informat tells SAS how to read data values,
   including the number of characters. When SAS reads character data,
   a standard character informat, such as '$12.', is often used
   instead of a LENGTH statement.*/
   /* The colon format modifier ':' before an informat e.g. '$12.'
   tells SAS to ignore the specified length when it reads data values,
   and instead to read only until it reaches a delimiter.
   Omitting the colon format modifier is likely
   to result in data errors.*/
   INPUT Employee_ID First_Name :$12. Last_Name :$18.
         Gender :$1. Salary Job_Title :$25. Country :$2.
         Birth_Date :date. Hire_Date :mmddyy.;
         /* 11AUG1973 == 'date.', 01/01/1993 == 'mmddyy.' */
RUN;

/* SAS informats e.g.
Informant       Raw Data Value  ->  SAS Data Value
COMMA.DOLLAR.   $12,345             12345
COMMAX.DOLLARX. $12.345             12345
EUROX.          €12.345             12345
$CHAR.          _ _Australia        _ _Australia (preserve the leading blanks in the SAS data)
$UPCASE.        au                  AU
MMDDYY.         01/01/1960          0 (SAS Daye Value)
DDMMYY.         31/12/1960          365 (SAS Daye Value)
DATE.           31DEC1959           -1 (SAS Daye Value)
*/
/* Use with the colon format modifier ':' to avoid errors*/
PROC PRINT DATA=work.sales2;
RUN;

/**************************************
3. Subsetting and Adding Permanent Attributes */

DATA work.subset;
   INFILE "&path/sales.csv" DLM=',';
   INPUT  Employee_ID First_Name :$12.
          Last_Name :$18. Gender :$1. Salary
          Job_Title :$25. Country :$2.
          Birth_Date :date. Hire_Date :mmddyy.;
   IF     Country='AU';
          /* use subsetting IF statement because the input data
          is a raw data file, not a SAS data set */
   KEEP   First_Name Last_Name Salary
          Job_Title Hire_Date;
          /* include only the needed variables */
   LABEL  Job_Title='Sales Title'
          Hire_Date='Date Hired';
          /* add more descriptive labels*/
   FORMAT Salary dollar12. Hire_Date monyy7.;
          /* format the Numeric variables*/
RUN;
PROC PRINT DATA=work.subset LABEL;
/* add LABEL option to print new labels*/
RUN;


/**************************
4. Reading Instream Data */

/* Reading Instream Data (delimited with blanks) in DATA Step*/
DATA work.newemps;
    /* the Instream Data is delimited with blanks,
    so use an INPUT statement for list input */
    INPUT First_Name $ Last_Name $
         Job_Title $ Salary :dollar8.;

    datalines;
    /* read the Instream Data listed direct bellow */
Steven Worton Auditor $40,450
Merle Hieds Trainee $24,025
Marta Bamberger Manager $32,000
  /* The instream data should be the last part
  of the DATA step except for a null statement.*/
; /* use a null statement ';' to indicate the end of the input data */

PROC PRINT DATA=work.newemps;
RUN;

/* Reading Instream Data (delimited with commas) in DATA Step*/
DATA work.newemps2;
    /* the Instream Data is delimited with commas,
    so use an INFILE statement with DATALINES option and DLM=','  */
    INFILE  datalines DLM=',';
    INPUT   First_Name $ Last_Name $
            Job_Title $ Salary :dollar8.;
    datalines;
Steven,Worton,Auditor,$40450
Merle,Hieds,Trainee,$24025
Marta,Bamberger,Manager,$32000
;
PROC PRINT DATA=work.newemps2;
RUN;


/**************************
5. Validating Data */

/* Reading a Raw Data File That Contains Data Errors */
DATA work.sales4;
   INFILE "&path/sales3inv.csv" DLM=',';
   INPUT  Employee_ID First $ Last $
          Job_Title $ Salary Country $;
RUN;
PROC PRINT DATA=work.sales4;
RUN;
/* When SAS encounters a data error, it prints messages
and a ruler in the log and assigns a missing value
to the affected variable. Then SAS continues processing.*/


/************************************
6. Missing Data */

/* Reading a Raw Data File That Contains Missing Data  */

/* When there are missing data values in a record,
SAS loads the next record to finish the observation,
and writes a note to the log. */
DATA work.contacts;
   LENGTH   Name $ 20 Phone Mobile $ 14;
   INFILE   "&path/phone2.csv" DSD;
   /* use the DSD (delimiter sensitive data) option to correctly read the raw data file */
   /* The DSD option sets the default delimiter to a comma,
   treats consecutive delimiters as missing values,
   and enables SAS to read values with embedded delimiters
   if the value is surrounded by quotation marks*/
   /*  You can use the DLM= option with the DSD option,
   but it is not needed for comma-delimited files.*/

   INPUT Name $ Phone $ Mobile $;
RUN;
PROC PRINT DATA=work.contacts noobs;
RUN;


/* Reading a Raw Data File Using the MISSOVER Option */

/* When some raw data files have records with missing data
at the end of the record, so there are fewer fields in the record
than specified in the INPUT statement.*/

/* DSD option isn’t appropriate because the missing data
isn’t marked by consecutive delimiters.*/

/* Use the MISSOVER option in your INFILE statement
to prevent SAS from loading a new record
when it reaches the end of the current record.*/
/* If SAS reaches the end of a record without finding values
for all fields, variables without values are set to missing.*/

DATA work.contacts2;
   INFILE   "&path/phone.csv" DLM=',' MISSOVER;
            /* use MISSOVER option*/
   INPUT Name $ Phone $ Mobile $;
RUN;
PROC PRINT DATA=contacts2 noobs;
RUN;

/* The variable values can be truncate.
Add a LENGTH statement to our program
to specify the proper lengths for our character variables./

DATA work.contacts2;
   LENGTH Name $ 20 Phone Mobile $ 14;
          /* specify the proper lengths */
   INFILE "&path/phone.csv" DLM=',' MISSOVER;
   INPUT  Name $ Phone $ Mobile $;
RUN;
PROC PRINT DATA=contacts2 noobs;
RUN;

/* --- PRACTICE 1 --- */

/* prices.dat
120265,,,,25
120267,15,15,15,15
120269,20,20,20,20
120270,20,10,5
120271,20,20,20,20 */

DATA work.donations;
    INFILE "&path/phone.csv" DSD MISSOVER;
    /* DLM= option with the DSD option,
    but it is not needed for comma-delimited files.*/

    INPUT EmpID, Q1 Q2 Q3 Q4;
RUN;
PROC PRINT DATA=work.dotation noobs;
RUN;


/* --- PRACTICE 2 --- */

/* prices.dat
210200100009*09JUN2007*31DEC9999*$15.50*$34.70
210200100017*24JAN2007*31DEC9999*$17.80
210200200023*04JUL2007*31DEC9999*$8.25*$19.80
210200600067*27OCT2007*31DEC9999*$28.90
210200600085*28AUG2007*31DEC9999*$17.85*$39.40 */

DATA work.prices;
    *LENGTH  ProductID 12;
    INFILE  "&path/prices.dat" DML="*" MISSOVER;
    INPUT   ProductID
            StartDate :date. EndDate :date.
            UnitCostPrice :dollar.
            UnitSalesPrice :dollar.;
    LABEL   ProductID='Product ID'
            StartDate='Start of Date Range'
            EndDate='End of Date Range'
            UnitCostPrice='Cost Price per Unit'
            UnitSalesPrice='Sales Price per Unit';
    FORMAT  StartDate EndDate MMDDYY10.
            UnitCostPrice UnitSalesPrice 8.2;

RUN;
TITLE '2007 Prices';
PROC PRINT DATA=work.prices noobs LABEL;
RUN;
