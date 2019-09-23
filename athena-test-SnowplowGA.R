# sample R connector to Athena DB with Snowplow events generated via Google Analytics plugin collected
# required package to instal AWR.Athena
# connect to Athena
# install.packages("AWR.Athena")
library(AWR.Athena)
require(DBI)
library(tidyverse)
library(lubridate)
# You need AWS API user with proper access to S3 and Athena
# AWS Access Key and Secret should be set via AWS CLI, run "aws configure" from command line
# S3OutputLocation should be taken from your Athena settings        
con <- dbConnect(AWR.Athena::Athena(), region='us-west-2',
                 S3OutputLocation='s3://aws-athena-query-results-518190832416-us-west-2/',
                 Schema='default')
# get list of tables available
dbListTables(con)
#query specific table (all records, SQL statement can be any supported by Athena)
df <- as_tibble(dbGetQuery(con, "Select * from eventsga"))


## reformatting dates to AEST
df <- df %>% mutate(date_time=as.POSIXct(collector_tstamp))
for (i in 1:length(df$date_time)){
        tz(df$date_time[i])<-df$geo_timezone[i]}

## rounding to hours and grouping by hours and show mobile users with ggplot

df1 <- df %>% mutate(date_time_hour=floor_date(date_time, unit="hour")) %>%
        group_by(date_time_hour, dvce_ismobile) 

df1 %>% count (n()) %>%
        ggplot(aes(x=date_time_hour, y=n, color=dvce_ismobile))+
        geom_line()

##
library(xts)
df2 <- df1 %>% ungroup() %>% group_by(date_time_hour) %>% count(n()) %>% select(date_time_hour, n) %>%
        as.data.frame()
rownames(df2) <- df2$date_time_hour
df2 <- df2 %>% select(n) %>% as.xts()
plot(df2, xlab="Date/time", ylab="Hits", main="Website hits", col="blue")

