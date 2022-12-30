# How Does a Bike-Share Navigate Speedy Success?: A case study of Cyclistic

I created this project as a case study to showcase my abilities in data analysis and visualization. It was developed after completing the Google Data Analytics specialization.

## Description

- I'm a junior data analyst working at Cyclistic, a bike-sharing company in Chicago.
- The marketing team at Cyclistic wants to understand the differences in usage between casual riders and annual members in order to design a new marketing strategy to convert more casual riders into annual members.
- To gain approval for your recommendations, you will need to provide compelling data insights and professional data visualizations to support your ideas.


## About the company (Cyclistic)

- Cyclistic is a bike-sharing program in Chicago with a fleet of over 5,800 bikes and 692 stations.
- Cyclistic offers a range of pricing options, including single-ride passes, full-day passes, and annual memberships. Customers who purchase single-ride or full-day passes are referred to as casual riders, while those who purchase annual memberships are called Cyclistic members.
- Annual members are more profitable for Cyclistic than casual riders, and the marketing team is interested in converting more casual riders into annual members.

## About the Dataset (FitBit Fitness Tracker Data)

We will be using Cyclistic's historical trip data.
- This data is available for download and includes information from the previous 12
months.
- The data was made available by Motivate International Inc. and is licensed for public
use.
- Some of these data:
1. ride id 
2. rideable type 
3. started at 
4. ended at 
5. start station name 
6. end station name –
7. member/casual

### Dependencies

* This project is based on the R programming language.
* To run this project, the following packages are required:
1. tidyverse
2. lubridate
3. ggplot2
4. ggthemes

```r
install.packages("tidyverse")
install.packages("lubridate")
install.packages("ggplot2")
install.packages("ggthemes")

library(tidyverse)
library(lubridate)
library(ggplot2)
library(ggthemes)
```

### Reproduce Analysis and Visualization

- Download the data on your local machine from [here](https://divvy-tripdata.s3.amazonaws.com/index.html)

- Add data location instead of this line of code 
```r
setwd("C:\\Users\\youss\\OneDrive\\Desktop\\Case study #1\\Raw trip data - Copy - Excel")

```

## Results
- A full report detailing the results and high-level insights from the project can be found in the root directory of the project.
- The report is titled "report" and can be accessed from the root directory.
- The report provides a comprehensive overview of the project and its key findings.
- It is intended to give readers a detailed understanding of the project and its results.
- If you are interested in learning more about the project, we recommend reviewing the report in the root directory

## Version History

* 0.1
    * Initial Release