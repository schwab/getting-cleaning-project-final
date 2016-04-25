# Assignment : Getting and cleaning data course project
# Created by Michael Schwab in the month of April 2016
# * The work submitted for this project is the work of the student who submitted it.

library(dplyr)
library(assertthat)
library(reshape2)
downloadToTmp <- function()
{
  tf <- tempfile()
  uciUrl <-   'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
  #download the zip file to a tmp location (takes a minute or two at 1MB/s)
  download.file(uciUrl,tf)
  tf
}
cleanupTmp <- function(file)
{
  unlink(file)
}
mergeTrainTest <- function(tf)
  {
    
    x_test <-read.table(unz(tf,"UCI HAR Dataset/test/X_test.txt"))
    y_test <- read.table(unz(tf,"UCI HAR Dataset/test/y_test.txt"))
    sub_test <- read.table(unz(tf,"UCI HAR Dataset/test/subject_test.txt"))
    x_train <-read.table(unz(tf,"UCI HAR Dataset/train/X_train.txt"))
    y_train <- read.table(unz(tf,"UCI HAR Dataset/train/y_train.txt"))
    sub_train <- read.table(unz(tf,"UCI HAR Dataset/train/subject_train.txt"))
    features <- read.table(unz(tf,"UCI HAR Dataset/features.txt"))
    activity <- read.table(unz(tf,"UCI HAR Dataset/activity_labels.txt"))
    
    # give activity table some known column names we can use later for merging on
    colnames(activity) <- c("ActivityId","Activity")
    
    # save x col length for use as a limit  later when setting the column names
    xcolnlength <- length(colnames(x_train))
    
    # TEST : verify the column count for x is the same as the number of feature names
    assert_that(length(features[,2]) == xcolnlength)                    
    
    # TEST : verify the y row counts match the x row counts before appending the y values
    assert_that(nrow(x_test) == nrow(y_test))
    assert_that(nrow(x_train) == nrow(y_train))
    
    # Find features with mean or std labels.
    mean_std_labels <- features[grepl("mean|std", features[,2]),2]
    xcolnlength <- length(mean_std_labels)
    
    # 2. Extracts only the measurements on the mean and standard deviation for each measurement.
    x_test_select <- x_test[,mean_std_labels]
    x_train_select <- x_train[,mean_std_labels]
    
    # TEST : we got the correct number of columns for test and train data
    assert_that(length(names(x_test_select)) == length(mean_std_labels))
    assert_that(length(names(x_train_select)) == length(mean_std_labels))
    
    #append the y values to both train and test data
    x_test_select$ActivityId <- as.factor(y_test$V1)
    x_train_select$ActivityId  <- as.factor(y_train$V1)
    x_test_select$Subject <- as.factor(sub_test$V1)
    x_train_select$Subject <- as.factor(sub_train$V1)
    
    # 1. Merges the training and the test sets to create one data set.
    ds <- rbind(x_test_select,x_train_select)
    
    # TEST : verify all rows are appended 
    assert_that(nrow(ds) == nrow(x_test_select) + nrow(x_train_select))
    
    # 4. Appropriately labels the data set with descriptive variable names.
    names(ds) <-mean_std_labels
    names(ds)[xcolnlength + 1] <- "ActivityId"
    names(ds)[xcolnlength + 2 ] <- "Subject"
    
    # TEST :  ds column names appear correct 
    assert_that(colnames(ds)[xcolnlength + 1] == "ActivityId")
    assert_that(colnames(ds)[xcolnlength + 2] == "Subject")
    assert_that(colnames(ds)[1] == mean_std_labels[1])
    assert_that(colnames(ds)[xcolnlength] == mean_std_labels[xcolnlength])
    
    #3. Uses descriptive activity names to name the activities in the data set
    rowsbeforemrege  <- nrow(ds)
    ds <- merge(ds, activity, by="ActivityId")
    assert_that(colnames(ds[xcolnlength + 2]) == "Subject")
    assert_that(colnames(ds[xcolnlength + 3]) == "Activity")
    assert_that(rowsbeforemrege == nrow(ds))
    ds
  
}
tidy_mean <- function(ds)
{
  keyColumns <- c("Activity","Subject","ActivityId")
  valueColumns <- setdiff(names(ds),keyColumns)
  tidy_melt <- melt(ds, id.vars=keyColumns, measure.vars=valueColumns)
  #head(tidy_melt, 1000)
  tidy_avg <- dcast(tidy_melt, Activity + Subject ~ variable,mean)
  tidy_avg
  
}

#####################################################################################
# this step takes the longest but only needs to be run once to download  the data
tf <- downloadToTmp()

# steps 1-4 :  produce the first dataset (see the function for detailed steps)
ds <- mergeTrainTest(tf)
head(ds)

# 5. From the data set in step 4, creates a second, 
# independent tidy data set with the average of each variable for each activity and each subject.
tidy <- tidy_mean(ds)

cleanupTmp()

# save files to the current file's directory
# NOTE : in RStudio BEFORE running, use Session -> Set Working Directory -> To Source File Location
# otherwise I have no idea where these files will end up being saved ;)
#write.table(ds, file ="./working_data.csv", sep = ',', row.name = FALSE)
write.table(tidy, file = "./avg_data.csv", sep=",", row.name = FALSE)

