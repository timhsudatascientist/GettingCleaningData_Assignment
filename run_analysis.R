## Filename:run_analysis.R
## Purpose: Project of on the course 'Getting and Cleaning Data' 
##
## Usage: source("run_analysis.R")
##
## Author:  Jennting Timothy Hsu
## Date:    June 22, 2014

## The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. 
## The goal is to prepare tidy data that can be used for later analysis. 
## You will be graded by your peers on a series of yes/no questions related to the project. 
## You will be required to submit: 
##    1) a tidy data set as described below, 
##    2) a link to a Github repository with your script for performing the analysis, and 
##    3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. 
## You should also include a README.md in the repo with your scripts. 
## This repo explains how all of the scripts work and how they are connected.
##
## One of the most exciting areas in all of data science right now is wearable computing 
## - see for example this article 
##    (http://www.insideactivitytracking.com/data-science-activity-tracking-and-the- battle-for-the-worlds-top-sports-brand/). 
## Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. 
## The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 
## A full description is available at the site where the data was obtained:
##    http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
##    (http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
##
## Here are the data for the project:
##    https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
##    (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
## You should create one R script called run_analysis.R that does the following.
##    1. Merges the training and the test sets to create one data set.
##    2. Extracts only the measurements on the mean and standard deviation for each measurement.
##    3. Uses descriptive activity names to name the activities in the data set
##    4. Appropriately labels the data set with descriptive variable names.
##    5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

##--- Read in the training set and test set ---
# library(sqldf)
# library(data.table)
# library(plyr)
# library(stringr)

data.train <- read.csv("./UCI HAR Dataset/train/X_train.txt", header = FALSE, sep = "")
data.train.activity <- read.csv("./UCI HAR Dataset/train/Y_train.txt", header = FALSE, sep = "")
data.train.subject <- read.csv("./UCI HAR Dataset/train/subject_train.txt", header = FALSE, sep = "")
data.test <- read.csv("./UCI HAR Dataset/test/X_test.txt", header = FALSE, sep = "")
data.test.activity <- read.csv("./UCI HAR Dataset/test/Y_test.txt", header = FALSE, sep = "")
data.test.subject <- read.csv("./UCI HAR Dataset/test/subject_test.txt", header = FALSE, sep = "")

data.feature <- read.csv("./UCI HAR Dataset/features.txt", header = FALSE, sep = "")
data.label <- read.csv("./UCI HAR Dataset/activity_labels.txt", header = FALSE, sep = "")
  
##--- Impose the variable names (extract from the second column of 'features.txt') to the training set and test set ---
data.varName <- data.feature[,2]
# data.varName <- gsub("\\()", "", data.varName)

names(data.train) <- data.varName
names(data.test) <- data.varName

##--- Label the activity for each observation ---
data.train.rownames <- c()
for (i in 1:nrow(data.train.activity)){
  for(j in 1:nrow(data.label)){
    if (data.train.activity[i,1] == data.label[j,1]){
      data.train.rownames <- c(data.train.rownames, as.character(data.label[j,2]))
      break
    }
  }
}

data.test.rownames <- c()
for (i in 1:nrow(data.test.activity)){
  for(j in 1:nrow(data.label)){
    if (data.test.activity[i,1] == data.label[j,1]){
      data.test.rownames <- c(data.test.rownames, as.character(data.label[j,2]))
      break
    }
  }
}

attr(data.train, "row.names") <- data.train.rownames
attr(data.test, "row.names") <- data.test.rownames


##--- Merges the labelled training and test sets to create one data set. ---
data.merge <- rbind(data.train, data.test)
data.merge.rownames <- c(data.train.rownames, data.test.rownames)
attr(data.merge, "row.names") <- data.merge.rownames

##--- Extracts only the measurements on the mean and standard deviation for each measurement. ---
##--- The 'data.merge.extract' is appropriately labelled with descriptive variable names and activity labels for observations ---
##--- The data set 'data.merge.extract.sort' is a sort version of the data set 'data.merge.extract'
## Extract indics of columns of data.merge referring to the measurements on the 'mean()' and 'std()'
ind <- sort(c(grep("mean()", names(data.merge), value = FALSE, fixed = TRUE), grep("std()", names(data.merge), value = FALSE, fixed = TRUE)))
data.merge.extract <- data.merge[ , ind]
# data.merge.extract.sort <- data.merge.extract[order(rownames(data.merge.extract), na.last = TRUE, decreasing = FALSE), ]


##--- Creates a second, independent tidy data set with the average of each variable for each activity and each subject ---
## Create a merged data set named 'data.merge.subject' whose row.names are subject IDs associated with variable names
data.merge.extract.subject <- data.merge.extract
data.merge.subject.rownames <- c(data.train.subject[,1], data.test.subject[,1])
attr(data.merge.extract.subject, "row.names") <- data.merge.subject.rownames    # Re-populate the row.names by subject's ID

tidy.rownames.1 <- sort(unique(rownames(data.merge.extract)))
tidy.rownames.2 <- sort(unique(rownames(data.merge.extract.subject)))

## Generate the final tidy data set named 'data.merge.extract.mean.tidy' 
data.merge.extract.mean.tidy <- data.merge.extract
data.merge.extract.mean.tidy <- data.merge.extract.mean.tidy[1:(length(tidy.rownames.1)+length(tidy.rownames.2)), ]
rownames(data.merge.extract.mean.tidy) <- c(tidy.rownames.1, tidy.rownames.2)
data.tidy.rownames <- rownames(data.merge.extract.mean.tidy)

for (i in 1:nrow(data.merge.extract.mean.tidy)){
  data.merge.extract.mean.tidy[, i] <- c(tapply(data.merge.extract[ ,i], rownames(data.merge.extract), mean), tapply(data.merge.extract.subject[ ,i], rownames(data.merge.extract.subject), mean))
}

##--- Output the tidy data set: 'data_output_mean_tidy.txt' ---
write.csv(data.merge.extract.mean.tidy, file = "data_output_mean_tidy.txt", row.names = TRUE)






