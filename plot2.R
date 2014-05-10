# roughly estimating the storage needed for the data with 2M rows,9 variables,
# types of variables 2 character verctors (lets say average 50 in length), 7 numeric values of
# 8 bytes each, and double the total size
#   2 * 2m * (2*50+7*8)
# comes to 624m

# it is assumed that the data file is available in the directory that
# this script is running in and its name is household_power_consumption.txt

# check if the sqldf package needs to be installed,  this package is used for filtering the
# data while reading the data in from a file
if (!require("sqldf", character.only = TRUE)) {
  install.packages("sqldf", dep = TRUE)
}

# load the library
library(sqldf)

# read the head of the file to understand the data
# First column has the date in %d/%m/%Y format and the second column has the time in
# %H:%M%S format,  the rest of them are numeric values

# leave the Date and Time columns as character and read the rest as numeric values
# also use the sqldf package to filter in the rows that correspond to the days we
# are interested in, 1st of Feb and 2nd of Feb of that year
cclasses =  c("character", "character", rep("numeric", 7))
powerData = read.csv.sql("household_power_consumption.txt", "select * from file where Date in ('2/2/2007', '1/2/2007') ", sep=";", colClasses = cclasses, drv="SQLite")

# create a new column ts with the combined value of Date and Time
powerData$ts = strptime(paste(powerData$Date, powerData$Time), "%d/%m/%Y %H:%M:%S")

# open a PNG file and write the plot to it
# Looks like the x label is not needed set it to null
png(file = "plot2.png")
plot(powerData$ts, powerData$Global_active_power, xlab="", ylab="Global Active Power (kilowatts)", type="l")
dev.off()