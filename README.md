<h1>Circle Reports</h1>
Circlereports is a Ruby script that runs on your local machine.

To run, from Terminal, you need to run `gem install thor` then run:
```
./circlereport.rb rpt <date>
```
where `date` is the day on which you wish the report to start. The default value for `date` is Today - 7 days.

You need to create a local environment variable `CIRCLETOKEN` which can be obtained from the CircleCI dashboard `https://circleci.com/account/api` `Personal API Tokens`

The ruby script will start on that day and include the following 6 days (a total of 7 days).

If the report runs successfully, you'll see output like this:
```text
13:26 ~/dev/circlereports (master) $ ./circlereport.rb rpt 2020-03-20
Date: 2020-03-20
Date: 2020-03-25 Successful builds: 3 other builds: 1
Date: 2020-03-24 Successful builds: 4 other builds: 0
Date: 2020-03-23 Successful builds: 2 other builds: 0
Date: 2020-03-20 Successful builds: 1 other builds: 0

Total successful builds: 10, total failing builds: 1
Percentage succeeding: 90.91
Percentage failing: 9.09
13:26 ~/dev/circlereports (master) $
```

If your token is incorrect, you'll see output like this:
```text
13:24 ~/dev/circlereports (master) $ ./circlereport.rb rpt 2020-03-20
Date: 2020-03-20
Traceback (most recent call last):
	14: from ./circlereport.rb:88:in `<main>'
	13: from /Users/ian/.rvm/rubies/ruby-2.5.7/lib/ruby/gems/2.5.0/gems/thor-0.20.3/lib/thor/base.rb:466:in `start'
	12: from /Users/ian/.rvm/rubies/ruby-2.5.7/lib/ruby/gems/2.5.0/gems/thor-0.20.3/lib/thor.rb:387:in `dispatch'
	11: from /Users/ian/.rvm/rubies/ruby-2.5.7/lib/ruby/gems/2.5.0/gems/thor-0.20.3/lib/thor/invocation.rb:126:in `invoke_command'
	10: from /Users/ian/.rvm/rubies/ruby-2.5.7/lib/ruby/gems/2.5.0/gems/thor-0.20.3/lib/thor/command.rb:27:in `run'
	 9: from ./circlereport.rb:18:in `rpt'
	 8: from ./circlereport.rb:70:in `circle_data'
	 7: from /Users/ian/.rvm/rubies/ruby-2.5.7/lib/ruby/2.5.0/open-uri.rb:35:in `open'
	 6: from /Users/ian/.rvm/rubies/ruby-2.5.7/lib/ruby/2.5.0/open-uri.rb:735:in `open'
	 5: from /Users/ian/.rvm/rubies/ruby-2.5.7/lib/ruby/2.5.0/open-uri.rb:165:in `open_uri'
	 4: from /Users/ian/.rvm/rubies/ruby-2.5.7/lib/ruby/2.5.0/open-uri.rb:224:in `open_loop'
	 3: from /Users/ian/.rvm/rubies/ruby-2.5.7/lib/ruby/2.5.0/open-uri.rb:224:in `catch'
	 2: from /Users/ian/.rvm/rubies/ruby-2.5.7/lib/ruby/2.5.0/open-uri.rb:226:in `block in open_loop'
	 1: from /Users/ian/.rvm/rubies/ruby-2.5.7/lib/ruby/2.5.0/open-uri.rb:755:in `buffer_open'
/Users/ian/.rvm/rubies/ruby-2.5.7/lib/ruby/2.5.0/open-uri.rb:377:in `open_http': 404 Not Found (OpenURI::HTTPError)
13:24 ~/dev/circlereports (master) $
```

<h2>Options</h2>
`--capture` will capture the Circle data to a `JSON` file. The default is `--no-capture`.

