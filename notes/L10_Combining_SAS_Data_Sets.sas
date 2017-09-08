/****************************************************
Combining SAS Data Sets cheatsheet - a collection of snippets

from Summary of Lesson 10: Combining SAS Data Sets
- concatenate two or more SAS data sets using the SET statement in a DATA step
- rename variables using the RENAME= data set option
- merge SAS data sets one-to-one based on a common variable
- prepare data sets for merging by using the SORT procedure
- merge SAS data sets one-to-many based on a common variable
- control the observations in the output data set by using the IN= data set option
*****************************************************/

/************************
1. Concatenating Data Sets

combine data sets vertically by concatenating
[x1,x2,x3,...,x_n ]
        +
[x1,x2,x3,...,x_n ]
*/

/* 1.1 Concatenating Data Sets
with Different Variables in both Sets */
********** Create Data **********;
DATA empscn;
   INPUT First $ Gender $ Country $;
   DATALINES;
Chang   M   China
Li      M   China
Ming    F   China
;
RUN;
DATA empsjp;
   INPUT First $ Gender $ Country $;
   DATALINES;
Cho     F   Japan
Tomi    M   Japan
;
RUN;
********** Like-Structured Data Sets **********;
DATA empsall2;
    SET empscn empsjp; /* specify multiple data sets,
        SAS combines them into a single data set */
    /* In the combined data set, the observations appear
    in the order in which the data sets are listed
    in the SET statement.*/
RUN;
PROC PRINT DATA=empsall2;
RUN;


/* 1.2 Concatenating Data Sets
with Different Variables in both Sets */
********** Create Data **********;
DATA empscn;
   INPUT First $ Gender $ Country $;
   DATALINES;
Chang   M   China
Li      M   China
Ming    F   China
;
RUN;
DATA empsjp;
   INPUT First $ Gender $ Region $;
   DATALINES;
Cho     F   Japan
Tomi    M   Japan
;
RUN;

/* Do the data sets have variables in common?*/
********** Unlike-Structured Data Sets **********;
DATA empsall2;
    SET empscn empsjp; /* specify multiple data sets,
        SAS combines them into a single data set */
    /* In the combined data set, the observations appear
    in the order in which the data sets are listed
    in the SET statement.*/
RUN;
PROC PRINT DATA=empsall2;
RUN;


/*****************************************************
2. Renaming variables during Concatenating Data Sets*/

/* 2.1 Rename variable using the RENAME= data set option*/
********** Create Data **********;
DATA empscn;
   INPUT First $ Gender $ Country $;
   DATALINES;
Chang   M   China
Li      M   China
Ming    F   China
;
RUN;
DATA empsjp;
   INPUT First $ Gender $ Region $;
   DATALINES;
Cho     F   Japan
Tomi    M   Japan
;
RUN;
DATA empsall2;
    SET empscn
        empsjp(RENAME=(Region=Country));
              /* rename variable 'Region' to match first data SET */

RUN;
PROC PRINT DATA=empsall2;
RUN;

/* 2.2 Rename more variables using the RENAME= data set option*/
DATA empsall2;
    SET empscn(RENAME=(First=Fname Country=Region)) /* rename variables in first set*/
        empsjp(RENAME=(First=Fname)); /* rename variables in first set*/
RUN;
PROC PRINT DATA=empsall2;
RUN;


/**********************
3. Merging Data Sets

combine data sets horizontally by Merging
[x1,x3,...,x_n ] + [x2,x3,...,x_n ]
*/
/* Merging combines observations
from two or more SAS data sets
into a single observation
in a new data set. */

/**********************************
3.1 Merging Data Sets One-to-One */

/* Merging based on the values
of one or more common variables,
a process called match-merging.*/

/* The match-merge was designed
to manipulate sorted data sets. */

/* In a one-to-one relationship, a single observation
in one data set is related to one, and only one,
observation in another data set
based on the values of one or more common variables.
For example, two data sets contain employee
identification numbers for the same group of employees. */

*********Create Data One-to-One*********;
DATA empsau;
   INPUT First $ Gender $ EmpID;
   DATALINES;
Togar   M   121150
Kylie   F   121151
Birin   M   121152
;
RUN;
DATA phoneh;
   INPUT EmpID Phone $15.;
   DATALINES;
121150 +61(2)5555-1793
121151 +61(2)5555-1849
121152 +61(2)5555-1665
;
RUN;
/*What is the relationship between observations in the input data sets?*/
/* Which variable can I use to match-merge these data sets? */
/* Do these data sets have a one-to-one relationship? */
/* How many variables will the new data set empsauh contain? */

********** Default Match-Merge One-to-One**********;
DATA empsauh;
   MERGE empsau phoneh; /* use the MERGE statement, not SET statement*/
   BY EmpID; /* specify the common variable or variables to match */
   /* The both data sets must be sorted by the variables
   listed in the BY statement*/
   /* If needed use PROC SORT to sort the data sets
   by the common variable EmpID*/
RUN;
PROC PRINT DATA=empsauh;
RUN;
/* In this merge every record from both input files
exists in the output file*/

/***************************************************
4. Sorting data with PROC SORT before match-merge */
PROC SORT DATA=orion.employee_payroll
          OUT=work.payroll;
   BY Employee_ID;
RUN;
PROC SORT DATA=orion.employee_addresses
          OUT=work.addresses;
   BY Employee_ID;
RUN;
DATA work.payadd;
	MERGE work.payroll work.addresses;
	BY Employee_ID;
RUN;
PROC PRINT DATA=work.payadd;
   VAR Employee_ID Employee_Name
       Birth_Date Salary;
   FORMAT Birth_Date weekdate.;
RUN;

/************************************
4.1 Match-merge more than two data sets*/
DATA mergedata.emppay;
  MERGE work.reps empinfo.sales empinfo.bonuses;
  BY Emp_ID;
RUN;


/**********************************
5. Merging DATA Sets One-to-Many */

/* In a one-to-many relationship,
a single observation in one data set is related
to one or more observations in another data set.*/
/* In a many-to-one relationship,
multiple observations in one data set are related
to one observation in another data set.*/
/* In a many-to-many relationship,
multiple observations in one data set are related
to multiple observations in another data set.*/

/* Merge Data Sets One-to-Many */
*********Create Data One-to-Many*********;
DATA empsau;
   INPUT First $ Gender $ EmpID;
   DATALINES;
Togar   M   121150
Kylie   F   121151
Birin   M   121152
;
DATA phones;
   INPUT EmpID Type $ Phone $15.;
   DATALINES;
121150 Home +61(2)5555-1793
121150 Work +61(2)5555-1794
121151 Home +61(2)5555-1849
121152 Work +61(2)5555-1850
121152 Home +61(2)5555-1665
121152 Cell +61(2)5555-1666
;
********** One-to-Many Merge **********;
DATA empphones;
   MERGE  phones empsau;
   BY EmpID;
RUN;
PROC PRINT DATA=empphones;
RUN;
/*When you reverse the order of the data sets
in the MERGE statement, the results are the same,
but the order of the variables is different.
SAS performs a many-to-one merge.*/


/* Practice: Using the MERGENOBY Option */
/* MERGENOBY option is used to issue a warning or an error
when a BY statement is omitted from a merge.
Performing a merge without a BY statement
merges the observations based on their positions.
This is almost never done intentionally
and can lead to unexpected results.*/

/*
Value	  Description	                      Default (Y/N)
NOWARN	performs the positional merge 	      Y
        without warning
WARN	  performs the positional merge 	      N
        but writes a warning message
        to the log
ERROR	  writes an error message to the log,   N
        and the DATA step terminates
*/


/*****************************************
6. Match-Merging Data Sets with Non-Matches */

/* Sometimes, the data sets have non-matches.
At least one observation in one of the data sets
is unrelated to any observation in another data set
based on the values of one or more common variables.*/
*********Create Data with Non-Matches*********;
DATA empsau;
   INPUT First $ Gender $ EmpID;
   DATALINES;
Togar   M   121150
Kylie   F   121151
Birin   M   121152
;
RUN;
DATA phonec;
   INPUT EmpID Phone $15.;
   DATALINES;
121150 +61(2)5555-1795
121152 +61(2)5555-1667
121153 +61(2)5555-1348
;
RUN;
********** Match-Merge with Non-Matches**********;
DATA empsauc;
   MERGE empsau phonec;
   BY EmpID;
RUN;
PROC PRINT DATA=empsauc;
RUN;
/* The completed output data set contains
both matches and non-matches.*/


/* 6.1 Selecting Non-Matches from only one data set*/
*********Create Data with Non-Matches*********;
DATA empsau;
   INPUT First $ Gender $ EmpID;
   DATALINES;
Togar   M   121150
Kylie   F   121151
Birin   M   121152
;
RUN;
DATA phonec;
   INPUT EmpID Phone $15.;
   DATALINES;
121150 +61(2)5555-1795
121152 +61(2)5555-1667
121153 +61(2)5555-1348
;
RUN;
********** Select Non-Matches from empsau Only **********;
DATA empsauc2;
   MERGE empsau(IN=Emps)
         phonec(IN=Cell);
         /* use the IN= data set option in a MERGE statement
         to identify which input data sets contributed
         to each observation in your output.*/
         /* SAS creates a temporary numeric variable
         that indicates whether the data set contributed data
         to the current observation.
         The temporary variable has two possible values.
         If the value of the variable is 0, it indicates that
         the data set did not contribute to the current observation.
         If the value of the variable is 1,
         the data set did contribute to the current observation. */
   BY EmpID;

   /* add a subsetting IF statement to your DATA step
   that refers to the variables you created using IN=*/
   IF Emps=1 and Cell=0;
         /* You can select only the matches (=1)
         or only the non-matches (=0)
         for your output data set. */
RUN;
PROC PRINT DATA=empsauc2;
RUN;


********** Select Non-Matches from phonec Only **********;
DATA empsauc3;
   MERGE empsau(IN=Emps)
         phonec(IN=Cell);
         /* use the IN= data set option */
   BY EmpID;

   /* add a subsetting IF statement */
   IF Emps=O and Cell=1;
         /* You can select only the matches (=1)
         or only the non-matches (=0)
         for your output data set. */
RUN;
PROC PRINT DATA=empsauc4;
RUN;

********** Select Only Non-Matches from both data sets **********;
*********************************************************;
DATA empsauc4;
   MERGE empsau(IN=Emps)
         phonec(IN=Cell);
         /* use the IN= data set option */
   BY EmpID;

   /* add a subsetting IF statement */
   IF Emps=O OR Cell=o; /* use OR operator to select
                        non-matches from either data set.*/
RUN;
PROC PRINT DATA=empsauc4;
RUN;


/* 7. Alternate syntax for only matches*/

/*
Standard syntax:        Alternate syntax:
IF Emps=1 and Cell=1;   IF Emps and Cell;
IF Emps=1 and Cell=0;   IF Emps and NOT Cell;
IF Emps=0 and Cell=1;   IF NOT Emps and Cell;
IF Emps=0 or Cell=0;    IF NOT Emps or NOT Cell;
*/

7.1 Create a merged data set that includes only matches */
********** Create Data **********;
DATA empsau;
   INPUT First $ Gender $ EmpID;
   DATALINES;
Togar   M   121150
Kylie   F   121151
Togar   M   121150
Birin   M   121
152
;
RUN;
DATA phonec;
   INPUT EmpID Phone $15.;
   DATALINES;
121150 +61(2)5555-1795
121152 +61(2)5555-1667
121153 +61(2)5555-1348
;
RUN;
********** Select Matches from both data sets ***********;
DATA empsauc5;
   MERGE empsau(IN=Emps)
         phonec(IN=Cell);
         /* use the IN= data set option */
   BY EmpID;
   /* use subsetting IF statement */
   *IF Emps=1 and Cell=1;
   IF Emps and Cell; /* use Alternate syntax */
         /* You can select the matches (true)
         or the non-matches (NOT == FALSE)
         for your output data set. */
RUN;
PROC PRINT DATA=empsauc5;
RUN;

/*--- PRACTICE 2 ---*/
DATA work.allcustomer;
   MERGE work.customer_sort(in=Cust)
         orion.lookup_country
         (rename=(Start=Country
         Label=Country_Name) in=Ctry);
   BY Country;
   KEEP Customer_ID Country Customer_Name
        Country_Name;
   IF Cust=1 and Ctry=1;
RUN;
PROC PRINT DATA=work.allcustomer;
RUN;

/*--- PRACTICE 3 ---*/
/* Practice: Merging and Outputting to Multiple Data Sets */
/*  Match-Merge a sorted version of orion.orders
and orion.staff BY Employee_ID */

/* sort orion.orders BY Employee_ID to create
a new data set, work.orders_sort */
PROC SORT DATA=orion.orders
          OUT=work.orders_sort;
   BY Employee_ID;
RUN;
/*  MERGE orion.staff and work.orders_sort BY Employee_ID
and create two new data sets: work.allorders
and work.noorders */
DATA work.allorders work.noorders;
   MERGE orion.staff(in=Staff)
         work.orders_sort(in=Ord);
   BY Employee_ID;
   IF Ord=1 THEN OUTPUT work.allorders; /* 1st data set*/
   ELSE IF Staff=1 and Ord=0
      THEN OUTPUT work.noorders; /* 2nd data set*/
  /* alternate statement */
      *ELSE OUTPUT work.noorders; *

   KEEP Employee_ID Job_Title Gender
        Order_ID Order_Type Order_Date;
RUN;
TITLE "work.allorders Data Set";
PROC PRINT DATA=work.allorders;
RUN;
TITLE "work.noorders Data Set";
PROC PRINT DATA=work.noorders;
RUN;
TITLE;

****************************************************;
OPTIONS MERGENOBY=WARN MSLEVEL=I;
DATA ONEs TWOs inBOTH NOmatch1 NOmatch2 allRECS NOmatch;
  MERGE ONE(IN=In1) TWO(IN=In2);
  BY ID;
  IF In1=1 then output ONEs;
  IF In2=1 then output TWOs;
  IF (In1=1 and In2=1) then output inBOTH;
  IF (In1=0 and In2=1) then output NOmatch1;
  IF (In1=1 and In2=0) then output NOmatch2;
  IF (In1=1 OR In2=1) then output allRECS;
  IF (In1+In2)=1 then output NOmatch;
RUN;
/*
FILE ONE    FILE TWO
---------   -------------
 ID NAME    ID AGE SEX
---------   -------------
 A01 SUE    A01 58 F
 A02 TOM    A02 20 M
 A05 KAY    A04 47 F
 A10 JIM    A10 11 M

 (3a) FILE ONEs (In1=1)
 -------------------------
 ID NAME AGE SEX
 -------------------------
 A01 SUE 58 F
 A02 TOM 20 M
 A05 KAY .
 A10 JIM 11 M

 (3b) FILE TWOs (In2=1)
 -------------------------
 ID NAME AGE SEX
 -------------------------
 A01 SUE 58 F
 A02 TOM 20 M
 A04 47 F
 A10 JIM 11 M

 (3c) inBOTH(In1=1 & In2=1)
 -------------------------
 ID NAME AGE SEX
 -------------------------
 A01 SUE 58 F
 A02 TOM 20 M
 A10 JIM 11 M

 (3d) FILE NOmatch1
 (In1=0 and In2=1)
 -------------------------
 ID NAME AGE SEX
 -------------------------
 A04 47 F

 (3e) FILE NOmatch2
 (In1=1 & In2=0)
 -------------------------
 ID NAME AGE SEX
 -------------------------
 A05 KAY .

 (3f) FILE allRECS
 (In1=1 OR In2=1)
 -------------------------
 ID NAME AGE SEX
 -------------------------
 A01 SUE 58 F
 A02 TOM 20 M
 A04 47 F
 A05 KAY .
 A10 JIM 11 M

 (3g) FILE NOmatch(In1+In2)
 -------------------------
 ID NAME AGE SEX
 -------------------------
 A04 47 F
 A05 KAY .
