# Use Github user id as uid on unix systems 

## Get public github users between 2018 and 2020 from BigQuery

Go to https://console.cloud.google.com/bigquery and enter this query and export as CSV github-export.csv

```
SELECT actor.login, actor.id FROM `githubarchive.year.*`
WHERE _TABLE_SUFFIX BETWEEN '2020' AND '2023' AND
actor.id > 100000
GROUP BY actor.login, actor.id
ORDER BY actor.login
```

## convert CSV to redis import and execute import  

create this script `github2redis` on the redis server and upload github-export.csv

```
#! /bin/bash

GHF=$1
RDF=$2

if ! [[ -f "${GHF}" ]]; then
  echo "github user csv file \"${GHF}\" does not exist."
fi

rm -f "${RDF}"
while IFS=, read -r LOGIN ID; do
    echo "SET USER/${LOGIN} ${LOGIN}:x:${ID}:${ID}:${LOGIN}:/:/sbin/nologin" >> "${RDF}"
    echo "SET USER/${ID} ${LOGIN}:x:${ID}:${ID}:${LOGIN}:/:/sbin/nologin" >> "${RDF}"
    echo "SET GROUP/${LOGIN} ${LOGIN}:x:${ID}:${LOGIN}" >> "${RDF}"
    echo "SET GROUP/${ID} ${LOGIN}:x:${ID}:${LOGIN}" >> "${RDF}"
done < "${GHF}"

```

and run it 

```
github2redis github-export.csv redis-import.txt
```

and finally import it to your redis server

```
export REDISCLI_AUTH=xxxxxxxx 
cat redis-import.txt | redis-cli --pipe

```

to use the github user list from the redis database install libnss-redis from here  

* https://github.com/dirkpetersen/libnss-redis
* Use section "Testing with Github users" 