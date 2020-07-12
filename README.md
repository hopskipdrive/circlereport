# Circle Reports
`circlereports` is a Ruby gem that runs on your local machine. It generates reports by calling the CircleCI API to retrieve information about build workflows.

It generates a report covering 7 days, starting on the `--start` date provided.

## Installation
To install (until we have a gem server):
 - clone the github repository
 - run `bundle`
 - run `rake build`
 - run `rake install`

## Execution
You will need an API token from CircleCI to allow you to execute this command. You can [get it here](https://app.circleci.com/settings/user/tokens?return-to=https%3A%2F%2Fapp.circleci.com%2Fpipelines%2Fgithub%2Fhopskipdrive%2Frails-api). 

To run:
```
hsd_circle_reports
```
To see all options:
```
hsd_circle_reports help build_stats
```

### Options

  - --account `account_name`
    * the account your token belongs to (default `hopskipdrive`)


  - --branch `branch_name`
    * the branch you want to report on (default `develop`)

  - --repository `repository_name`
    * the repository you want to report on (default `rails-api`)  


  - --capture
    * if specified, will capture the output from the CircleCI API in a `json` file
    * you cannot specify both `--capture` and `--input`


  - --input `file_name`
    * if specified, will read from this file instead of calling the CircleCI API
    * you cannot specify both `--input` and `--capture`



  - --start `date`
    * `YYYY-MM-DD` format
    * If not specified, will default to Today - 7 days


  - --token `token`
    * your API token for CircleCI. This can also be provided in an environment variable `CIRCLETOKEN`.

### Output
If the report runs successfully, you'll see output like this:
```text
13:26 ~ $ hsd_circle_reports
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
13:24 ~ $ hsd_circle_reports --start 2020-06-27 --token badtoken
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
  
Before pushing to `github`, run:
  - `rubocop -a`
  - `bundle audit --update`  
  
When finished, run:
  -  `rake build`
  -  `rake install`

### Development tips & tricks
- If you're using `rvm`, watch your `gemset`. You probably want to switch to the `global` gemset before running `rake install`. That will make the executable available whenever your Ruby version is in use.

- Some sample `run configurations` for RubyMine are in the `run_configurations` folder.
