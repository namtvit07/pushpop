# Pushpop
[![Build Status](https://travis-ci.org/keenlabs/pushpop.svg)](https://travis-ci.org/keenlabs/pushpop)

### Automated delivery of analytics reports and alerts

<hr>
<img src="http://f.cl.ly/items/1I421w263a10340a0u2q/Screen%20Shot%202014-04-16%20at%204.35.47%20PM.png" width="45%" alt="Pingpong Daily Response Time Report">
&nbsp;&nbsp;&nbsp;
<img src="http://f.cl.ly/items/3F3X2s2d2A1I1o0V3p1n/image.png" width="45%" alt="There were 5402 Pageviews today!">
<hr>

## Overview

Pushpop is a simple, powerful Ruby app that sends notifications in response to events you're capturing with Keen IO.

#### Things Pushpop can do

**Report Delivery**

+ Send a metrics report to your inbox every day at noon
+ Send an email when your site has been particularly busy in the last hour
+ Send regular analytics reports to your customers

**Alerting**

+ Text you if your site is slow or unavailable
+ Text you if the performance of your signup funnel has dramatically changed
+ Text your sales team if a big company signs up

#### An example Pushpop job

Here's a Pushpop job that uses [Twilio](https://twilio.com/) to text the number of daily pageviews to a phone number every night at midnight:

``` ruby
require 'pushpop'

job do

  every 24.hours, at: '00:00'

  keen do
    event_collection 'pageviews'
    analysis_type 'count'
    timeframe 'last_24_hours'
  end

  twilio do |response|
    to '+18005555555'
    body "There were #{response} pageviews today!"
  end

end
```

Pushpop is designed to be short and sweet, but because anything Ruby can be used it's also very powerful.

### Where next?

Excited to try Pushpop with your data? Here's a few options to choose from:

#### Quickstart

Got 10 minutes? Setup Pushpop locally. It doesn't take long to get that first shiny report in your inbox, and even less if you already have a Keen IO, Sendgrid or Twilio account.

**[Go to the Quickstart](#quickstart)**

#### Deploy a Pushpop Instance

If you've already written and run a Pushpop job locally you're now ready to deploy it. Instructions are for Heroku are provided, but are generalizeable to other platforms.

**[Go to the Deploy Guide](#deploy-guide)**

#### Want! Help?

Not sure how to dig in? The friendly folks at Keen IO are happy to help you get an Pushpop instance running.

**Email [team@keen.io](mailto:team@keen.io?subject=I want a Pushpop!)** with the subject "I want a Pushpop!"

## Quickstart

The goal of the Quickstart is to get a Pushpop instance running locally. This should take less than 10 minutes.

#### Prerequisites

+ A working Ruby 1.9 installation
+ A [Keen IO](https://keen.io) account and project and associated API keys
+ A [Sendgrid](https://sendgrid.com) and/or [Twilio](https://twilio.com) account and associated API keys

#### Steps

**Clone this repository**

``` shell
$ git clone git@github.com:keenlabs/pushpop.git
```

Enter the pushpop directory and install dependencies.

``` shell
$ cd pushpop
$ gem install bundler
$ bundle install
```

**Test an example job**

There is an example job in [jobs/example_job.rb](jobs/example_job.rb). All it does is print some output to the console. Run this job via a rake task to make sure your configuration is setup properly.

``` shell
$ foreman run rake jobs:run_once[jobs/example_job.rb]
```

You should see the following output (followed by a logging statement):

``` html
Hey Pushpop, let's do a math!
<pre>The number 30!</pre>
```

**Specify your API credentials**

Now it's time to write a job that connects to APIs and does something real. For that we'll need to specify API keys. To tell Pushpop aboutAPI keys, we'll use [foreman](https://github.com/ddollar/foreman). When you use foreman to run a process, it adds variables found in a local `.env` file to the environment. It's very handy for keeping secure API keys out of your code (`.env` files are gitignored by Pushpop).

Create a `.env` file in the project directory and add the API configuration and keys that you have. Here's what an example file looks like with settings from all three services:

```
KEEN_PROJECT_ID=*********
KEEN_READ_KEY=*********
SENDGRID_DOMAIN=*********
SENDGRID_PASSWORD=*********
SENDGRID_USERNAME=*********
TWILIO_AUTH_TOKEN=*********
TWILIO_FROM=*********
TWILIO_SID=*********
```

**Write your first job**

Let's write a job that performs a count of one of your Keen IO collections, then sends an email or text with the result. We'll set it to run every 24 hours.

Create a file in the `jobs` folder called `first_job.rb` and paste in the following example:

``` ruby
job do

  # how frequently do we want this job to run?
  every 24.hours

  # what keen io query should be performed?
  keen do
    event_collection '<my-keen-collection-name>'
    analysis_type 'count'
    timeframe 'last_24_hours'
  end

  # use this block to send an email
  sendgrid do |_, step_responses|
    to '<my-to-email-address>'
    from '<my-from-email-address>'
    subject "There were #{step_responses['keen']} events in the last 24 hours!"
    body 'Blowing up!'
  end
  
  # use this block to send an sms
  twilio do |_, step_responses|
    to '<to-phone-number>'
    body "There were #{step_responses['keen']} events in the last 24 hours!"
  end
end
```

Now modify the example to use your specific information. You'll want to specify a `to` and a `from` address if you're using Sendgrid, and a `to` phone number if you're using Twilio. Everything you need to change is marked with `<>`. You'll also want to remove either Sendgrid or Twilio blocks you're not using them.

Save the file and test this job using the same `jobs:run_once` rake task that we used before.

``` shell
$ foreman run rake jobs:run_once[jobs/first_job.rb]
```

The output of each step should print, and if everything worked you'll receive an email or a text message within a few seconds!

**Next steps**

From here you can write and test more jobs. See the [Pushpop API Documentation](#pushpop-api-documentation) below for more examples of what you can do.

If you're ready to deploy a Pushpop to send ongoing reports, continue on to the deploy guide.

## Deploy Guide

These instructions are for Heroku, but should be adaptable to most environments.

**Prerequisites**

You'll need a Heroku account, and the Heroku toolbelt installed.

**Create a new Heroku app**

Make sure you're inside the Pushpop directory.

``` shell
$ heroku create
```

**Commit changes**

If you created a new job from the Quickstart guide, you'll want to commit that code before deploying.

``` shell
$ git commit -am 'Adding my first job'
```

**Push up Heroku config variables**

The easiest way to do this is with the [heroku-config](https://github.com/ddollar/heroku-config) plugin. This step assumes you have created a `.env` file containing your keys as demonstrated in the Quickstart guide.

``` shell
$ heroku plugins:install git://github.com/ddollar/heroku-config.git
$ heroku config:push
```

**Deploy code to Heroku**

Now that your code is commited and config variables pushed we can begin a deploy.

``` shell
$ git push heroku master
```

**Tail logs to confirm it's working**

To see that jobs are running and that there are no errors, tail the logs on Heroku.

``` shell
$ heroku logs --tail
```

Note that if you have jobs that are set to run at specific times of day you might not see output for a while.

Also note - by default this will run all jobs in the `jobs` folder. You might want to delete the `example_job.rb` file in
a separate commit once you've got the hang of things.

## Pushpop API Documentation

Steps and jobs are the heart of the Pushpop workflow. Any file can contain one or more jobs,
and each job consists of one or more steps.

#### Jobs

Jobs have the following attributes:

+ `name`: (optional) something that describe the job, useful in logs
+ `every_duration`: the frequency at which to run the job
+ `every_options`: options related to when the job runs
+ `steps`: the ordered list of steps to run

These attributes are easily specified with the DSL's block syntax. Here's an example:

``` ruby
job 'print job' do
  every 5.minutes
  step do
    puts "5 minutes later..."
  end
end
```

Inside of a `job` configuration block, steps are added by using the `step` method. They can also be
added by using a method registered by a plugin, like `keen` or `twilio`. For more information, see [Plugins](#plugins).

The frequency of the job is set via the `every` method. This is basically a passthrough to Clockwork.
Here are some cool things you can do:

``` ruby
every 5.seconds
every 24.hours, at: '12:00'
every 24.hours, at: ['00:00', '12:00']
every 24.hours, at: '**:05'
every 24.hours, at: '00:00', tz: 'UTC'
every 5.seconds, at: '10:**'
every 1.week, at: 'Monday 12:30'
```

See the full set of options on the [Clockwork README](https://github.com/tomykaira/clockwork#event-parameters).

##### Job workflow

When a job kicks off, steps are run serially in the order they are specified. Each step is invoked with 2
arguments - the response of the step immediately preceding it, and a map of all responses so far.
The map is keyed by step name, which defaults to a plugin name if a plugin was used but a step name not specified.

Here's an example that shows how the response chain works:

``` ruby
job do
  every 5.minutes
  step 'one' do
    1
  end
  step 'two' do |response|
    5 + response
  end
  step 'add previous steps' do |response, step_responses|
    puts response # prints 5
    puts step_responses['one'] + step_responses['two'] # prints 6
  end
end
```

If a `step` returns false, subsequent steps **are not run**. Here's a simple example that illustrates this:

``` ruby
job 'lame job' do
  every 5.minutes
  step 'one' do
    false
  end
  step 'two' do
    # never called!
  end
end
```

This behavior is designed to make *conditional* alerting easy. Here's an example of a job that only sends an alert
for certain query responses:

``` ruby
job do

  every 1.minute

  keen do
    event_collection 'errors'
    analysis_type 'count'
    timeframe 'last_1_minute'
  end

  step 'notify only if there are errors' do |response|
    response > 0
  end

  twilio do |step_responses|
    to '+18005555555'
    body "There were #{step_responses['keen']} errors in the last minute!"
  end
end
```

In this example, the `twilio` step will only be ran if the `keen` step returned a count greater than 0.

#### Steps

Steps have the following attributes:

+ `name`: (optional) something that describes the step. Useful in logs, and is the key in the `step_responses` hash. Defaults to plugin name if a plugin is used
+ `plugin`: (optional) if the step is backed by a plugin, it's the name of the plugin
+ `block`: A block that runs to configure the step (when a plugin is used) or run it

Steps can be pure Ruby code, or in the case of a plugin calling into a DSL.

Steps have built-in support for ERB templating. This is useful for generating more complex emails and reports.

Here's an example that uses a template:

``` ruby
sendgrid do |response, step_responses|
  to 'josh+pushpop@keen.io'
  from 'pushpopapp+123@keen.io'
  subject 'Pingpong Daily Response Time Report'
  body template 'pingpong_report.html.erb', response, step_responses
  preview false
end
```

`template` is a function that renders a template in context of the step responses and returns a string.
The first argument is a template file name, located in the `templates` directory by default.
The second and third arguments are the `response` and `step_responses` respectively.
An optional fourth parameter can be used to change the path templates are looked up in.

Here's a very simple template:

``` erb
<h1>Daily Report</h1>
<p>We got <%= response %> new users today!</p>
```

## Rake Tasks

All `jobs:*` rake tasks optionally take a single filename as a parameter. The file is meant to contain one or more Pushpop jobs. If no filename is specified, all jobs in the jobs folder are considered.

+ `jobs:describe` - Print out the names of jobs in the jobs folder
+ `jobs:run_once` - Run each job once, right now
+ `jobs:run` - Run jobs as scheduled in a long-running process
+ `spec` - Run the specs

## Recipes

Here are some ways to use Pushpop to do common tasks.

##### Error alerting with Pingpong

[Pingpong](https://github.com/keenlabs/pingpong.git) captures HTTP request/response data for remote URLs.
By pairing Pingpong with Pushpop, you can get custom alerts and reports about the web performance and
availability you're attempting to observe.

Here's a job that sends an SMS if any check had errors in the last minute.

``` ruby
job do

  every 1.minute

  keen do
    event_collection 'checks'
    analysis_type 'count'
    timeframe 'last_1_minute'
    filters [{
      property_name: "response.successful",
      operator: "eq",
      property_value: false
    }]
  end

  step 'notify only if there are errors' do |response|
    response > 0
  end

  twilio do |step_responses|
    to '+18005555555'
    body "There were #{step_responses['keen']} errors in the last minute!"
  end
end
```

##### Daily response time email report

See [examples/response_time_report_job.rb](examples/response_time_report_job.rb and the
[corresponding template](examples/templates/response_time_report.html.erb).

## Plugin Documentation

Plugins are located at `lib/plugins`. They are loaded automatically.

##### Keen

The `keen` plugin gives you a DSL to specify Keen query parameters. When it runs, it
passes those parameters to the [keen gem](https://github.com/keenlabs/keen-gem), which
in turn runs the query against the Keen IO API.

Here's an example that shows most of the options you can specify:

``` ruby
job 'daily average response time by check for successful requests in april' do

  keen do
    event_collection  'checks'
    analysis_type     'average'
    target_property   'request.duration'
    group_by          'check.name'
    interval          'daily'
    timeframe         ({ start: '2014-04-01T00:00Z' })
    filters           [{ property_name: "response.successful",
                         operator: "eq",
                         property_value: true }]
  end

end
```

The `keen` plugin requires that the following environment variables are set: `KEEN_PROJECT_ID` and `KEEN_READ_KEY`.

A `steps` method is also supported for [funnels](https://keen.io/docs/data-analysis/funnels/),
as well as `analyses` for doing a [multi-analysis](https://keen.io/docs/data-analysis/multi-analysis/).

##### Sendgrid

The `sendgrid` plugin gives you a DSL to specify email parameters like subject and body.

Here's an example:

``` ruby
job 'send an email' do

  sendgrid do
    to 'josh+pushpop@keen.io'
    from 'pushpopapp+123@keen.io'
    subject 'Is your inbox lonely?'
    body 'This email was intentionally left blank.'
    preview false
  end

end
```

The `sendgrid` plugin requires that the following environment variables are set: `SENDGRID_DOMAIN`, `SENDGRID_USERNAME`, and `SENDGRID_PASSWORD`.

The `preview` directive is optional and defaults to false. If you set it to true, the email contents will print out
to the console, but the email will not be sent.

The `body` method can take a string, or it can take the same parameters as `template`,
in which case it will render a template to create the body. For example:

``` ruby
body 'pingpong_report.html.erb', response, step_responses
```

##### Twilio

The `twilio` plugin provides DSL to specify SMS recipient information as well as the text itself.

Here's an example:

``` ruby
job 'send a text' do

  twilio do
    to '18005555555'
    body 'Breathe in through the nose, out through the mouth.'
  end

end
```

The `twilio` plugin requires that the following environment variables are set: `TWILIO_AUTH_TOKEN`, `TWILIO_SID`, and `TWILIO_FROM`.

## Creating plugins

Plugins are just subclasses of `Pushpop::Step`. Plugins should implement a run method, and
register themselves. Here's a simple plugin that stops job execution if the input into the step is 0:

``` ruby
module Pushpop
  class BreakIfZero < Step
    PLUGIN_NAME = 'break_if_zero'
    def run(last_response=nil, step_responses=nil)
      last_response == 0
    end
  end

  Pushpop::Job.register_plugin(BreakIfZero::PLUGIN_NAME, BreakIfZero)
end

# now in your job you can use the break_if_zero step

job do
  step do [0, 1].shuffle.first end
  break_if_zero
  step do puts 'made it through!' end
end
```

## Contributing

Issues and pull requests are welcome! Some ideas are to:

+ Add more plugins!
+ Add a web interface that lets you preview emails in the browser

Pushpop has a full set of specs (including plugins). Run them like this:

``` shell
$ bundle exec rake spec
```
