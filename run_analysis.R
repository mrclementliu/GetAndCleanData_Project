# Loading the dplyr package to enable the use of "inner_join" later in the code
library(dplyr)

# Checks whether the "data" folder is in current directory.
# If it is, then the code is skipped.
# If it is not, then it creates the "data" folder, downloads the file into the folder,
# and then unzips the file into the folder with name "project_data".

if(!file.exists("./data")) 
{
  dir.create("./data")
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl, destfile="./data/HAR_Dataset.zip")
  unzip("./data/HAR_Dataset.zip", exdir = "project_data")
}

# Read files to variables
subjecttest <- read.table("./project_data/UCI HAR Dataset/test/subject_test.txt")
xtest <- read.table("./project_data/UCI HAR Dataset/test/X_test.txt")
ytest <- read.table("./project_data/UCI HAR Dataset/test/y_test.txt")
subjecttrain <- read.table("./project_data/UCI HAR Dataset/train/subject_train.txt")
xtrain <- read.table("./project_data/UCI HAR Dataset/train/X_train.txt")
ytrain <- read.table("./project_data/UCI HAR Dataset/train/y_train.txt")
activitylabels <- read.table("./project_data/UCI HAR Dataset/activity_labels.txt")
features <- read.table("./project_data/UCI HAR Dataset/features.txt")

# Rename dataset columns to the features
colnames(xtest) <- features$V2
colnames(xtrain) <- features$V2

# Add column to identify subject
xtest$subject <- subjecttest$V1
xtrain$subject <- subjecttrain$V1

# Link labels to the activity labels
ytrain <- left_join(ytrain, activitylabels, by="V1")
colnames(ytrain) <- c("class_label", "activity_name")
ytest <- left_join(ytest, activitylabels, by="V1")
colnames(ytest) <- c("class_label", "activity_name")

# Create master dataset
xtest <- cbind(xtest, ytest)
xtrain <- cbind(xtrain, ytrain)
project_data <- rbind(xtest, xtrain)

# Subsetting to only "mean" and "std"
meanstd <- project_data[,c(grepl("mean\\(\\)|std\\(\\)|subject|activity_name", 
                                 colnames(project_data), ignore.case=T))]

# Rename variables to be more descriptive
colnames(meanstd)[1:66] <- sub("^t","Time",colnames(meanstd)[1:66]) 
colnames(meanstd)[1:66] <- sub("^f","Freq",colnames(meanstd)[1:66]) 
colnames(meanstd)[1:66] <- sub("mean", "Mean", colnames(meanstd)[1:66])
colnames(meanstd)[1:66] <- sub("std", "STD", colnames(meanstd)[1:66])
colnames(meanstd)[1:66] <- sub("\\(","", colnames(meanstd[1:66]))
colnames(meanstd)[1:66] <- sub("\\)","", colnames(meanstd[1:66]))
colnames(meanstd)[1:66] <- sub("X$","_X", colnames(meanstd[1:66]))
colnames(meanstd)[1:66] <- sub("Y$","_Y", colnames(meanstd[1:66]))
colnames(meanstd)[1:66] <- sub("Z$","_Z", colnames(meanstd[1:66]))
colnames(meanstd)[1:66] <- gsub("\\-","", colnames(meanstd[1:66]))
colnames(meanstd)[1:66] <- sub("BodyBody","Body", colnames(meanstd[1:66]))

# Group the variables by subject and activiity_name then find the means for each observation
by_act_subj <- group_by(meanstd, subject, activity_name)
tidydata <- summarize_each(by_act_subj, funs(mean))

# Write the data into "tidydata.txt" for output
write.table(tidydata, "tidydata.txt", row.names = FALSE)
