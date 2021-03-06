# load the library needed
library("data.table")
library("reshape2")

# get the current working directory 
cwd <- getwd()
# url of the datasets
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(url, file.path("cwd", "dataFiles.zip")) # it's a zip file so extract it's files at destination folder

# Load the activity labels and features from activity labels and features text files

activityLabels <- fread(file.path("./dataFiles/", "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path("./dataFiles", "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
#Extracts only the measurements on the mean and standard deviation for each measurement so we will get these name from feature text file.

featuresMeanStd <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresMeanStd, featureNames]
measurements <- gsub('[()]', '', measurements)

# load the train dataset
train <- fread(file.path("./dataFiles", "UCI HAR Dataset/train/X_train.txt"))[, featuresMeanStd, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path("./dataFiles", "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
trainSubjects <- fread(file.path("./dataFiles", "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
# combine all train data frame by column
train <- cbind(trainSubjects, trainActivities, train)

# load the test datasets
test <- fread(file.path("./dataFiles", "UCI HAR Dataset/test/X_test.txt"))[, featuresMeanStd, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path("./dataFiles", "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path("./dataFiles", "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
#combine all test datasets by column
test <- cbind(testSubjects, testActivities, test)

#combine train and test data set by Row
rbind(train, test)

# Convert classLabels to activityName basically. More explicit. 
combined[["Activity"]] <- factor(combined[, Activity]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])

combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)








