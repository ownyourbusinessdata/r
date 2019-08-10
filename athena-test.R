# sample R connector to Athena DB with Snowplow events collected
# required package to instal AWR.Athena
# connect to Athena
library(AWR.Athena)
require(DBI)
library(tidyverse)
# You need AWS API user with proper access to S3 and Athena
# AWS Access Key and Secret should be set via AWS CLI, run "aws configure" from command line
# S3OutputLocation should be taken from your Athena settings        
con <- dbConnect(AWR.Athena::Athena(), region='us-west-2',
                 S3OutputLocation='s3://aws-athena-query-results-518190832416-us-west-2/',
                 Schema='default')
# get list of tables available
dbListTables(con)
#query specific table (all records, SQL statement can be any supported by Athena)
df <- as_tibble(dbGetQuery(con, "Select * from events"))

# basic visualization, hits by different browsers

t<- df %>% group_by (br_family) %>% mutate (n=n())%>% 
        select (br_family, n) %>% count() %>% rename(browser=br_family, hits=n) %>% arrange (desc(hits))

t$browser <- as.factor(t$browser)
        

t %>%   ggplot(aes(x="", y=hits, fill=browser))+
        geom_bar(width = 1, stat="identity")+
        coord_polar(theta = "y", start = 0)


## identyfy columns with missed data
## we probably need to improve or tracker or enrichment process to get it

cn <- colnames(df)[1]
n <- length(colnames(df))
m <- nrow(df)
for (i in 1:n){
        cn <- colnames(df[i])
        if (sum(is.na(df[cn]))==m) print(paste0("NA column: ",cn))
        else if (sum(df[cn]=="-")==m) print(paste0("Empty column (-): ",cn))
}
