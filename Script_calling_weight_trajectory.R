#R script for calling stable weight, weight gain, weight loss, or weight cycle


###############  stable weight trajectory ##################
############################################################

#get the the maximum and minimum weight per individual first
library(dplyr)
grp<-group_by(your_data,individual_ID)
max_annualKG <-aggregate(annualKG ~ individual_ID, data = your_data, max)
min_annualKG <-aggregate(annualKG ~ individual_ID, data = your_data, min)

#only those whose maximum weight change is <5% from the baseline are classified as having a stable weight
your_data$perc_maxfirst_annualKG <- your_data$max_annualKG/your_data$first_annualKG*100-100
your_data$perc_minfirst_annualKG <- your_data$min_annualKG/your_data$first_annualKG*100-100
#if 5% is used as the cutoff for clinically meaningful weight change
your_data$stable_weight_5 <-ifelse((your_data$perc_maxfirst_annualKG < 5) & (your_data$perc_minfirst_annualKG >-5),1,0)
#if 10% is used as the cutoff for clinically meaningful weight change
your_data$stable_weight_10 <-ifelse((your_data$perc_maxfirst_annualKG < 10) & (your_data$perc_minfirst_annualKG >-10),1,0)

############################################################





#################  Weight loss trajectory ##################
############################################################

#Three criteria to define a weight loss
#either 5% or 10% as the cutoff for clinically meaningful weight change
#(1) the net weight loss from the first to the last annual weight over the measured period was > 0;  

#computing the first and last annual weight
library(data.table)
DT <- as.data.table(your_data)
tmp1<-DT[, .SD[1], by=individual_ID]
tmp2<-DT[, .SD[.N], by=individual_ID]
#SD subset of dataset
#.N is the number of rows in each group 
tmp1 <- as.data.frame(tmp1)
tmp2 <- as.data.frame(tmp2)
tmp1$first_annualKG <-tmp1$annualKG
tmp2$last_annualKG <- tmp2$annualKG

#compute the net change from the first to the last annual weight (in percentage)
your_data$perc_lastfirst_annualKG <-your_data$last_annualKG/your_data$first_annualKG*100-100

#(2) the maximum weight loss from baseline was ≥ 5%; 

#(3) overall the individual had more weight loss than weight gain over time and this was quantified by
#(a) the maximum weight gain from baseline was < 5%,
#or (b) the amount of maximum weight gain from baseline was < 45% of the overall weight change magnitude (maximum - minimum)
#The cutoff of 45% was chosen based on manual visual inspection of the weight trajectory plots among a random group of 100 individuals.
#You can change 45% to other values based on how weight trajectory looks like in your Biobank/cohort

#compute the difference between the maximum and the first annual weights per individual
your_data$diff_maxfirst_annualKG <- your_data$max_annualKG - your_data$first_annualKG 
#compute the difference between the maximum and minimum weights per individual
your_data$diff_maxmin_annualKG <- your_data$max_annualKG - your_data$min_annualKG 

#creating the weight loss trajectory binary variable based on the 3 criteria using either 5% or 10% cutoff
your_data$weight_loss_5 <- ifelse((your_data$perc_lastfirst_annualKG < 0 & your_data$perc_minfirst_annualKG <= -5 & (your_data$perc_maxfirst_annualKG < 5 | (abs(your_data$diff_maxfirst_annualKG) < 0.45*your_data$diff_maxmin_annualKG)) ),1,0)
your_data$weight_loss_10 <- ifelse((your_data$perc_lastfirst_annualKG < 0 & your_data$perc_minfirst_annualKG <= -10 & (your_data$perc_maxfirst_annualKG < 5 | (abs(your_data$diff_maxfirst_annualKG) < 0.45*your_data$diff_maxmin_annualKG)) ),1,0)

############################################################





#################  Weight gain trajectory ##################
############################################################

#Three criteria to define a weight gain
#either 5% or 10% as the cutoff for clinically meaningful weight change
#(1) the net weight gain from the first to the last annual weight over the measured period was > 0;  

#(2) the maximum weight gain from baseline was ≥ 5%; ; 

#(3) overall the individual had more weight gain than weight loss over time and this was quantified by 
#(a) the maximum weight loss from baseline was < 5%, 
#or (b) he amount of maximum weight loss from baseline was < 45% of the overall weight change magnitude (maximum - minimum), 
#The cutoff of 45% was chosen based on manual visual inspection of the weight trajectory plots among a random group of 100 individuals.
#You can change 45% to other values based on how weight trajectory looks like in your Biobank/cohort

#compute the difference between the maximum and the first annual weights per individual
your_data$diff_minfirst_annualKG <- your_data$min_annualKG - your_data$first_annualKG 

#creating the weight gain trajectory binary variable based on the 3 criteria using either 5% or 10% cutoff
your_data$weight_gain_5 <-  ifelse((your_data$perc_lastfirst_annualKG > 0 & your_data$perc_maxfirst_annualKG >= 5 & (your_data$perc_minfirst_annualKG > -5 | (abs(your_data$diff_minfirst_annualKG) < 0.45*your_data$diff_maxmin_annualKG)) ),1,0)
your_data$weight_gain_10 <- ifelse((your_data$perc_lastfirst_annualKG > 0 & your_data$perc_maxfirst_annualKG >= 10  & (your_data$perc_minfirst_annualKG > -5 | (abs(your_data$diff_minfirst_annualKG) < 0.45*your_data$diff_maxmin_annualKG)) ),1,0)

############################################################





#################  Weight cycle trajectory #################
############################################################

#weight cycle was identified through either the (1) local minimum/maximum (2) global minimum/maximum approaches

##### (1) local minimum/maximum  #####
#first, weight changes between each adjacent annual weights need to be computed (i.e., the weight change from ith annual weight to (i+1)th annual weight)
test<- your_data
for (i in 1:dim(your_data)[1]) {
  if (i>1){
  #if it is the same individual, compute the year difference, weight different (in kg or %), and weight change per year between the two adjacent annual weights
    if (test[i,1]==test[i+1,1]) {
      test$year_diff[i+1] <- test$YOMeasure[i+1] - test$YOMeasure[i]
      test$annualKG_diff[i+1] <- test$annualKG[i+1] - test$annualKG[i]
      test$wt_chng_peryear[i+1] <- test$annualKG_diff[i+1]/test$year_diff[i+1]
      test$percdiff_annual[i+1] <- test$annualKG[i+1]/test$annualKG[i]*100-100
    }
  #if it is not the same individual (i.e., change from the last annual weight for jth individual to the first annual weight for the (j+1)th individual), leave the first row as NA for (j+1)th individual, as it has no preceding weight from the same individual to calculate the weight difference
    else if (test[i,1]!=test[i+1,1]) {
      test$year_diff[i+1] <- NA
      test$annualKG_diff[i+1] <- NA
      test$wt_chng_peryear[i+1] <- NA
      test$percdiff_annual[i+1] <- NA
    }
  }
  #for the first annual weight of the first individual in the dataset, leave the first row as NA, and compute the weight difference for the second annual weight (compared to the first annual weight)
  if (i==1){
    test$year_diff[i] <- NA
    test$annualKG_diff[i] <- NA
    test$wt_chng_peryear[i] <- NA
    test$percdiff_annual[i] <- NA
    test$year_diff[i+1] <- test$YOMeasure[i+1] - test$YOMeasure[i]
    test$annualKG_diff[i+1] <- test$annualKG[i+1] - test$annualKG[i]
    test$wt_chng_peryear[i+1] <- test$annualKG_diff[i+1]/test$year_diff[i+1]
    test$percdiff_annual[i+1] <- test$annualKG[i+1]/test$annualKG[i]*100-100
  }
}
your_data <- test


#second, restrict the weight dataset to the first annual weight, last annual weight, and any annual weight(s) in between that is a inflection point (aka, local peak, could be either local minimum or local maximum)
num_individual <- dim(your_data)[1]
num_column <- dim(your_data)[2]
your_data_subset1 <- data.frame(matrix(NA, nrow = num_individual, ncol = num_column))


for (i in 1:dim(your_data)[1]) {
  #if the weight change value (%) between annual weight is not NA or missing
  if ((!is.na(your_data$percdiff_annual[i])) & (!is.na(your_data$percdiff_annual[i+1]))) {
  #keep the local maximum point 
    if ((your_data$percdiff_annual[i] > 0) & (your_data$percdiff_annual[i+1] <= 0)) {
      your_data_subset1[i,] <- your_data[i,]
    }
  #keep the local minimum point
    else if ((your_data$percdiff_annual[i] < 0) & (your_data$percdiff_annual[i+1] >= 0)) {
      your_data_subset1[i,] <- your_data[i,]
    }
  #otherwise, set this row as NA
    else {your_data_subset1[i,] <- your_data_subset1[i,]}
  }
  #keep the first annual weight
  else if (is.na(your_data$percdiff_annual[i])) {
    your_data_subset1[i,] <- your_data[i,]
  }
  #keep the last annual weight
  else if (is.na(your_data$percdiff_annual[i+1])){
    your_data_subset1[i,] <- your_data[i,]
  }
}

your_data_subset1 <- your_data_subset1[which(!is.na(your_data_subset1$annualKG)),]

#using the code above, only the first, local maximum/minimum, and last annual weights per individual were kept
#the rows with NA were removed


#Third, calculating the weight percentage difference between the inflection points (annual weight at inflection point 2 - annual weight at inflection point 1)
#create the % wt change between each turning point
test<-your_data_subset1

for (i in 1:dim(test)[1]) {
  if (i>1){
    #if it is the same individual, compute the weight different (in %) between the two inflection points
    if (test[i,1]==test[i+1,1]){
      test$percdiff_turnpt[i+1] <- test$annualKG[i+1]/test$annualKG[i]*100-100
    }
    #if it is not the same individual (i.e., change from the last annual weight for jth individual to the first annual weight for the (j+1)th individual), leave the first row as NA for (j+1)th individual, as it has no preceding weight from the same individual to calculate the weight difference
    else if (test[i,1]!=test[i+1,1]) {
      test$percdiff_turnpt[i+1] <- NA
    }
  }
  #for the first annual weight of the first individual in the dataset, leave the first row as NA, and compute the weight difference for the first inflection point (compared to the first annual weight)
  if (i==1){
    test$percdiff_turnpt[i] <- NA
    test$percdiff_turnpt[i+1] <- test$annualKG[i+1]/test$annualKG[i]*100-100
  }
}

your_data_subset1 <-test


#Fourth (optional), only if there is any plateau points
#using the codes above, there could be some plateau points kept in the dataset, which we also need to remove (aka, for one inflection point, the annual weight right after it has the same weight value)
num_individual_subset1 <- dim(your_data_subset1)[1]
num_column_subset1 <- dim(your_data_subset1)[2]
your_data_subset2 <- data.frame(matrix(NA, nrow = num_individual_subset1, ncol = num_column_subset1))

for (i in 1:dim(your_data_subset1)[1]) {
  if (i <dim(your_data_subset1)[1]){
  #if it is the first annual weight of an individual, keep it
    if (is.na(your_data_subset1$percdiff_turnpt[i])) {
      your_data_subset2[i,] <- your_data_subset1[i,]
    }
  #for inflection points between the first and last annual weights for each individual
    else {
  #keep if it is truly an inflection point (aka, local maximum)
      if (your_data_subset1$individual_ID[i] == your_data_subset1$individual_ID[i+1]) {
        if (your_data_subset1$percdiff_turnpt[i] > 0 & your_data_subset1$percdiff_turnpt[i+1] < 0 ) {
          your_data_subset2[i,] <- your_data_subset1[i,]
        }
  #keep if it is truly an inflection point (aka, local minimum)
        else if (your_data_subset1$percdiff_turnpt[i] < 0 & your_data_subset1$percdiff_turnpt[i+1] > 0 ) {
          your_data_subset2[i,] <- your_data_subset1[i,]
        }
  #otherwise it is a plateau point and set it to NA 
  #caveat: this may also remove a true inflection point depending on if the weight goes down for a local maximum plateau, or if the weight goes up for a local minimum plateau
  #This is not an issue if the weight keeps going up after a local maximum plateau, or if the weight keeps going down for a local minimum plateau (which is the case for all plateau points in our dataset)
        else {your_data_subset2[i,] <- your_data_subset2[i,]}
      }
  #if it is the last annual weight of an individual, keep it
      else if (your_data_subset1$individual_ID[i]!= your_data_subset1$individual_ID[i+1]) {
        your_data_subset2[i,] <- your_data_subset1[i,]
      }
    }
  }
  else if (i==dim(your_data_subset1)[1]) {
  #if it is the last annual weight of the last individual, keep it
    your_data_subset2[i,] <- your_data_subset1[i,]
  }
}

your_data_subset2 <- your_data_subset2[which(!is.na(your_data_subset2$annualKG)),]
#using the code above, only the first, inflection points, and last annual weights per individual were kept, excluding those plateau points
#the rows with NA were removed


#Fifth (optional), recalculate the weight percentage difference between the corrected inflection points (annual weight at inflection point 2 - annual weight at inflection point 1)
#create the % wt change between each inflection point
test<-your_data_subset2

for (i in 1:dim(your_data_subset2)[1]) {
  if (i>1){
    #if it is the same individual, compute the weight different (in %) between the two inflection points
    if (test[i,1]==test[i+1,1]){
      test$percdiff_turnpt_v2[i+1] <- test$annualKG[i+1]/test$annualKG[i]*100-100
    }
    #if it is not the same individual (i.e., change from the last annual weight for jth individual to the first annual weight for the (j+1)th individual), leave the first row as NA for (j+1)th individual, as it has no preceding weight from the same individual to calculate the weight difference
    else if (test[i,1]!=test[i+1,1]) {
      test$percdiff_turnpt_v2[i+1] <- NA
    }
  }
  #for the first annual weight of the first individual in the dataset, leave the first row as NA, and compute the weight difference for the first inflection point (compared to the first annual weight)
  if (i==1){
    test$percdiff_turnpt_v2[i] <- NA
    test$percdiff_turnpt_v2[i+1] <- test$annualKG[i+1]/test$annualKG[i]*100-100
  }
}

your_data_subset2 <- test

#Sixth, calling clinically meaningful weight change (5% or 10%) between the inflection points

#5% cutoff
for (i in 1:dim(your_data_subset2)[1]){
#if the weight difference is not NA
  if (!is.na(your_data_subset2$percdiff_turnpt_v2[i])) {
  #if the weight change is >= 5% (weight gain), then it is a clinically relevant weight change, marked as 1
    if (your_data_subset2$percdiff_turnpt_v2[i]>=5) {
      your_data_subset2$cutoff_v2[i] <- 1
    }
  #if the weight change is <= -5% (weight loss), then it is also a clinically relevant weight change, marked as 99
    else if (your_data_subset2$percdiff_turnpt_v2[i]<=-5) {
      your_data_subset2$cutoff_v2[i] <- 99
    }
  #otherwise it is not a clinically relevant weight change, marked as 0
    else {your_data_subset2$cutoff_v2[i]  <- 0}
  }
  #if the weight change value is NA, also marked as 0
  else if (is.na(your_data_subset2$percdiff_turnpt_v2[i])) {
    your_data_subset2$cutoff_v2[i]  <- 0
  }
}

#same as above, but with 10% as the cutoff
for (i in 1:dim(your_data_subset2)[1]){
  #if the weight difference is not NA
  if (!is.na(your_data_subset2$percdiff_turnpt_v2[i])) {
    #if the weight change is >= 10% (weight gain), then it is a clinically relevant weight change, marked as 1
    if (your_data_subset2$percdiff_turnpt_v2[i]>=10) {
      your_data_subset2$big_cutoff_v2[i] <- 1
    }
    #if the weight change is <= -10% (weight loss), then it is also a clinically relevant weight change, marked as 99
    else if (your_data_subset2$percdiff_turnpt_v2[i]<=-10) {
      your_data_subset2$big_cutoff_v2[i] <- 99
    }
    #otherwise it is not a clinically relevant weight change, marked as 0
    else {your_data_subset2$big_cutoff_v2[i]  <- 0}
  }
  #if the weight change value is NA, also marked as 0
  else if (is.na(your_data_subset2$percdiff_turnpt_v2[i])) {
    your_data_subset2$big_cutoff_v2[i]  <- 0
  }
}

#Seventh, count the total number of weight changes (>5% or 10%) between inflection points
library(dplyr)
grp1<-group_by(your_data_subset2,ondividual_ID)
wtcycle_index <-as.data.frame(summarise(grp1,sum(cutoff_v2)))
colnames(wtcycle_index)[colnames(wtcycle_index)=="sum(cutoff_v2)"] <- "wtcycle_index_v2"

wtcycle_index_big <-as.data.frame(summarise(grp1,sum(big_cutoff_v2)))
colnames(wtcycle_index_big)[colnames(wtcycle_index_big)=="sum(big_cutoff_v2)"] <- "wtcycle_index_big_v2"

#1 loss, 1 gain = 99 + 1 =100;
#similarly
#101 - 1 loss, 2 gain; 102 - 1 loss, 3 gain; 103 - 1 loss, 4 gain
#199 - 2 loss, 1 gain; 200 - 2 loss, 2 gain; 201 - 2 loss, 3 gain; 202 - 2 loss, 4 gain
#298 - 3 loss, 1 gain, 299 - 3 loss, 2 gain, 300, 3 loss, 3 gain, 301, 3 loss, 4 gain; 302, 3 loss, 5 gain
#397 - 4 loss, 1 gain; 398 - 4 loss, 2 gain; 399 - 4 loss, 3 gain; 400 - 4 loss, 4 gain
#0 - no weight loss or gain
#1,2,3,4 - ranges from 1 weight gain to 4 weight gains
#99, 198, 297, 396 - ranges from 1 weight loss to 4 weight losses


#weight cycle (have both weight gain and loss >= 5%)
#could be either 100,101,102,103,199,200,201,202,298,299,300,301,302,397,398,399,or 400

#need to merge this weight cycle index with your dataset (e.g. your_data)
#each individual will have the same weight cycle index (either 5% or 10%) across all annual weight measures

#after merging the weight cycle index with your original annual weight dataset (e.g. your_data)

#Eighth, identify individuals through the LOCAL maximum/minimum method
#any individuals with these weight cycle index has at least 1 clinically relevant weight gain and 1 clinically relevant weight loss according to their weight cycle index
#thus these are the weight cyclers identified through the local minimum/maximum approach using inflection points
your_data$wtcycle_turnpt_v2 <- ifelse(your_data$wtcycle_index %in% c(100,101,102,103,199,200,201,202,298,299,300,301,302,397,398,399,400),1,0)
your_data$wtcycle_bigturnpt_v2 <- ifelse(your_data$wtcycle_index_big %in% c(100,101,102,103,199,200,201,202,298,299,300,301,302,397,398,399,400),1,0)


##### end of the (1) local minimum/maximum script #####



#########  (2) global minimum/maximum   ###########

#compute the weight cycle using the overall weight change ( weight change % to the global maximum and minimum annual weights per individual, and see if it is >= 5% or 10%)

#To achieve this, we first need to know the time sequence (if the maximum annual KG is before the minimum annual KG, or vice versa)

#get the year of the maximum annual weight 
#some individuals may have the maximum annual weight at multiple time points, and if this is the case, we are interested in getting the year of the first maximum weight here
for (i in 1:dim(your_data)[1]) {
  if (your_data$annualKG[i] == your_data$max_annualKG[i]) {
      your_data$max_annualKG_year[i] <- your_data$YOMeasure[i]
  }
  else {your_data$max_annualKG_year[i] <- NA}
}

#to get the first year of maximum annual weights per individual, first to only keep the rows with maximum annual weights
tmp <- your_data[which(!is.na(your_data$max_annualKG_year)),]
max_annualKG_year <- unique(tmp[,c("individual_ID","max_annualKG_year")])
library(plyr)
ID_max_annualKG_year<-ddply(max_annualKG_year,.(individual_ID),nrow)

for (i in 1:dim(max_annualKG_year)[1]){
  id <- max_annualKG_year[i,1]
  year <- max_annualKG_year$max_annualKG_year[which(max_annualKG_year$individual_ID==id)]
  keep <- which.min(year)
  max_annualKG_year$firstmaxyear[i] <- year[keep]
}

#similarly, to get the year of the minimum annual weight (the first year if there are multiple)
for (i in 1:dim(your_data)[1]) {
  if (your_data$annualKG[i] == your_data$min_annualKG[i]) {
    your_data$min_annualKG_year[i] <- your_data$YOMeasure[i]
  }
  else {your_data$min_annualKG_year[i] <- NA}
}

#to get the first year of the minimum annual weights per individual, first to only keep the rows with the minimum annual weights
tmp <- your_data[which(!is.na(your_data$min_annualKG_year)),]
min_annualKG_year <- unique(tmp[,c("individual_ID","min_annualKG_year")])
library(plyr)
ID_min_annualKG_year<-ddply(min_annualKG_year,.(individual_ID),nrow)

for (i in 1:dim(min_annualKG_year)[1]){
  id <- min_annualKG_year[i,1]
  year <- min_annualKG_year$min_annualKG_year[which(min_annualKG_year$individual_ID==id)]
  keep <- which.min(year)
  min_annualKG_year$firstminyear[i] <- year[keep]
}

#now we get the first year of both maximum annual weight and minimum annual weight, so we can compare which occurred first for each individual

#Next, we also need to compute the second minimum annual weight before/after maximum annual weight and/or second maximum annual weight before/after minimum annual weight
tmp <- your_data
for (i in 1:dim(tmp[1])){
  id <- tmp$individual_ID[i]
  dat <- tmp[which(tmp$individual_ID==id),]
  #when the maximum annual weight occurred before the minimum annual weight
  if (tmp$firstmaxyear[i] < tmp$firstminyear[i]) {
    beforemax <- dat[which(dat$YOMeasure < dat$firstmaxyear),]
    if (dim(beforemax)[1] > 0) {
      #find the second minimum annual weight before the maximum annual weight
      keep1 <- which.min(beforemax$annualKG)
      tmp$second_min_annualKG[i] <- beforemax$annualKG[keep1]
    }
    else {tmp$second_min_annualKG[i] <- NA}
    aftermin <- dat[which(dat$YOMeasure > dat$firstminyear),]
    if (dim(aftermin)[1] > 0) {
      #find the second maximum annual weight after the minimum annual weight
      keep2 <- which.max(aftermin$annualKG)
      tmp$second_max_annualKG[i] <- aftermin$annualKG[keep2]
    }
    else {tmp$second_max_annualKG[i] <- NA}
    #    tmp$max_over_2min [i] <- tmp$max_annualKG[i]/tmp$second_min_annualKG[i]*100-100
    #    tmp$max2_over_min[i] <- tmp$second_max_annualKG[i]/tmp$min_annualKG[i]*100-100
  }
  #when the maximum annual weight occurred after the minimum annual weight
  else if (tmp$firstmaxyear[i] > tmp$firstminyear[i]) {
    beforemin <- dat[which(dat$YOMeasure < dat$firstminyear),]
    if (dim(beforemin)[1] > 0) {
      #find the second maximum annual weight before the minimum annual weight
      keep1 <- which.max(beforemin$annualKG)
      tmp$second_max_annualKG[i] <- beforemin$annualKG[keep1]
    }
    else {tmp$second_max_annualKG[i] <- NA}
    aftermax <- dat[which(dat$YOMeasure > dat$firstmaxyear),]
    if (dim(aftermax)[1] > 0) {
      #find the second minimum annual weight after the maximum annual weight
      keep2 <- which.min(aftermax$annualKG)
      tmp$second_min_annualKG[i] <- aftermax$annualKG[keep2]
    }
    else {tmp$second_min_annualKG[i] <- NA}
    #    tmp$min_over_2max [i] <- tmp$min_annualKG[i]/tmp$second_max_annualKG[i]*100-100
    #    tmp$min2_over_max[i] <- tmp$second_min_annualKG[i]/tmp$max_annualKG[i]*100-100
  }
}

your_data <- tmp

#What if the second minimum or maximum annual weights occurred between the years of maximum and minimum annual weights 
#aka, the first and last annual weights happened to be the maximum and minimum annual weights or vice versa
#compute the 2nd minimum and maximum annual weights in between minimum and maximum annual weights

tmp <- your_data

for (i in 1:dim(tmp)[1]){
  id <- tmp$individual_ID[i]
  dat <- tmp[which(tmp$individual_ID==id),]
  # when the maximum annual weight occurred before the minimum annual weight
  if (tmp$firstmaxyear[i] < tmp$firstminyear[i]) {
    between <- dat[which(dat$YOMeasure > dat$firstmaxyear & dat$YOMeasure < dat$firstminyear),]
    if (dim(between)[1]> 0) {
      #get the second maximum and minimum annual weights and their corresponding years in between the maximum and minimum annual weights
      #which.max or which.min get the row index of the first maximum or minimum values (even if there are multiple maximum or minimum values present)
      keep_max <- which.max(between$annualKG)
      keep_min <- which.min(between$annualKG)
      tmp$between_second_max_annualKG[i] <- between$annualKG[keep_max]
      tmp$between_second_min_annualKG[i] <- between$annualKG[keep_min]
      tmp$between_second_max_annualKG_year[i] <- between$YOMeasure[keep_max]
      tmp$between_second_min_annualKG_year[i] <- between$YOMeasure[keep_min]
    }
    else if (dim(between)[1] == 0) {
      tmp$between_second_max_annualKG[i] <- NA
      tmp$between_second_min_annualKG[i] <- NA
      tmp$between_second_max_annualKG_year[i] <- NA
      tmp$between_second_min_annualKG_year[i] <- NA
    }
  }
  # when the maximum annual weight occurred after the minimum annual weight
  else if (tmp$firstmaxyear[i] > tmp$firstminyear[i]) {
    between <- dat[which(dat$YOMeasure < dat$firstmaxyear & dat$YOMeasure > dat$firstminyear),]
    if (dim(between)[1]> 0) {
      #get the second maximum and minimum annual weights and their corresponding years in between the maximum and minimum annual weights
      keep_max <- which.max(between$annualKG)
      keep_min <- which.min(between$annualKG)
      tmp$between_second_max_annualKG[i] <- between$annualKG[keep_max]
      tmp$between_second_min_annualKG[i] <- between$annualKG[keep_min]
      tmp$between_second_max_annualKG_year[i] <- between$YOMeasure[keep_max]
      tmp$between_second_min_annualKG_year[i] <- between$YOMeasure[keep_min]
    }
    else if (dim(between)[1] == 0) {
      tmp$between_second_max_annualKG[i] <- NA
      tmp$between_second_min_annualKG[i] <- NA
      tmp$between_second_max_annualKG_year[i] <- NA
      tmp$between_second_min_annualKG_year[i] <- NA
    }
  }
}

your_data <- tmp

#so now we get the years of maximum, second maximum, minimum and second minimum annual weights, so we can compare the time sequence of these annual weights for each individual

#Below are the several most common scenarios 

#Situation 1: when max annual KG is before min annual KG
###Situation 1.1: 2nd min -> max -> min
###Situation 1.2: max -> min -> 2nd max
###Situation 1.3: 2nd min -> max  -> min  -> 2nd max
###Situation 1.4: max -> 2nd min -> 2nd max -> min 
#Situation 2: when min annual KG is before max annual KG
###Situation 2.1: 2nd max -> min -> max
###Situation 2.2: min -> max -> 2nd min
###Situation 2.3: 2nd max -> min -> max -> 2nd min
###Situation 2.4: min -> 2nd max -> 2nd min -> max 

#compute the weight change (%) from second maximum or minimum values to minimum or maximum annual weights, or vice versa
# (i) when the second maximum and minimum annual weights are outside the time interval of maximum and minimum annual weights

#when the second maximum annual weight occurred before the minimum annual weight
your_data$min_over_max2<- your_data$min_annualKG/your_data$second_max_annualKG*100-100
#when the second maximum annual weight occurred after the minimum annual weight
your_data$max2_over_min <- your_data$second_max_annualKG/your_data$min_annualKG*100-100
#when the second minimum annual weight occurred after the maximum annual weight
your_data$min2_over_max <- your_data$second_min_annualKG/your_data$max_annualKG*100-100
#when the second minimum annual weight occurred before the maximum annual weight
your_data$max_over_min2 <- your_data$max_annualKG/your_data$second_min_annualKG*100-100


# (ii) when the second maximum and minimum annual weights are within the time interval of maximum and minimum annual weights
#when the second maximum annual weight occurred after the second minimum annual weight
your_data$max2_over_min2 <- your_data$between_second_max_annualKG/your_data$between_second_min_annualKG*100-100
#when the second minimum annual weight occurred after the second maximum annual weight
your_data$min2_over_max2 <- your_data$between_second_min_annualKG/your_data$between_second_max_annualKG*100-100
#when the second maximum annual weight occurred before the minimum annual weight
your_data$between_min_over_max2<- your_data$min_annualKG/your_data$between_second_max_annualKG*100-100
#when the second maximum annual weight occurred after the minimum annual weight
your_data$between_max2_over_min <- your_data$between_second_max_annualKG/your_data$min_annualKG*100-100
#when the second minimum annual weight occurred after the maximum annual weight
your_data$between_min2_over_max <- your_data$between_second_min_annualKG/your_data$max_annualKG*100-100
#when the second minimum annual weight occurred before the maximum annual weight
your_data$between_max_over_min2 <- your_data$max_annualKG/your_data$between_second_min_annualKG*100-100

# (i) model the weight cycle when the second maximum and minimum annual weights are outside the time interval of maximum and minimum annual weights
#compute the wtcycle using max, min and second max/min before or after the max/min values
your_data$perc_maxmin_annualKG <- your_data$max_annualKG/your_data$min_annualKG*100-100
your_data$perc_minmax_annualKG <- your_data$min_annualKG/your_data$max_annualKG*100-100

tmp <- your_data

#5% cutoff
for (i in 1:dim(tmp)[1]) {
  #when the maximum annual weight occurred before the minimum annual weight
  if (tmp$firstmaxyear[i] < tmp$firstminyear[i]) {
    #maximum annual weight is the first annual weight and minimum annual weight is the last annual weight
    if (is.na(tmp$second_min_annualKG[i]) & is.na(tmp$second_max_annualKG[i])) {
      tmp$wtcycle_maxmin_5[i] <- 0
    }
    #Situation 1.1: 2nd min -> max -> min
    else if (!is.na(tmp$second_min_annualKG[i]) & is.na(tmp$second_max_annualKG[i])) {
      if (tmp$max_over_min2[i] >= 5 & tmp$perc_minmax_annualKG[i] <= -5) {
        tmp$wtcycle_maxmin_5[i] <- 1
      }
      else { tmp$wtcycle_maxmin_5[i] <- 0}
    }
    #Situation 1.2: max -> min -> 2nd max
    else if (is.na(tmp$second_min_annualKG[i]) & !is.na(tmp$second_max_annualKG[i])) {
      if (tmp$max2_over_min[i] >= 5 & tmp$perc_minmax_annualKG[i] <= -5) {
        tmp$wtcycle_maxmin_5[i] <- 1
      }
      else {tmp$wtcycle_maxmin_5[i] <- 0}
    }
    #Situation 1.3: 2nd min -> max  -> min  -> 2nd max
    else if (!is.na(tmp$second_min_annualKG[i]) & !is.na(tmp$second_max_annualKG[i])) {
      #if the change from maximum to minimum annual weight was greater than 5%
      #AND any change on either of the two ends (2nd min -> max , or min  -> 2nd max) was greater than 5% in Situation 1.3
      if (tmp$perc_minmax_annualKG[i] <= -5 & (tmp$max2_over_min[i] >= 5 | tmp$max_over_min2[i] >= 5 )) {
        tmp$wtcycle_maxmin_5[i] <- 1
      }
      else {tmp$wtcycle_maxmin_5[i] <- 0}
    }
  }
  #when the maximum annual weight occurred after the minimum annual weight
  else if (tmp$firstmaxyear[i] > tmp$firstminyear[i]) {
    #maximum annual weight is the last annual weight and minimum annual weight is the first annual weight
    if (is.na(tmp$second_min_annualKG[i]) & is.na(tmp$second_max_annualKG[i])) {
      tmp$wtcycle_maxmin_5[i] <- 0
    }
    #Situation 2.1: 2nd max -> min -> max
    else if (is.na(tmp$second_min_annualKG[i]) & !is.na(tmp$second_max_annualKG[i])) {
      if (tmp$min_over_max2[i]  <= -5 & tmp$perc_maxmin_annualKG[i] >= 5) {
        tmp$wtcycle_maxmin_5[i] <- 1
      }
      else {tmp$wtcycle_maxmin_5[i] <- 0}
    }
    #Situation 2.2: min -> max -> 2nd min
    else if (!is.na(tmp$second_min_annualKG[i]) & is.na(tmp$second_max_annualKG[i])) {
      if (tmp$min2_over_max[i] <= -5 & tmp$perc_maxmin_annualKG[i] >= 5) {
        tmp$wtcycle_maxmin_5[i] <- 1
      }
      else { tmp$wtcycle_maxmin_5[i] <- 0}
    }
    #Situation 2.3: 2nd max -> min -> max -> 2nd min
    else if (!is.na(tmp$second_min_annualKG[i]) & !is.na(tmp$second_max_annualKG[i])) {
      #if the change from minimum to maximum annual weight was greater than 5%
      #AND any change on either of the two ends (2nd max -> min , or max -> 2nd min) was greater than 5% in Situation 2.3
      if (tmp$perc_maxmin_annualKG[i] >= 5 & (tmp$min2_over_max[i] <= -5 | tmp$min_over_max2[i] <= -5 )) {
        tmp$wtcycle_maxmin_5[i] <- 1
      }
      else {tmp$wtcycle_maxmin_5[i] <- 0}
    }
  }
}

#10% cutoff
for (i in 1:dim(tmp)[1]) {
  #when the maximum annual weight occurred before the minimum annual weight
  if (tmp$firstmaxyear[i] < tmp$firstminyear[i]) {
    #maximum annual weight is the first annual weight and minimum annual weight is the last annual weight
    if (is.na(tmp$second_min_annualKG[i]) & is.na(tmp$second_max_annualKG[i])) {
      tmp$wtcycle_maxmin_10[i] <- 0
    }
    #Situation 1.1: 2nd min -> max -> min
    else if (!is.na(tmp$second_min_annualKG[i]) & is.na(tmp$second_max_annualKG[i])) {
      if (tmp$max_over_min2[i] >= 10 & tmp$perc_minmax_annualKG[i] <= -10) {
        tmp$wtcycle_maxmin_10[i] <- 1
      }
      else { tmp$wtcycle_maxmin_10[i] <- 0}
    }
    #Situation 1.2: max -> min -> 2nd max
    else if (is.na(tmp$second_min_annualKG[i]) & !is.na(tmp$second_max_annualKG[i])) {
      if (tmp$max2_over_min[i] >= 10 & tmp$perc_minmax_annualKG[i] <= -10) {
        tmp$wtcycle_maxmin_10[i] <- 1
      }
      else {tmp$wtcycle_maxmin_10[i] <- 0}
    }
    #Situation 1.3: 2nd min -> max  -> min  -> 2nd max
    else if (!is.na(tmp$second_min_annualKG[i]) & !is.na(tmp$second_max_annualKG[i])) {
      #if the change from maximum to minimum annual weight was greater than 10%
      #AND any change on either of the two ends (2nd min -> max , or min  -> 2nd max) was greater than 10% in Situation 1.3
      if (tmp$perc_minmax_annualKG[i] <= -10 & (tmp$max2_over_min[i] >= 10 | tmp$max_over_min2[i] >= 10 )) {
        tmp$wtcycle_maxmin_10[i] <- 1
      }
      else {tmp$wtcycle_maxmin_10[i] <- 0}
    }
  }
  #when the maximum annual weight occurred after the minimum annual weight
  else if (tmp$firstmaxyear[i] > tmp$firstminyear[i]) {
    #maximum annual weight is the last annual weight and minimum annual weight is the first annual weight
    if (is.na(tmp$second_min_annualKG[i]) & is.na(tmp$second_max_annualKG[i])) {
      tmp$wtcycle_maxmin_10[i] <- 0
    }
    #Situation 2.1: 2nd max -> min -> max
    else if (is.na(tmp$second_min_annualKG[i]) & !is.na(tmp$second_max_annualKG[i])) {
      if (tmp$min_over_max2[i]  <= -10 & tmp$perc_maxmin_annualKG[i] >= 10) {
        tmp$wtcycle_maxmin_10[i] <- 1
      }
      else {tmp$wtcycle_maxmin_10[i] <- 0}
    }
    #Situation 2.2: min -> max -> 2nd min
    else if (!is.na(tmp$second_min_annualKG[i]) & is.na(tmp$second_max_annualKG[i])) {
      if (tmp$min2_over_max[i] <= -10 & tmp$perc_maxmin_annualKG[i] >= 10) {
        tmp$wtcycle_maxmin_10[i] <- 1
      }
      else { tmp$wtcycle_maxmin_10[i] <- 0}
    }
    #Situation 2.3: 2nd max -> min -> max -> 2nd min
    else if (!is.na(tmp$second_min_annualKG[i]) & !is.na(tmp$second_max_annualKG[i])) {
      #if the change from minimum to maximum annual weight was greater than 10%
      #AND any change on either of the two ends (2nd max -> min , or max -> 2nd min) was greater than 10% in Situation 2.3
      if (tmp$perc_maxmin_annualKG[i] >= 10 & (tmp$min2_over_max[i] <= -10 | tmp$min_over_max2[i] <= -10 )) {
        tmp$wtcycle_maxmin_10[i] <- 1
      }
      else {tmp$wtcycle_maxmin_10[i] <- 0}
    }
  }
}

your_data <- tmp

# (ii) Model the weight cycle using the global maximum/minimum approach when the second maximum and minimum annual weights are within the time interval of maximum and minimum annual weights

tmp <- your_data

#5% cutoff
for (i in 1:dim(tmp)[1]){
  if (!is.na(tmp$between_second_min_annualKG[i])) {
    #when the maximum annual weight occurred before the minimum annual weight
    if (tmp$firstmaxyear[i] < tmp$firstminyear[i]) {
      #Situation 1.4: max -> 2nd min -> 2nd max -> min 
      if (tmp$between_second_min_annualKG_year[i] < tmp$between_second_max_annualKG_year[i]) {
        #if the weight gain and loss were both greater than 5% for this part (max -> 2nd min -> 2nd max) in Situation 1.4
        if ( tmp$between_min2_over_max[i] <= -5 & tmp$max2_over_min2[i] >= 5) {
          tmp$wtcycle_between_5[i] <- 1
        }
        #if the weight gain and loss were both greater than 5% for this part (2nd min -> 2nd max -> min ) in Situation 1.4
        else if ( tmp$max2_over_min2[i] >= 5 & tmp$between_min_over_max2[i] <= -5) {
          tmp$wtcycle_between_5[i] <- 1
        }
        else { tmp$wtcycle_between_5[i] <- 0}
      }
      else {tmp$wtcycle_between_5[i] <- 0}
    }
    #when the maximum annual weight occurred after the minimum annual weight
    else if (tmp$firstmaxyear[i] > tmp$firstminyear[i]) {
      #Situation 2.4: min -> 2nd max -> 2nd min -> max 
      if (tmp$between_second_max_annualKG_year[i] < tmp$between_second_min_annualKG_year[i]) {
        #if the weight gain and loss were both greater than 5% for this part ( min -> 2nd max -> 2nd min) in Situation 2.4
        if ( tmp$between_max2_over_min[i] >=5 & tmp$min2_over_max2[i] <= -5) {
          tmp$wtcycle_between_5[i] <- 1
        }
        #if the weight gain and loss were both greater than 5% for this part ( 2nd max -> 2nd min -> max ) in Situation 2.4
        else if ( tmp$min2_over_max2[i] <= -5 & tmp$between_max_over_min2[i] >= 5) {
          tmp$wtcycle_between_5[i] <- 1
        }
        else { tmp$wtcycle_between_5[i] <- 0}
      }
      else 
      { tmp$wtcycle_between_5[i] <- 0}
    }
  }
  else if (is.na(tmp$between_second_min_annualKG[i])) {
    tmp$wtcycle_between_5[i] <- 0
  }
}


#10% cutoff
for (i in 1:dim(tmp)[1]){
  if (!is.na(tmp$between_second_min_annualKG[i])) {
    #when the maximum annual weight occurred before the minimum annual weight
    if (tmp$firstmaxyear[i] < tmp$firstminyear[i]) {
      #Situation 1.4: max -> 2nd min -> 2nd max -> min 
      if (tmp$between_second_min_annualKG_year[i] < tmp$between_second_max_annualKG_year[i]) {
        #if the weight gain and loss were both greater than 10% for this part (max -> 2nd min -> 2nd max) in Situation 1.4
        if ( tmp$between_min2_over_max[i] <= -10 & tmp$max2_over_min2[i] >= 10) {
          tmp$wtcycle_between_10[i] <- 1
        }
        #if the weight gain and loss were both greater than 10% for this part (2nd min -> 2nd max -> min ) in Situation 1.4
        else if ( tmp$max2_over_min2[i] >= 10 & tmp$between_min_over_max2[i] <= -10) {
          tmp$wtcycle_between_10[i] <- 1
        }
        else { tmp$wtcycle_between_10[i] <- 0}
      }
      else {tmp$wtcycle_between_10[i] <- 0}
    }
    #when the maximum annual weight occurred after the minimum annual weight
    else if (tmp$firstmaxyear[i] > tmp$firstminyear[i]) {
      #Situation 2.4: min -> 2nd max -> 2nd min -> max 
      if (tmp$between_second_max_annualKG_year[i] < tmp$between_second_min_annualKG_year[i]) {
        #if the weight gain and loss were both greater than 10% for this part ( min -> 2nd max -> 2nd min) in Situation 2.4
        if ( tmp$between_max2_over_min[i] >=10 & tmp$min2_over_max2[i] <= -10) {
          tmp$wtcycle_between_10[i] <- 1
        }
        #if the weight gain and loss were both greater than 10% for this part ( 2nd max -> 2nd min -> max ) in Situation 2.4
        else if ( tmp$min2_over_max2[i] <= -10 & tmp$between_max_over_min2[i] >= 10) {
          tmp$wtcycle_between_10[i] <- 1
        }
        else { tmp$wtcycle_between_10[i] <- 0}
      }
      else 
      { tmp$wtcycle_between_10[i] <- 0}
    }
  }
  else if (is.na(tmp$between_second_min_annualKG[i])) {
    tmp$wtcycle_between_10[i] <- 0
  }
}

your_data <- tmp

##### end of the (2) global minimum/maximum #######



### FINALLY, create the weight cycle trajectory binary variable  #####
#if 5% is used as the cutoff for clinically meaningful weight change
for (i in 1:dim(your_data)[1]){
  if (your_data$wtcycle_turnpt_v2[i]==1 | your_data$wtcycle_maxmin_5[i]==1|your_data$wtcycle_between_5[i]==1) {
    your_data$weight_cycle_5[i] <- 1
  }
  else {your_data$weight_cycle_5[i] <- 0}
}

#if 10% is used as the cutoff for clinically meaningful weight change
for (i in 1:dim(your_data)[1]){
  if (your_data$wtcycle_bigturnpt_v2[i]==1 | your_data$wtcycle_maxmin_10[i]==1|your_data$wtcycle_between_10[i]==1) {
    your_data$weight_cycle_10[i] <- 1
  }
  else {your_data$weight_cycle_10[i] <- 0}
}

######### completion of weight cycle classification! ############





#################  Check the summary statistics of each weight trajectory ##################
############################################################################################
table(your_data$stable_weight_5)
table(your_data$stable_weight_10)

table(your_data$weight_loss_5)
table(your_data$weight_loss_10)

table(your_data$weight_gain_5)
table(your_data$weight_gain_10)

table(your_data$weight_cycle_5)
table(your_data$weight_cycle_10)
############################################################################################
