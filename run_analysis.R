# Down load data source file
data_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url = data_url, destfile = "data_file.zip")
unzip(zipfile = "data_file.zip")

# load libraries
pkg <- c('dplyr')
require(pkg, character.only = T)

# load data attributes names
feat <- read.table(file = "UCI HAR Dataset/features.txt", col.names = c("var_num","var_name"))
y_label <- read.table(file = "UCI HAR Dataset/activity_labels.txt", col.names = c("label_num", "label_name"))

# clean up and make valid colnames
x_names <- feat$var_name %>% 
        gsub("-", x = ., replacement = "_") %>%
        gsub("\\()", x = ., replacement = "") %>%
        gsub(",", x = ., replacement = ".") %>%
        gsub("^t", x = ., replacement = "Time.") %>%
        gsub("^f", x = ., replacement = "Freq.")

# read training and testing data and assign column names
x_train <- read.table(file = "UCI HAR Dataset/train/X_train.txt", col.names = x_names)
x_test <- read.table(file = "UCI HAR Dataset/test/X_test.txt", col.names = x_names)

y_train <- read.table(file = "UCI HAR Dataset/train/y_train.txt", col.names = "activity_num")
y_test <- read.table(file = "UCI HAR Dataset/test/y_test.txt", col.names = "activity_num")

subject_train <- read.table(file = "UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
subject_test <- read.table(file = "UCI HAR Dataset/test/subject_test.txt", col.names = "subject")

# merge the training and testing data sets
x_all <- bind_rows(x_train, x_test)
y_all <- bind_rows(y_train, y_test)
subject_all <- bind_rows(subject_train, subject_test)

# clean up x names and grep only key word mean and standard deviation
target_cols <- x_names %>% 
                grep(pattern = "mean|std", x = . ,ignore.case = T, value = T) %>%
                grep(pattern = "^angle", x = ., invert = T)

# subset x_all using the columns names
x_target <- x_all %>% select(target_cols)

# join labels and y data
y_target <- y_all %>% full_join(y_label, by = c("activity_num" = "label_num")) %>% setNames(c("activity.number", "activity.name"))

# merge X and Y
tidy_data <- bind_cols(y_target, subject_all, x_target)

# summarize data set by subject and activity
tidy_data_summary <- tidy_data %>% group_by(activity.number, activity.name, subject) %>% summarise_all(mean)

# finalize the beautiful codes, and save the data sets
write.table(tidy_data, "tidy_data.txt")
write.table(tidy_data_summary, "tidy_summary.txt")

saveRDS(tidy_data, file = "tidy_data.Rds")
saveRDS(tidy_data_summary, file = "tidy_summary.Rds")
