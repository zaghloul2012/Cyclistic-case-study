# setting working environment
library(tidyverse)
library(lubridate)


# setting working directory
setwd("C:\\Users\\youss\\OneDrive\\Desktop\\Case study #1\\Raw trip data - Copy - Excel")
getwd()


# aggregate all csv files of the last 12 months onto single data frame
df <- list.files("C:\\Users\\youss\\OneDrive\\Desktop\\Case study #1\\Raw trip data - Copy - Excel", pattern = "*.csv") %>%
  lapply(read_csv) %>%
  bind_rows()

# check top observations to get insights about data and get familiarized with it
head(df)

# check structure of data and data types of each column
str(df)

# Check if there are duplicates and remove it if found
raw_observations_count <- nrow(df)
raw_observations_count
df <- df[!duplicated(df$ride_id),]
unique_observations_count <- nrow(df)
removed_observations_count = raw_observations_count - unique_observations_count
print(paste(removed_observations_count, "duplicated row removed"))


# Create new dataframe to add new columns used in analysis
new_df <- df %>%
  mutate(
    
    # add new column "ride_length" to calculate the length of each ride in minutes    
    ride_length_min = as.numeric((ended_at -started_at) / 60),
    
    # add new column "start_hour" to determine which hour in the day the ride started at    
    start_hour = format(started_at, "%H"),
    
    # add new column "day_of_week" to determine the day the ride started at
    day_of_week = wday(started_at, label=TRUE),
    
    # add new column "month" to determine the month the ride started at
    month = month(started_at, label=TRUE),
    
    # add new column "year" to determine the year the ride started at
    year = year(started_at),
  )

# quick summary
summary(new_df)
# The only catching observation here is that there is some negative (invalid ride_length values) that we will deal with later

zero_ride_length <- new_df %>%
  filter(ride_length_min == 0)
View(negative_ride_length)

ggplot(zero_ride_length,
       aes(rideable_type)) +
  geom_bar()
# There are 538 ride with ride_length equals to zero, most of them are in electric bikes so this may be there is some break down in 
# electric bike or may be the user couldn't use it, so these rides will be discarded

negative_ride_length <- new_df %>%
  filter(ride_length_min < 0,
         start_station_id == end_station_id)
nrow(negative_ride_length)
# There are 100 ride with ride_length less than zero, half of them are with same starting and ending station so they may be discarded 
# to the same reason above


new_df <- new_df %>%
  filter(ride_length_min > 0)

# Get number of uniqe values in each column
unique_values <- new_df %>%
  summarise_all(n_distinct)
unique_values
# This is used for some data validations as:
#there are only two types of members in member_casual column
#there are 7 unique values in day_of_week
#there are 24 unique values in hour_of_day


#check if any of the rows have null values
null_values_count <- sapply(new_df, function(x) sum(is.na(x)))
null_values_count
# all null values observations are found in station names which will not affect analysis very much


# Casuals Vs. Members
casual_member_grouped_summary <- new_df %>%
  group_by(member_casual) %>%
  summarize(
    count = n(),
    proportion = 100*(count / nrow(new_df))
  ) 
casual_member_grouped_summary
# It's obvious that members are more than casual at general with difference about 20%, we will check later if this 
#difference is usual in all months or in general 
ggplot(new_df, aes(member_casual, fill=member_casual)) +
  geom_bar() + 
  labs(title = "Casuals Vs. Members")


# Monthly summary
monthly_summary <- new_df %>%
  group_by(month) %>%
  summarise(
    count = n(),
    proportion = 100*count / nrow(new_df)
  )
monthly_summary
# we can observe that count of rides increase dramatically from May to  Oct
ggplot(new_df, aes(month)) + geom_bar()
# This may be due to climate so let's see
# Cyclistic operates in Chicago so we we searched for mean temperatures in Chicago in these months
months <- unique(new_df$month)
chicago_mean_temp_2022 <- data.frame(
  month = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"),
  temp = c(27, 30, 39, 49, 59, 70, 76, 75, 67, 55, 43, 32)
)

ggplot(
  data=chicago_mean_temp_2022,
  aes(x=month, y=temp, group=1, start = "Jan")
       ) +
  geom_col()
cor_month_temp <- cor(monthly_summary$count, chicago_mean_temp_2022$temp)
cor_month_temp
# we can see from both graphs and correlation that this distribution may be due to low temperatures at the start and the end of the year

#Casuals Vs Members Monthly
casual_member_monthly <- new_df %>%
  group_by(month) %>%
  summarise(
    member_count = sum(member_casual == "member"),
    casual_count = sum(member_casual == "casual"),
    member_prop = member_count / (member_count + casual_count),
    casual_prop = casual_count / (member_count + casual_count)
  )
casual_member_monthly
ggplot(new_df,
       aes(x=month, fill=member_casual)
       ) + 
  geom_bar()
#We can see that's the proportion of member are greater than casual in the start and end of year 
# but they are nearly equal in the middle of the year
# This can help us to make the campaign in the middle of the year



# mode function.
get_mode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

# Daily summary
daily_summary <- new_df %>%
  group_by(day_of_week) %>%
  summarise(
    count = n(),
    prop = count / nrow(new_df)
  )
daily_summary
ggplot(new_df,
       aes(x=day_of_week)) + 
  geom_bar()
# we can see that all days are nearly equal with mode = Saturday, this may be due to weekend so more people tend to use it
# This also can help in determining which days we can focus on in campaign


# Casuals Vs Members Daily
casual_member_daily <- new_df %>%
  group_by(day_of_week) %>%
  summarise(
    member_count = sum(member_casual == "member"),
    casual_count = sum(member_casual == "casual"),
    member_prop = member_count / (member_count + casual_count),
    casual_prop = casual_count / (member_count + casual_count)
  )
casual_member_daily
ggplot(new_df,
       aes(x=day_of_week, fill=member_casual)
       ) + 
  geom_bar()
# member rides are always greater than casual rides except for weekends 


# Hourly summary
hourly_summary <- new_df %>%
  group_by(start_hour) %>%
  summarise(
    count = n(),
    prop = count / nrow(new_df)
  )
hourly_summary

ggplot(new_df,
       aes(x=start_hour)) + 
  geom_bar()
# we can see that rush hours are from 15:00 -> 18:00 this due to many people returning back to their homes
# This also will be useful if we wanted to use digital ads poping on bikes 



# Casuals Vs Members Hourly
casual_member_hourly <- new_df %>%
  group_by(start_hour) %>%
  summarise(
    member_count = sum(member_casual == "member"),
    casual_count = sum(member_casual == "casual"),
    member_prop = member_count / (member_count + casual_count),
    casual_prop = casual_count / (member_count + casual_count)
  )
print(casual_member_hourly, n=24)
ggplot(new_df,
       aes(x=start_hour, fill=member_casual)
) + 
  geom_bar()
# usally there is no big difference in rides among members and casuals except in morning this due to members use bikes when they going to their work


# Ride length summary

summary(as.numeric(new_df$ride_length_min))
# we can observe here that minimun ride_length is too small so let's have a big picture with quantiles
ride_length_distribution = quantile(new_df$ride_length_min, probs = seq(0,1,0.05))
ride_length_distribution
ggplot(new_df, 
       aes(x=member_casual, y=ride_length_min)) + 
  geom_boxplot() + 
  scale_y_log10()
# we can observe that there are small proportion of data that may be considered as outliers

q1 <- quantile(new_df$ride_length_min, 0.25)
q3 <- quantile(new_df$ride_length_min, 0.75)
iqr = q3 - q1
lower = q1 - (1.5*iqr)
upper = q3 + (1.5*iqr)

nrow(new_df)
new_df <- new_df %>%
  filter(ride_length_min >= 1 ) %>%
  filter(ride_length_min <=  upper)

ggplot(new_df, 
       aes(x=member_casual, y=ride_length_min)) + 
  geom_boxplot() + 
  scale_y_log10()
# We can quietly work with these data
quantiles = quantile(new_df$ride_length_min, probs = seq(0,1,0.1))
quantiles

ggplot(new_df,
       aes(ride_length_min)) +
  geom_density()
#Distribution of ride_length is nearly normal

# ride_length summary
ride_length_summary <- new_df %>%
  group_by(member_casual) %>%
  summarise(
    min_ride_length = min(ride_length_min),
    mean_ride_length = mean(ride_length_min),
    median_ride_length = median(ride_length_min),
    max_ride_length = max(ride_length_min)
  )
ride_length_summary

ggplot(new_df,
       aes(x=ride_length_min)) + 
  geom_histogram() + 
  facet_wrap(~member_casual)

ggplot(new_df,
       aes(x=ride_length_min, fill=member_casual)) + 
  geom_histogram() + 
  facet_wrap(~month)


# Rideable type summary
rideable_type_summary <- new_df %>%
  group_by(rideable_type) %>%
  summarise(
    count = n(),
    prop = count / nrow(new_df),
  )
rideable_type_summary

# There is no great difference between docked bikes and electric bikes contributing both by about 97%
# This gives us idea about what types of bikes needed in the future in case of scaling

ggplot(new_df,
       aes(x=rideable_type)) + 
  geom_bar()

ggplot(new_df,
       aes(x=rideable_type, fill=member_casual)) + 
  geom_bar()


# 