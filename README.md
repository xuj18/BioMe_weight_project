# BioMe_weight_project

Note: this R script includes codes to classify different types of weight trajectory. 
However, this is not a program that could run it by itself.
Feel free to copy and modify the script to fit your own dataset.

Please cite "xxxx" if you use any of the R code for weight trajectory classification in your cohort/Biobank

You can plug in your data (replace the your_data dataset, which is a place holder)

Your dataset should be organized in a long format (e.g. ID, annual weight value, calendar year, like the example below)

Individual_ID| AnnualKG| YOMeasure|Other variables
------------ | -------------| -------------| -------------
ID1| 58|2010| etc
ID1 | 64|2012| etc
ID1| 60|2013|etc
ID2| 80|2007|etc
ID2 | 70|2008|etc
ID2| 60| 2009|etc
ID2| 65| 2010|etc

## Stable weight trajectory <h2>

line 4-21 in the R script


## Weight loss trajectory <h2>

line 27-66 in the R script

## Weight gain trajectory <h2>

line 72-94 in the R script

## Weight cycle trajectory <h2>

line 100-794 in the R script
