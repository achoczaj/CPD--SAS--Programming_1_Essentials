/****************************************************
Accessing Data cheatsheet - a collection of snippets

from Summary of Lesson 3: Accessing Data
*****************************************************/

/* Lesson 3: Accessing Data */

/* Accessing SAS Libraries */
/* SAS data sets are stored in SAS libraries. A SAS library is a collection
of one or more SAS files that are recognized by SAS. SAS automatically
provides one temporary and at least one permanent SAS library in every SAS session.
Work is a temporary library that is used to store
and access SAS data sets for the duration of the session. 
Sasuser and sashelp are permanent libraries
that are available in every SAS session.
You refer to a SAS library by a library reference name, or libref.
A libref is a shortcut to the physical location of the SAS files. */

/* Using Two-Level Data Set Names */
/* All SAS data sets have a two-level name that consists of
the libref and the data set name, separated by a period.

When a data set is in the temporary work library,
you can optionally use a one-level name.
A one-level name consists of just the data set name, such as newsalesemps.
When you specify a one-level name, SAS assumes that the data set
is stored in the work library. So, work is the default libref.

When the data set is in a permanent library, you must use a two-level name.
Let’s take a look at the following program to further understand
how SAS data sets are named and how you refer to them in code. */

/* 1. Using the LIBNAME Statement */
LIBNAME libref  'SAS-data-set' <options>;

/* Corect libref name follows all three rules for valid librefs.
It has a length of one to eight characters,
it begins with a letter or underscore,
and its remaining characters are letters, numbers, or underscores. */

/* correctly assigns the libref 'myfiles' to a SAS library
in the c:/mysasfiles folder */
LIBNAME myfiles 'c:/mysasfiles';

/*This LIBNAME statement begins with the keyword LIBNAME,
followed by the name of the libref, which is myfiles.
It then specifies the physical location of the library,
in quotation marks, which is c:/mysasfiles. */


/* 2. Accessing a SAS Library */
/*submit a LIBNAME statement to assign the 'orion' libref */
%let path=/dept/dvt/WebDMS/Education/Prg1PracticeFiles;
libname orion "&path";


/* 2.1 Browsing a Library Programmatically */

/* create a report that displays the contents of a SAS library,
you can write a PROC CONTENTS step. */

PROC CONTENTS DATA= libref._ALL_;
/* When you use _ALL_ in the DATA= option,
PROC CONTENTS displays a list of all the SAS files
that are contained in the SAS library. */
RUN;


/* 3. Accessing a Permanent Data Set */
PROC PRINT DATA=... SAS-data set;
RUN;
/* After DATA=, you specify the libref name e.g. 'orion'
as the first part of the two-level data set name.
Then you specify the name of the data set that you want to display.
For example, suppose you know that one of the data sets
is named 'country'.
So you type data=orion.country in your PROC PRINT step
to view the data set. */


/* 4. Changing or Cancelling a Libref */
libname perm 'filepath/myfiles';
proc print data=perm.orders;
   var Order_ID Order_Type Order_Date;
run;

libname perm clear;
/* At the end of the program, another LIBNAME statement
disassociates the perm libref. */


/***********************************
Accessing a SAS Library - snippets*/

/* Replace filepath with the physical location of your practice files.*/
%let path=filepath;
libname orion "&path";

/* Browsing a Library */
proc contents data=orion._all_;
run;
proc contents data=orion._all_ nods;
run;

/* Viewing a Data Set with PROC PRINT */
proc print data=orion.country;
run;

/* Viewing the Descriptor Portion of a Data Set */
proc contents data=orion.sales;
run;
/* Viewing the Data Portion of a SAS Data Set */
proc print data=orion.sales;
run;
