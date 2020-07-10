# Circle Reports
`circlereports` is a Ruby gem that runs on your local machine. It generates reports on the builds of a named branch from our `rails-api` repository.

Each report covers 7 days starting on the `--start` date provided.

## Installation
To install (until we have a gem server), clone the github repository, run `bundle`, then `rake install`

## Execution
To run:
```
hsd_circle_reports build_stats
```
### Options

  - --account `account_name`
    * the account your token belongs to (default `hopskipdrive`)


  - --branch `branch_name`
    * the branch you want to report on (default `develop`)


  - --capture
    * if specified, will capture the output from the CircleCI API in a `json` file
    * you cannot specify both `--capture` and `--input`


  - --input `file_name`
    * if specified, will read from this file instead of calling the CircleCI API
    * you cannot specify both `--input` and `--capture`


  - --repository `repository_name`
    * the repository you want to report on (default `rails-api`)  


  - --start `date`
    * `YYYY-MM-DD` format
    * If not specified, will default to Today - 7 days


  - --token `token`
    * your API token for CircleCI. This can also be defined in an environment variable `CIRCLETOKEN`.

### Output
If the report runs successfully, you'll see output like this:
```text
13:26 ~ $ hsd_circle_reports build_stats 2020-03-20
Date: 2020-03-20
Date: 2020-03-25 Successful builds: 3 other builds: 1
Date: 2020-03-24 Successful builds: 4 other builds: 0
Date: 2020-03-23 Successful builds: 2 other builds: 0
Date: 2020-03-20 Successful builds: 1 other builds: 0

Total successful builds: 10, total failing builds: 1
Percentage succeeding: 90.91
Percentage failing: 9.09
13:26 ~ $
```

If your token is incorrect, you'll see output like this:
```text
13:24 ~ $ hsd_circle_reports build_stats --start 2020-06-27 --token badtoken
Start Date: 2020-06-27
Error retrieving from CircleCI: 
    404 Not Found.
    '404 Not Found' could indicate a problem with your Circle Token.
13:24 ~ $
```

## Developing

Clone this repository.

In the root of the repository, run:
  -  `bundle install` 

To test, run:
  - `rspec`
  
When finished, run:
  -  `rake build`
  -  `rake install`


Some sample `run configurations` for RubyMine are in the `run_configurations` folder.
