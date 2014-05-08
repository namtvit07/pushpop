# Pushpop
[![Build Status](https://travis-ci.org/keenlabs/pushpop.svg)](https://travis-ci.org/keenlabs/pushpop)

### Automated delivery of analytics reports and notifications

<hr>
<img src="http://f.cl.ly/items/1I421w263a10340a0u2q/Screen%20Shot%202014-04-16%20at%204.35.47%20PM.png" width="45%" alt="Pingpong Daily Response Time Report">
&nbsp;&nbsp;&nbsp;
<img src="http://f.cl.ly/items/3F3X2s2d2A1I1o0V3p1n/image.png" width="45%" alt="There were 5402 Pageviews today!">
<hr>

## Overview

Pushpop is a simple, deploy-in-minutes Ruby app that sends emails and notifications in response to events you're capturing with Keen IO.

#### Things Pushpop can do

**Report Delivery**

+ Send a metrics report to your inbox every day
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

## What next?

With me so far? Excited to try Pushpop with your data? Here's a few things to do next:

#### Quickstart - Run Pushpop locally

Got 10 minutes? It doesn't take long to get that first shiny report in your inbox, and even less if you already have a Keen IO, Sendgrid or Twilio account.

**[Go to the Quickstart](#Quickstart)**

#### Deploy a Pushpop Instance

If you've already written and run a Pushpop job locally you're now ready to deploy it. Instructions are for Heroku are provided, but are generalizeable to other platforms.

**[Go to the Deploy Guide](#DeployGuide)**

#### Not into the coding thing?

Programming not your cup of tea? That's ok. Tea comes in a lot of different flavors. The friendly folks at Keen IO are happy to help you out.

**Email [team@keen.io](mailto:team@keen.io?subject=I want a Pushpop!)** with the subject "I want a Pushpop!"

## Quickstart

The goal of the quickstart is to get a Pushpop instance locally. This should take less than 10 minutes.

#### Prerequisites

+ A working Ruby 1.9 installation
+ A [Keen IO](https://keen.io) account and project and associated API keys
+ A [Sendgrid](https://sendgrid.com) or [Twilio](https://twilio.com) account and associated API keys

#### Steps

**Clone this repository.**

``` shell
$ git clone git@github.com:keenlabs/pushpop.git
```

Enter the pushpop directory and install dependencies.

``` shell
$ cd pushpop
$ gem install bundler
$ bundle install
```

**Make sure everything is in order by running a test job.**

There is an example job in `jobs/example.rb`. All it does is print some output to the console. Run this job via a rake task to make sure your configuration is properly setup.

``` shell
$ foreman run rake jobs:run_once[jobs/example.rb]
```

You should see the following output followed by a logging statement:

``` html
Hey Pushpop, let's do a math!
<pre>The number 30!</pre>
```

**Specify your API credentials**

Now it's time to write a job that does something real. For that we'll need to specify API keys. To tell Pushpop about 
API keys, we'll use [foreman](https://github.com/ddollar/foreman). When you use foreman to run a process, it adds variables found in a `.env` file to the environemnt. It's very handy for keeping secure API keys out of your code! (.env files are gitignored by Pushpop)

Create a `.env` file in the project directory and add Keen IO API keys and either Twilio or Sendgrid keys. Here's
what an example file would look like with all three:

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

Let's write a job that performs a count of one of your Keen IO collections, then sends you an email or text with the result. We'll set it to run every 24 hours.

Create a file in the `jobs` folder called `first_job.rb` and paste in the following example.

``` ruby
job do

  # how frequently do we want this job to run?
  every 24.hours

  # here we setup the keen query
  keen do
    event_collection '<my-keen-collection-name>'
    analysis_type 'count'
    timeframe 'last_24_hours'
  end

  sendgrid do |response, step_responses|
    to '<my-to-email-address>'
    from '<my-from-email-address>'
    subject "There were #{step_responses['keen']} events in the last 24 hours!"
    body 'Not too shabby!'
  end
  
  twilio do |step_responses|
    to '<to-phone-number>'
    body "There were #{step_responses['keen']} events in the last 24 hours!"
  end
end
```

Now modify the example to suit your needs. You'll want to specify a `to` & `from` address if you're using Sendgrid and a
`to` phone number if using Twilio. Everything you need to change is marked with `<>`. You'll also want to remove either Sendgrid or Twilio blocks you're not using them.

Save the file, and let's test this job using the same rake task we used before.

``` shell
$ foreman run rake jobs:run_once[jobs/first_job.rb]
```

The output of each step should print, and if everything worked you'll receive an email or a text message within a few seconds!

**Next steps**

From here you can write and run more jobs, or continue to the Deploy Guide to see how to deploy your code and send reports on an ongoing basis.

## Deploy Guide

These instructions are for Heroku, but should be adaptable to most environments. This should only about 10 minutes.

1. Prerequisites
You'll need a Heroku account, and the Heroku toolbelt installed.

2. Create a new Heroku app

Make sure you're inside the Pushpop directory.

``` shell
$ heroku create
```

3. Commit any outstanding changes you have.

If you create a new job from the Quickstart guide, you'll need to commit that code before we deploy.

``` shell
$ git commit -am 'Adding my first job'
```

4. Push environment variables up to the Heroku app

The easiest way to do this is with the heroku-config plugin. This assumes you have created a .env file containing
your keys as demonstrated in the Quickstart guide.

``` shell
$ heroku plugins:install git://github.com/ddollar/heroku-config.git
$ heroku config:push
```

5. Push code to Heroku

Now that your code is commited and environment variables pushed we can kick off a deploy.

``` shell
$ git push heroku master
```

6. Make sure everything worked

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

+ `name`: (optional) something that describes the step. Useful in logs, and is the key in the `step_responses` hash. Defaults to plugin name, then an auto-generated value.
+ `plugin`: (optional) if the step is backed by a plugin, it's the name of the plugin
+ `block`: A block that runs to configure the step (when a plugin is used), or run it.

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
The second and third arguments are the response and step_responses respectively.
An optional fourth parameter can be used to change the path templates are looked for in.

Here's a very simple template:

``` erb
<h1>Daily Report</h1>
<p>We got <%= response %> new users today!</p>
```

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

All plugins are located at `lib/plugins`. They are loaded automatically.

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

The `sendgrid` plugin gives you a DSL to specify email recipient information, as well as the subject and body.

Here's an example:

``` ruby
job 'send an email' do

  sendgrid do
    to 'josh+pushpop@keen.io'
    from 'pushpopapp+123@keen.io'
    subject 'Hey, ho, Let's go!'
    body 'This email was intentionally left blank.'
    preview false
  end

end
```

The `sendgrid` plugin requires that the following environment variables are set: `SENDGRID_DOMAIN`, `SENDGRID_USERNAME`, and `SENDGRID_PASSWORD`.

The `preview` directive is optional and defaults to false. If you set it to true, the email contents will print out
to the console, but the email will not send.

The `body` method can take a string, or it can take the same parameters as `template`,
in which case it will render a template to create the body. For example:

``` ruby
body 'pingpong_report.html.erb', response, step_responses
```

##### Twilio

The `twilio` plugin gives you a DSL to specify SMS recipient information as well as the text itself.

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
