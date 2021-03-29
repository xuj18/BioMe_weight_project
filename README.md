# Weight trajectory classification in a biobank setting

Note: this R script includes codes to classify different types of weight trajectory. 
However, this is not a program that could run it by itself.
Feel free to copy and modify the script to fit your own dataset.

In addition, the PheWAS summary statistics of weight trajectory is included in the tar.gz file

Please cite "xxxx" if you use any of the R code for weight trajectory classification in your cohort/biobank, or if you use the weight trajectory PheWAS summary statistics in your study

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

## Stable weight trajectory 

**Definition:** Maximum weight change from first annual weight < 5% or 10%.

**Location in the R script:** line 4-21 

**Figure illustration** 

The figures below give a cartoon illustration and a real example of what is classified as stable weight trajectory using the 5% cutoff (could be changed to 10%).

![stable_weight_illustration](https://user-images.githubusercontent.com/65192651/112688405-35bbe900-8e4f-11eb-9195-913714def58b.png)

![supl_figure2_stable](https://user-images.githubusercontent.com/65192651/112689715-0ad29480-8e51-11eb-9d7b-13637ea357ef.png)


## Weight loss trajectory 

**Definition:**
1. The net weight loss over the measured period was > 0
1. The maximum weight loss from baseline was ≥ 5% (or 10%)
1. Overall the individual had more weight loss than weight gain over time 
   1. The maximum weight gain from baseline was < 5%
   1. The amount of maximum weight gain from baseline was < 45% of the overall weight change magnitude (maximum annual weight - minimum annual weight)
   
If any individual meets all three criteria, then he/she had a weight loss trajectory. *To meet the 3rd criteria, either (i) or (ii) works*

**Location in the R script:** line 27-66


## Weight gain trajectory 

**Definition:**
1. The net weight gain over the measured period was > 0
1. The maximum weight gain from baseline was ≥ 5% (or 10%)
1. Overall the individual had more weight gain than weight loss over time 
   1. The maximum weight loss from baseline was < 5%
   1. The amount of maximum weight loss from baseline was < 45% of the overall weight change magnitude (maximum annual weight - minimum annual weight)
   
If any individual meets all three criteria, then he/she had a weight gain trajectory. *To meet the 3rd criteria, either (i) or (ii) works*

**Location in the R script:** line 72-94 

## Weight cycle trajectory 

**Definition:**
1. **Local** maximum/minimum approach based on inflection points (R script line: 105-349)
1. **Global** maximum/minimum approach based on maximum and minimum annual weights per individual (R script line: 353-773)
   1. When the maximum and minimum annual weights are **not** both at the two ends of the weight trajectory at the same time (i.e., the first and last annual weights) (R script line: 545-680)
   1. When the maximum and minimum annual weights are at the two ends of the weight trajectory at the same time (i.e., the first and last annual weights) (R script line:682-773)
   
**Location in the R script:** line 100-794

