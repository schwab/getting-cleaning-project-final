# gettting-cleaning-project-final
Final project for the Getting and Cleaning Data course for mschwab

## The Process
The project prepares a simple statistical mean analysis of smart phone data collected when test subjects wore their smart phones while doing various activities. To produce the summary data a script is provided which performs all the steps required to extract, load and transform the source into a tidy set with the expected fields.  See the CodeBook.md for more information on the source data fields and their relationship to the tidy data.  The results of this script is saved in *avg_data.csv*.  When run the script will also produce an intermediate data set called *working_data.csv* which shows the data just before it is summarized by the mean function.  This intermediate file is not included in the uploaded source due to its size.

## Transformation details

*run_analysis.R* performs the following functions:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
  * WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING
4. Appropriately labels the data set with descriptive activity names.
  * Subject, Activity + the 79 std and mean columns
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
  * This tidy data set is saved as *avg_data.csv*

## The script *run_analysis.R* implements the above steps in the following manner:

### Require *dplyr* , *reshape2* and *assertthat* libraries.

* Downloads the source data from the location mentioned above (as a zip file) into a tmp folder via the function *downloadToTmp*
* Load test and train data including all measurements, the observed activity and the subject identification data via the function *mergeTrainTest*
* Load the features and activity labels 
  ** append the observations (y data) column
  ** append the subject column
* Extract the mean and standard deviation column names and data via the function "tidy_mean".
  ** uses grepl on the column names to filter columns which do not have mean or std in their names
  ** Process the data. (using melt and dcast)
* Saves the intermediate dataset *working_data.csv*
* Saves the mean data to *avg_data.csv*
