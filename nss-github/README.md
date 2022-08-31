# Use Github user id as uid on unix systems 

## Get public github users between 2018 and 2020 from BigQuery

Go to https://console.cloud.google.com/bigquery and enter this query and export as CSV 

```
SELECT actor.login, actor.id FROM `githubarchive.year.*`
WHERE _TABLE_SUFFIX BETWEEN '2020' AND '2023' AND
actor.id > 100000
GROUP BY actor.login, actor.id
ORDER BY actor.login
```
