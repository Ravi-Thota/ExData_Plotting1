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

# open a PNG file and write to it
png(file = "plot4.png")
par(mfrow=c(2,2))
with(powerData, {
  plot(ts, Global_active_power, xlab="", ylab="Global active power", type="l")
  
  plot(ts, Voltage, xlab="datetime", ylab="Voltage", type="l")
  
  # legend has no box in the example
  plot(ts, Sub_metering_1, xlab="", ylab="Energy sub metering", type="l")
  lines(ts, Sub_metering_2, col="red", type="l")
  lines(ts, Sub_metering_3, col="blue", type="l")
  legend("topright", lty=c(1,1,1), col=c("black", "red", "blue"), bty="n", legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))
  
  # ylab is the same as the name of the variable
  plot(ts, Global_reactive_power, xlab="datetime", type="l")
})
dev.off()