# sample R connector to Athena DB with Snowplow events collected
# required package to instal AWR.Athena
# connect to Athena
library(AWR.Athena)
require(DBI)
library(tidyverse)

# AWS Access Key and Secret should be set via AWS CLI, run "aws configure" from command line
        
con <- dbConnect(AWR.Athena::Athena(), region='us-west-2',
                 S3OutputLocation='s3://aws-athena-query-results-518190832416-us-west-2/',
                 Schema='default')
dbListTables(con)
df <- as_tibble(dbGetQuery(con, "Select * from events"))

# basic visualization, browsers, hits

t<- df %>% group_by (br_family) %>% mutate (n=n())%>% 
        select (br_family, n) %>% count() %>% rename(browser=br_family, hits=n) %>% arrange (desc(hits))

t$browser <- as.factor(t$browser)
        

t %>%   ggplot(aes(x="", y=hits, fill=browser))+
        geom_bar(width = 1, stat="identity")+
        coord_polar(theta = "y", start = 0)

as.factor(t$browser)
