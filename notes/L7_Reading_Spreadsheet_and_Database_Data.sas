/****************************************************
Reading Spreadsheet and Database Data cheatsheet - a collection of snippets

from Summary of Lesson 7: Reading Spreadsheet and Database Data
*****************************************************/

/****************************
1. Reading Spreadsheet Data */

/* Accessing Excel Worksheets in SAS
libname orionx pcfiles path="&path/sales.xls";

proc contents data=orionx._all_;
run;

/* Printing an Excel Worksheet */
proc print data=orionx.'Australia$'n; /* use a SAS name literal when you refer to a worksheet in a program */
run;

proc print data=orionx.'Australia$'n noobs;
   where Job_Title ? 'IV'; /* have 'IV' in Job_Title's values */
   var Employee_ID Last_Name Job_Title Salary;
run;

/* Creating a SAS Data Set from an Excel Worksheet */
libname orionx pcfiles path="&path/sales.xls";

data work.subset;
   set orionx.'Australia$'n;
   where Job_Title contains 'Rep';
   Bonus=Salary*.10;
   label Job_Title='Sales Title'
         Hire_Date='Date Hired';
   format Salary comma10. Hire_Date mmddyy10.
          Bonus comma8.2;
run;

proc contents data=work.subset;
run;

proc print data=work.subset label;
run;

libname orionx clear; 
/* When you assign a libref to an Excel workbook in SAS,
the workbook cannot be opened in Excel.
To disassociate a libref, you submit a LIBNAME statement
specifying the libref and the CLEAR option.
SAS disconnects from the data source and closes any resources
that are associated with the connection.*/
