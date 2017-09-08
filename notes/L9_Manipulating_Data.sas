/****************************************************
Manipulating Data cheatsheet - a collection of snippets

from Summary of Lesson 9: Manipulating Data
- create data values using SAS functions
- process data conditionally using IF-THEN/ELSE statements
- assign values to variables conditionally
- execute multiple statements conditionally using DO and END statements
- control the length of character variables using the LENGTH statement
*****************************************************/


/************************
1. Using SAS Functions */

/* Creating Variables by Using Functions */
DATA WORK.comp;
    SET orion.sales;
    Bonus=500; /* create a numeric constant variable */

    * Compensation=Salary+Bonus; /*opt1 - calculate value*/
    /* If one of these variables contains a missing value,
    the expression evaluates to missing,
    and a missing value is assigned to Compensation. */

    Compensation=SUM(Salary,Bonus); /*opt2 - use SAS sum function */
    /* The SUM function ignores missing values,
    so if an argument has a missing value,
    the result of the SUM function
    is the sum of the nonmissing values.*/

    BonusMonth=MONTH(Hire_Date); /* use SAS-date function*/
    /*  the MONTH function extracts the month of hire from Hire_Date
    and returns a number from 1 to 12. */
RUN;

/* SAS-date functions
date function:      value extracted:    value returned:
YEAR(SAS-date)      the year            a four-digit year
QTR(SAS-date)       the quarter         a num: 1 to 4
MONTH(SAS-date)     the month           a num: 1 to 12
DAY(SAS-date)       the day of M        a num: 1 to 31
WEEKDAY(SAS-date)   the day of W        a num: 1 to 7
                                        1=SUN, 2=MON,...
TODAY(), DATE() returns the current date
MDY(month,day,year) r. a date with numeric month, day, year
*/

PROC PRINT DATA=work.comp;
   VAR Employee_ID First_Name Last_Name
       Salary Bonus Compensation BonusMonth;
RUN;


/* Add a DROP statement to remove columns*/

/* The DROP statement is a compile-time-only statement.
SAS sets a drop flag for the dropped variables,
but the variables are in the PDV and, therefore,
are available for processing.*/

data work.comp;
   set orion.sales;
   DROP Gender Salary /* can drop Salary, even I use it
                        to calculate Compensation var*/
        Job_Title Country
        Birth_Date Hire_Date;
   Bonus=500;
   Compensation=sum(Salary,Bonus);
   BonusMonth=month(Hire_Date);
run;
PROC PRINT DATA=work.comp;
   VAR Employee_ID First_Name Last_Name
       Bonus Compensation BonusMonth;
RUN;

/*---PRACTICE 1---*/
DATA work.increase;
    SET   orion.staff;
    KEEP  Employee_ID Salary Birth_Date
          Increase NewSalary BdayQtr;
    Increase=Salary*0.1;
    NewSalary=SUM(Salary,Increase);
    BdayQtr=QTR(Birth_Date);

    FORMAT Salary Increase NewSalary comma8.;
          /*permanent format to display with commas */
RUN;
PROC PRINT DATA=work.increase LABEL noobs;
RUN;

/*---PRACTICE 2---*/
DATA work.birthday;
    SET   orion.customer;
    KEEP  Customer_Name Birth_Date Bday2012
          BdayDOW2012 Age2012;

    Bday2012=MDY(MONTH(Birth_Date),DAY(Birth_Date),2012);
    BdayDOW2012=WEEKDAY(Bday2012); /* day of the week of Bday2012*/
    Age2012=(Bday2012-Birth_Date)/365.25;

    FORMAT Bday2012 date9.
           Age2012 3. ;
          /* formats: date9. == e.g.09JUL2012, 3. == e.g.102 */
RUN;
PROC PRINT DATA=work.birthday noobs;
RUN;

/*---PRACTICE 3---*/
/* Practice: Using the CATX and INTCK Functions
to Create Variables*/
data work.employees;
   set orion.sales;
   FullName=catx(' ',First_Name,Last_Name);
   /*use the CATX function to create the new variable FullName,
   which is the combination of First_Name, a space,
   and Last_Name*/

   Yrs2012=intck('year',Hire_Date,'01JAN2012'd);
   /*use the INTCK function to create the new variable Yrs2012,
   which is the number of years between January 1, 2012,
   and Hire_Date*/

   FORMAT Hire_Date ddmmyy10.; /*date with a two-digit day, two-digit month, and a four-digit year*/
   LABEL Yrs2012='Years of Employment in 2012';
run;
PROC PRINT DATA=work.employees label;
   VAR FullName Hire_Date Yrs2012;
run;

/***************************
2. Conditional Processing */

/* 2.1 Assigning Values Conditionally  */
/* conditions are mutually exclusive, so only one condition can be true*/
DATA WORK.comp;
   SET orion.sales;
   IF Job_Title='Sales Rep. IV' THEN
      Bonus=1000;
   IF Job_Title='Sales Manager' THEN
      Bonus=1500;
   IF Job_Title='Senior Sales Manager' THEN
      Bonus=2000;
   IF Job_Title='Chief Sales Officer' THEN
      Bonus=2500;
RUN;
PROC PRINT DATA=work.comp;
   VAR Last_Name Job_Title Bonus;
RUN;

/* 2.2 Using ELSE IF and Compound Conditions */
DATA WORK.comp;
   SET orion.sales;
   IF Job_Title='Sales Rep. III' or
      Job_Title='Sales Rep. IV' THEN
      Bonus=1000;
   ELSE IF Job_Title='Sales Manager' THEN
      Bonus=1500;
   ELSE IF Job_Title='Senior Sales Manager' THEN
      Bonus=2000;
   ELSE IF Job_Title='Chief Sales Officer' THEN
      Bonus=2500;
   ELSE Bonus=500; /* final option*/
RUN;

PROC PRINT DATA=work.comp;
   VAR Last_Name Job_Title Bonus;
RUN;


/***************************
3. Assign values to variables conditionally */

/* 3.1 Using IF-THEN/ELSE Statements */
DATA WORK.bonus;
   SET orion.sales;
   IF Country='US' THEN Bonus=500;
   ELSE Bonus=300;
RUN;
PROC PRINT DATA=work.bonus;
   VAR First_Name Last_Name Country Bonus;
RUN;

/* 3.2 Solving a problem of 'US' and 'us' codes in the data set */
DATA WORK.bonus;
   SET orion.sales;
   * IF Country='US' or 'us' THEN Bonus=500;
   /*opt1 - add both version of Country code*/
   * IF Country IN ('US', 'Us', 'us') THEN Bonus=500;
   /*opt2 - use the IN operator and all versions of Country code*/
   IF UPCASE(Country)='US' THEN Bonus=500;
   /*opt3 - use the UPCASE function to convert
   all letters in an argument to uppercase*/
   /* opt4 - clean the data before checking the value in your IF-THEN*/
   * Country=UPCASE(Country);
   * IF Country='US' or 'us' THEN Bonus=500;

   ELSE Bonus=300;
RUN;
PROC PRINT DATA=work.bonus;
   VAR First_Name Last_Name Country Bonus;
RUN;


/********************************************************
4. Creating Two Variables Conditionally with a DO group*/

/* 4.1 Assign values to two or more variables based on one condition*/
/*  The IF-THEN/ELSE statements allow for only one executable statement.*/
DATA WORK.bonus;
   SET orion.sales;
   IF Country='US' THEN
      DO;  /*use a DO group for multiple executable statements*/
         Bonus=500;
         Freq='Once a Year';
      END; /*use a END to close a DO group */
   ELSE IF Country='AU' THEN
      DO;
         Bonus=300; /*create 'deduced by SAS' a standard numeric variable (8 bytes) */
         Freq='Twice a Year'; /*create 'deduced by SAS' a standard character variable
                              (with a length of first value -
                              here: 'Once a Year' = 11 characters)
                              It will be too small for next string 'Twice a Year' (12) */
      END;
RUN;
PROC PRINT DATA=work.bonus;
   VAR First_Name Last_Name Country Bonus Freq;
RUN;


/**************************
5. Adjusting the Program to avoid values be truncated*/

/* 5.1 Control the length of character variables using the LENGTH statement*/
DATA WORK.bonus;
   SET orion.sales;
   LENGTH Freq $ 12; /* declare the byte size of a character variable (12 char) -*/
   IF Country='US' THEN
      do;
         Bonus=500;
         Freq='Once a Year';
      end;
   ELSE IF Country='AU' THEN
      do;
         Bonus=300;
         Freq='Twice a Year';
      end;
RUN;
/* In the DATA step, the first reference to a variable determines its length.
The first reference to a new variable can be in a LENGTH statement,
an assignment statement, or another statement such as an INPUT statement.
After a variable is created in the PDV, the length of the variable's first value
doesn't matter.*/
PROC PRINT DATA=work.bonus;
   VAR First_Name Last_Name Country Bonus Freq;
RUN;

/* 5.2 Set variables' values also for all OTHER CASES*/
DATA WORK.bonus;
   SET orion.sales;
   LENGTH Freq $ 12;
   IF Country='US' THEN
      do;
         Bonus=500;
         Freq='Once a Year';
      end;
   ELSE do; /* set this values for all OTHER CASES */
         Bonus=300;
         Freq='Twice a Year';
      end;
RUN;
PROC PRINT DATA=work.bonus;
   VAR First_Name Last_Name Country
       Bonus Freq;
RUN;

/*--- PRACTICE 2 ---*/
DATA work.season;
   SET orion.customer_dim;
   LENGTH Promo2 $ 6; /* declare the size of a character variable*/
   Quarter=qtr(Customer_BirthDate);
   IF Quarter=1 then Promo='Winter';
   else IF Quarter=2 then Promo='Spring';
   else IF Quarter=3 then Promo='Summer';
   else IF Quarter=4 then Promo='Fall';
   IF Customer_Age>=18 and Customer_Age<=25
      THEN Promo2='YA';
   ELSE IF Customer_Age>=65
      THEN Promo2='Senior';
   /* Promo2 should have a missing value
   for all other customers*/

   keep Customer_FirstName Customer_LastName
        Customer_BirthDate Customer_Age
        Promo Promo2;
RUN;

PROC PRINT DATA=work.season;
   VAR Customer_FirstName Customer_LastName
       Customer_BirthDate Promo
       Customer_Age Promo2;
run;

/*--- PRACTICE 3 ---*/
/* Practice: Using WHEN Statements in a SELECT Group
to Create Variables Conditionally */

/* The SELECT statement executes one of several statements
or groups of statements. The SELECT statement begins a SELECT group.
SELECT groups contain WHEN statements that identify SAS statements
that are executed when a particular condition is true.
Use at least one WHEN statement in a SELECT group.
An optional OTHERWISE statement specifies a statement to be executed
if no WHEN condition is met. An END statement ends a SELECT group. */

DATA work.gifts;
   SET orion.nonsales;
   LENGTH Gift1 $ 6 Gift2 $ 10; /* declare the sizes of character variables*/
   SELECT(Gender);
      WHEN('F') do;
         Gift1='Scarf';
         Gift2='Pedometer';
      END;
      WHEN('M') do;
         Gift1='Gloves';
         Gift2='Money Clip';
      END;
      OTHERWISE DO;
         Gift1='Coffee';
         Gift2='Calendar';
      END;
      END;
RUN;
PROC PRINT DATA=work.gifts noobs;
  VAR Employee_ID	First	Last	Gender	Gift1	Gift2;
RUN;
