# Weight trajectory classification in a biobank setting

Note: this R script includes codes to classify different types of weight trajectory. 
However, this is not a program that could run it by itself.
Feel free to copy and modify the script to fit your own dataset.

In addition, the PheWAS summary statistics of weight trajectory is included in the tar.gz file.

Please cite "xxxx" if you use any of the R code for weight trajectory classification in your cohort/biobank, or if you use the weight trajectory PheWAS summary statistics in your study.

You can plug in your own dataset (replace the your_data dataset, which is a place holder) to identify weight trajectory for participants in your study cohort.

Your dataset should be organized in a long format (e.g. ID, annual weight value, calendar year, like the example below).

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

**Definition:** Maximum weight change from first annual weight < 5% or 10%. The cutoff was selected based on previous evidence that a weight change of 5% or more could be clinically relevant [1,2,3].

**Location in the R script:** line 4-21 

**Figure illustration** 

The figures below give a cartoon illustration and a real example of what is classified as stable weight trajectory in the BioMe Biobank using the 5% cutoff (could be changed to 10%). 

The x axis represents time and the y axis is the weight change in percentage over time. [The x axis label could be ignored.]

![stable_weight_illustration](https://user-images.githubusercontent.com/65192651/112688405-35bbe900-8e4f-11eb-9195-913714def58b.png)

![supl figure2 stable](https://user-images.githubusercontent.com/65192651/112895967-cf7fd200-90ab-11eb-9665-a0768d06e013.png)


## Weight loss trajectory 

**Definition:**
1. The net weight loss from the first annual weight to the last annual weight was > 0
1. The maximum weight loss from baseline was ≥ 5% (or 10%)
1. Overall the individual had more weight loss than weight gain over time 
   1. The maximum weight gain from baseline was < 5% (or 10%)
   1. The amount of maximum weight gain from baseline was < 45% of the overall weight change magnitude (maximum annual weight - minimum annual weight)
   
If any individual meets all three criteria, then he/she had a weight loss trajectory. *To meet the 3rd criteria, either (i) or (ii) works*

**Location in the R script:** line 27-66

The figures below give a cartoon illustration and a real example of what is classified as weight loss trajectory in the BioMe Biobank using the 5% cutoff (could be changed to 10%).

The example on the left meets criteria (1), (2) and (3.i), while the example on the right meets criteria (1), (2) and (3.ii). [The x axis label could be ignored.]

![weight_loss_illustration](https://user-images.githubusercontent.com/65192651/112894103-72831c80-90a9-11eb-951b-6e856cc886c1.png)

Below is an example of weight loss trajectory in the BioMe Biobank.

![supl figure2 loss](https://user-images.githubusercontent.com/65192651/112896671-ab70c080-90ac-11eb-8a73-eb74092f9573.png)

## Weight gain trajectory 

**Definition:**
1. The net weight gain from the first annual weight to the last annual weight was > 0
1. The maximum weight gain from baseline was ≥ 5% (or 10%)
1. Overall the individual had more weight gain than weight loss over time 
   1. The maximum weight loss from baseline was < 5% (or 10%)
   1. The amount of maximum weight loss from baseline was < 45% of the overall weight change magnitude (maximum annual weight - minimum annual weight)
   
If any individual meets all three criteria, then he/she had a weight gain trajectory. *To meet the 3rd criteria, either (i) or (ii) works*

**Location in the R script:** line 72-94 

The figures below give a cartoon illustration and a real example of what is classified as weight gain trajectory in the BioMe Biobank using the 5% cutoff (could be changed to 10%).

The example on the left meets criteria (1), (2) and (3.i), while the example on the right meets criteria (1), (2) and (3.ii). [The x axis label could be ignored.]

![weight_gain_illustration](https://user-images.githubusercontent.com/65192651/112894362-c68e0100-90a9-11eb-8688-365e627cfd26.png)

Below is an example of weight gain trajectory in the BioMe Biobank.

![supl figure2 gain](https://user-images.githubusercontent.com/65192651/112896723-baf00980-90ac-11eb-8733-3f980e92006b.png)

## Weight cycle trajectory 

**Definition:**
1. **Local** maximum/minimum approach based on inflection points (R script line: 105-349)
1. **Global** maximum/minimum approach based on maximum and minimum annual weights per individual (R script line: 353-773)
   1. When the maximum and minimum annual weights are **not** both at the two ends of the weight trajectory at the same time (i.e., the first and last annual weights) (R script line: 545-680)
   1. When the maximum and minimum annual weights are at the two ends of the weight trajectory at the same time (i.e., the first and last annual weights) (R script line:682-773)
   
**Location in the R script:** line 100-794

Below is an example that meets the local weight cycle definition (there is at least one weight gain and one weight loss change ≥ 5% between inflection points). 
The inflection point was identified based on the slopes (i.e., a positive slope followed by a negative slope, or vice versa).

![local_weight_cycle_illustration](https://user-images.githubusercontent.com/65192651/112903631-c8f65800-90b5-11eb-8d73-8f41ac9f9092.png)

Below is an example that meets the first global weight cycle definition (e.g., maximum weight is not at the two ends of the weight trajectory).
1. Maximum annual weight/first annual weight ≥ 5%
1. Minimum annual weight/maximum annual weight ≤ -5%
1. This does not meet the local weight cycle criteria as none of the weight changes between inflection points reached 5%

![global_weight_cycle_illustration_1](https://user-images.githubusercontent.com/65192651/112903624-c693fe00-90b5-11eb-8199-7c7f2ecad235.png)

And below is an example that meets the second global weight cycle definition (i.e., maximum and minimum annual weights are at the two ends of the weight trajectory)
1. Second maximum annual weight/minimum annual weight ≥ 5%
1. Second minimum annual weight/second maximum annual weight ≤ -5%
1. Maximum annual weight/second minimum annual weight ≥ 5%
1. This does not meet the local weight cycle criteria because even though some weight gain changes between inflection points reached 5%, none of the weight loss between inflection points reached 5%.

![global_weight_cycle_illustration_2](https://user-images.githubusercontent.com/65192651/112902774-a3b51a00-90b4-11eb-969c-86040fde7f90.png)



## QC before identifying the weight trajectory for each individual

![Weight_trajectory_QC_flow](https://user-images.githubusercontent.com/65192651/112904711-54bcb400-90b7-11eb-81d4-ac64c7415bb3.png)

## Additional notes

### How to calculate weight changes in between inflection points if there is a plateau?
We kept the first plateau point as an inflection point candidate and removed the second plateau point. 
If the first plateau point turned out not to satisfy the inflection point definition above in (2), 
we then removed the first plateau point out of the set of inflection points and recalculated the weight changes between the new set of inflection points along with the first and last annual weight measures.

![removal_plateau_points](https://user-images.githubusercontent.com/65192651/112904824-8766ac80-90b7-11eb-8c84-803c43ce08ae.png)


## Reference
1. Stevens J, Truesdale KP, McClain JE, Cai J. The definition of weight maintenance. International Journal of Obesity 2006; 30: 391–9.
1. Blair SN, Shaten J, Brownell K, Collins G, Lissner L. Body weight change, all-cause mortality, and cause-specific mortality in the Multiple Risk Factor Intervention Trial. Ann Intern Med 1993; 119: 749–57.
1. French SA, Folsom AR, Jeffery RW, Zheng W, Mink PJ, Baxter JE. Weight variability and incident disease in older women: the Iowa Women’s Health Study. International Journal of Obesity 1997; 21: 217–23.


