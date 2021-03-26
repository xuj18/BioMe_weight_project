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

**Definition:** Maximum weight change from first annual weight < 5% or 10%.

**Location in the R script:** line 4-21 

## Weight loss trajectory <h2>

**Definition:**
1. The net weight loss over the measured period was > 0
1. The maximum weight loss from baseline was ≥ 5% (or 10%)
1. Overall the individual had more weight loss than weight gain over time 
   1. The maximum weight gain from baseline was < 5%
   1. The amount of maximum weight gain from baseline was < 45% of the overall weight change magnitude (maximum annual weight - minimum annual weight)
   
If any individual meets all three criteria, then he/she had a weight loss trajectory. *To meet the 3rd criteria, either (i) or (ii) works*

**Location in the R script:** line 27-66

## Weight gain trajectory <h2>

**Definition:**
1. The net weight gain over the measured period was > 0
1. The maximum weight gain from baseline was ≥ 5% (or 10%)
1. Overall the individual had more weight gain than weight loss over time 
   1. The maximum weight loss from baseline was < 5%
   1. The amount of maximum weight loss from baseline was < 45% of the overall weight change magnitude (maximum annual weight - minimum annual weight)
   
If any individual meets all three criteria, then he/she had a weight loss trajectory. *To meet the 3rd criteria, either (i) or (ii) works*

**Location in the R script:** line 72-94 

## Weight cycle trajectory <h2>

**Definition:**

**Location in the R script:** line 100-794

