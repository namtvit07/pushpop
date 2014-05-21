<p align="center">
<img align="center" src="http://f.cl.ly/items/0z182V2i3X0Q0Y3I2A2G/pushpop-logo.png"> 
</p>

[![Build Status](https://travis-ci.org/keenlabs/pushpop.svg)](https://travis-ci.org/keenlabs/pushpop)

### Send alerts and recurring reports based on Keen IO events

<hr>
<img src="http://f.cl.ly/items/1I421w263a10340a0u2q/Screen%20Shot%202014-04-16%20at%204.35.47%20PM.png" width="45%" alt="Pingpong Daily Response Time Report">
&nbsp;&nbsp;&nbsp;
<img src="http://f.cl.ly/items/3F3X2s2d2A1I1o0V3p1n/image.png" width="45%" alt="There were 5402 Pageviews today!">
<hr>

## Overview

Pushpop is a simple but powerful Ruby app that sends notifications about events captured with the [Keen IO](https://keen.io) Analytics API.

#### Ways to use Pushpop

##### Alerts

+ Send an email when your site has been busier than usual in the last hour
+ Send an SMS if the performance of your signup funnel dramatically changes

##### Recurring reports

+ Send a sales report to your inbox every day at noon
+ Send analytics reports to your customers every week

#### An example Pushpop job

This Pushpop job sends a nightly email at midnight containing the day's number of pageviews:

``` ruby
require 'pushpop'

job do

  every 24.hours, at: '00:00'

  keen do
    event_collection  'pageviews'
    analysis_type     'count'
    timeframe         'last_24_hours'
  end
  
  sendgrid do |response, _|
    to        'josh+pushpop@keen.io'
    from      'pushpop-app@keen.io'
    subject   'Pushpop Daily Pageviews Report'
    body      "There were #{response} pageviews today!"
  end

end
```

The email is sent by [Sendgrid](https://sendgrid.com), made possible by the `sendgrid` Pushpop plugin.

Pushpop syntax is short and sweet, but because Pushpop is just Ruby it's also quite powerful.

### Get Started

Excited to try out Pushpop with your Keen IO projects? Here's a few options to choose from:

#### The Quickstart

Setup Pushpop locally. It takes 10 minutes to get that first shiny report in your inbox, and even less if you already have a Keen IO, Sendgrid or Twilio account.

**[Go to the Quickstart](#quickstart)**

#### Deploy a Pushpop Instance

Ready to deploy a local Pushpop job? Detailed instructions for Heroku are provided as well as a basic guide for other platforms.

**[Go to the Deploy Guide](#deploy-guide)**

#### Need help?

Don't have a hacker on hand? The friendly folks at Keen IO can set a Pushpop up for you.

**Email [team@keen.io](mailto:team@keen.io?subject=I want a Pushpop!)** with the subject "I want a Pushpop!". Include information about what queries you'd like to run (and when) and how you'd like the results communicated.

## Quickstart

The goal of the Quickstart is to get a Pushpop instance running locally and write your first job. This should take less than 10 minutes.

#### Prerequisites

+ A working [Ruby installation](https://www.ruby-lang.org/en/installation/) (1.9+)
+ A [Keen IO](https://keen.io) account, project, and API keys
+ A [Sendgrid](https://sendgrid.com) and/or [Twilio](https://twilio.com) account and API keys

#### Steps

##### Clone this repository

``` shell
$ git clone git@github.com:keenlabs/pushpop.git
```

Enter the `pushpop` directory and install dependencies.

``` shell
$ cd pushpop
$ gem install bundler
$ bundle install
```

##### Test the included example job

There is an example job in [jobs/example_job.rb](jobs/example_job.rb). All it does is print some output to the console. Run this job via a rake task to make sure your configuration is setup properly.

``` shell
$ foreman run rake jobs:run_once[jobs/example_job.rb]
```

You should see the following output (followed by a logging statement):

``` html
Hey Pushpop, let's do a math!
<pre>The number 30!</pre>
```

##### Specify your API credentials

Now it's time to write a job that connects to APIs and does something real. For that we'll need to specify API keys. We'll use [foreman](https://github.com/ddollar/foreman) to tell Pushpop about these API keys. When you use foreman to run a process, it adds variables from a local `.env` file to the process environment. It's very handy for keeping secure API keys out of your code (`.env` files are gitignored by Pushpop).

Create a `.env` file in the project directory and add the API configuration properties and keys that you have. Here's what an example file looks like with settings from all three services:

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

##### Write your first job

Let's write a job that performs a count of one of your Keen IO collections and sends an email (or SMS) with the result. We'll set it to run every 24 hours.

Create a file in the `jobs` folder called `first_job.rb` and paste in the following example:

``` ruby
require 'pushpop'

job do

  # how frequently do we want this job to run?
  every 24.hours

  # what keen io query should be performed?
  keen do
    event_collection  '<my-keen-collection-name>'
    analysis_type     'count'
    timeframe         'last_24_hours'
  end

  # use this block to send an email
  sendgrid do |_, step_responses|
    to      '<my-to-email-address>'
    from    '<my-from-email-address>'
    subject "There were #{step_responses['keen']} events in the last 24 hours!"
    body    'We are blowing up!'
  end
  
  # use this block to send an sms
  twilio do |_, step_responses|
    to    '<to-phone-number>'
    body  "There were #{step_responses['keen']} events in the last 24 hours!"
  end
end
```

Now modify the example to use your query and contact information. You'll want to specify a `to` and a `from` address if you're using Sendgrid, and a `to` phone number if you're using Twilio. Everything you need to change is marked with `<>`. You'll also want to remove either Sendgrid or Twilio block if you're not using it.

Save the file and test this job the `jobs:run_once` rake task:

``` shell
$ foreman run rake jobs:run_once[jobs/first_job.rb]
```

The output of each step will be logged to the console. If everything worked you'll receive an email or a text message within a few seconds!

##### Next steps

+ Write and test more jobs. See the [Pushpop API Documentation](#pushpop-api-documentation) below for more examples of what you can do. See [pushpop-recipes](https://github.com/keenlabs/pushpop-recipes) for reusable code and inspiration!
+ Continue on to the [Deploy Guide](#deploy-guide) to deploy the job you just created.

## Deploy Guide

#### Heroku

These instructions are for Heroku, but should be relevant to most environments.

##### Prerequisites

You'll need a [Heroku](https://heroku.com/) account, and the [Heroku toolbelt](https://toolbelt.heroku.com/) installed.

##### Create a new Heroku app

Make sure you're inside a Pushpop project directory, than create a new Heroku app.

``` shell
$ heroku create
```

This will create a Heroku app and add a new git remote destination called `heroku` to your git configuration.

##### Commit changes

If you created a new job from the Quickstart guide, you'll want to commit that code before deploying.

``` shell
$ git commit -am 'Created my first Pushpop job'
```

##### Set Heroku config variables

The easiest way to do this is with the [heroku-config](https://github.com/ddollar/heroku-config) plugin. This step assumes you have created a `.env` file containing your keys as demonstrated in the Quickstart guide.

``` shell
$ heroku plugins:install git://github.com/ddollar/heroku-config.git
$ heroku config:push
```

##### Deploy code to Heroku

Now that your code is commited and config variables pushed we can begin a deploy.

``` shell
$ git push heroku master
```

##### Tail logs to confirm it's working

To see that jobs are running and that there are no errors, tail the logs on Heroku.

``` shell
$ heroku logs --tail
```

Note that if you have jobs that are set to run at specific times of day you might not see output for a while.

Another note - by default this will run all jobs in the `jobs` folder. You might want to delete the `example_job.rb` file in a separate commit once you've got the hang of things.

#### Other environments

Pushpop is deployed as one long-running Ruby process. Anywhere you can run this process you can run Pushpop. Here's the command:

``` shell
$ foreman run rake jobs:run
```

If you don't want to use foreman and prefer to set the environment variables yourself then all you need is this:

``` shell
$ bundle exec rake jobs:run
```

Note: You probably want to monitor the process via something like [supervisord](http://supervisord.org/).

## Rake Tasks

Pushpop comes with some rake tasks to make command line interaction and deployment easier.

All `jobs:*` rake tasks optionally take a single filename as a parameter. The file is meant to contain one or more Pushpop jobs. If no filename is specified, all jobs in the jobs folder are required.

Specifying a specific file looks like this:

``` shell
$ foreman run rake jobs:run[jobs/just_this_job.rb]
```

Here's a list of the available rake tasks:

+ `jobs:describe` - Print out the names of jobs in the jobs folder.
+ `jobs:run_once` - Run each job once, right now.
+ `jobs:run` - Run jobs as scheduled in a long-running process. This is the task used when you deploy.
+ `spec` - Run the specs.

## Pushpop API Documentation

Steps and jobs are the heart of the Pushpop workflow. Job files are written in pure Ruby and contain one or more jobs. Each job consists of one or more steps.

#### Jobs

Jobs have the following attributes:

+ `name`: (optional) something that describe the job, useful in logs
+ `period`: how frequently to run the job, first param to `every`
+ `every_options` (optional): options related to when the job runs, second param to `every`
+ `steps`: an ordered list of steps to run

These attributes are easily specified using the DSL's block syntax. Here's an example:

``` ruby
job 'print job' do
  every 5.minutes
  step do
    puts "5 minutes later..."
  end
end
```

The name of this job is 'print job'. It runs every 5 minutes and it has 1 step.

Inside of a `job` configuration block, steps are added by using the `step` method. They can also be
added by using a method registered by a plugin, like `keen` or `twilio`. For more information on plugins see [Plugin Documentation](#plugin-documentation).

The period of the job's execution is set via the `every` method. This is basically a passthrough to the [Clockwork](https://github.com/tomykaira/clockwork) long-running process scheduler. Here are some cool things you can do with regard to setting times and days:

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

+ `name`: (optional) something that describes the step. Useful in logs, and is the key in the `step_responses` hash. Defaults to plugin name if a plugin is used. If you use the same plugin more than twice, you'll need to give steps individual names.
+ `plugin`: (optional) if the step is backed by a plugin, it's the name of the plugin
+ `block`: A block that runs to configure the step (when a plugin is used) or run it

Steps can be pure Ruby code or use a DSL provided by a plugin. Plugins are just fancy abstractions for creating steps.

Steps have built-in support for ERB templating. This is useful for generating more complex emails and reports.

Here's an example that uses a template:

``` ruby
sendgrid do |response, step_responses|
  to            'josh+pushpop@keen.io'
  from          'pushpopapp+123@keen.io'
  subject       'Pingpong Daily Response Time Report'
  body template 'pingpong_report.html.erb', response, step_responses
end
```

`template` is a function that renders a template in context of the `response` and `step_responses` and returns a string.
The first argument is a template file name, located in the `templates` directory by default. The second and third arguments are the `response` and `step_responses` respectively. An optional fourth parameter can be used to change the path templates are looked up in.

Here's a very simple template that uses the `response` variable in context:

``` erb
<h1>Daily Report</h1>
<p>We got <%= response %> new users today!</p>
```

## Recipes

The community-driven [pushpop-recipes](https://github.com/keenlabs/pushpop-recipes) repository contains jobs and templates
for doing common things with Pushpop. Check it out for some inspiration!

## Plugin Documentation

Plugins are located at `lib/plugins`. They can be included explicitly via:

``` ruby
Pushpop.load_plugin '<plugin_name>'
```

Pushpop will also attempt to auto-include them if a step name is invoked that isn't defined yet.

##### Keen

The `keen` plugin gives you a DSL to specify Keen query parameters. Those query parameters are used to query data using the [keen-gem](https://github.com/keenlabs/keen-gem).

Here's an example that shows many of the options you can specify:

``` ruby
job 'average response time for successful requests last month' do

  keen do
    event_collection  'checks'
    analysis_type     'average'
    target_property   'request.duration'
    group_by          'check.name'
    interval          'daily'
    timeframe         'last_month',
    filters           [{ property_name: "response.successful",
                         operator: "eq",
                         property_value: true }]
  end

end
```

A `steps` method is also supported for [funnels](https://keen.io/docs/data-analysis/funnels/),
as well as `analyses` for doing a [multi-analysis](https://keen.io/docs/data-analysis/multi-analysis/).

The `keen` plugin requires that the following environment variables are set:
  
+ `KEEN_PROJECT_ID`
+ `KEEN_READ_KEY`

##### Sendgrid

The `sendgrid` plugin gives you a DSL to specify email parameters like subject and body.

Here's an example:

``` ruby
job 'send an email' do

  sendgrid do
    to        'josh+pushpop@keen.io'
    from      'pushpopapp+123@keen.io'
    subject   'Is your inbox lonely?'
    attachment '/funny_images/sad_inbox.jpeg'
    body      'This email was intentionally left blank.'
    preview   false
  end

end
```

The `preview` directive is optional and defaults to false. If you set it to true the email contents will print out
to the console but the email will not be sent.

The `attachment` method is optional and takes a path to the desired file to be attached.

The `body` method can take a string, or it can take the same parameters as `template`, in which case it will render a template to create the body. For example:

``` ruby
body 'pingpong_report.html.erb', response, step_responses
```

The `sendgrid` plugin requires that the following environment variables are set: 

+ `SENDGRID_DOMAIN`
+ `SENDGRID_USERNAME`
+ `SENDGRID_PASSWORD`

##### Non-DSL methods

Need to send multiple emails in one step? Need more control over email sending? The DSL approach won't be sufficient for you.
Instead, use the `send_email` method exposed by the plugin directly. Here's an example:

``` ruby
job 'send multiple emails' do

  step 'send some emails' do

    ['josh+1@keen.io', 'justin+1@keen.io'].each do |to_address|
      send_email to_address, 'pushpop-app@keen.io', 'Nice subject', 'Nice body'
    end

  end

end
```

##### Twilio

The `twilio` plugin provides a DSL to specify SMS recipient information as well as the message itself.

Here's an example:

``` ruby
job 'send a text' do

  twilio do
    to    '+18005555555'
    body  'Quick, move your car!'
  end

end
```

The `twilio` plugin requires that the following environment variables are set:

+ `TWILIO_AUTH_TOKEN`
+ `TWILIO_SID`
+ `TWILIO_FROM`

##### Non-DSL Methods

If you need a lower level interface to Twilio functionality, use the `send_message` method exposed by the plugin directly. Here's an example:

``` ruby
job 'send a few texts' do

  twilio do
    ['+18005555555','+18005555556'].each do |to_number|
      send_message(to_number, 'Quick, move your car!')
    end
  end

end
```


## Creating plugins

Plugins are just subclasses of `Pushpop::Step`. Plugins should implement a `run` method and register themselves. Here's a simple plugin that stops job execution if the input into the step is 0:

``` ruby
module Pushpop
  class StopIfZero < Step
    PLUGIN_NAME = 'stop_if_zero'
    def run(last_response=nil, step_responses=nil)
      last_response == 0
    end
  end

  Pushpop::Job.register_plugin(StopIfZero::PLUGIN_NAME, StopIfZero)
end

# now in your job you can use the stop_if_zero step

job do
  step do [0, 1].shuffle.first end
  stop_if_zero
  step do puts 'made it through!' end
end
```

## Usage as a Ruby gem

Pushpop can also be embedded in existing Ruby projects as a Ruby gem. Here's some steps on how to do that.

##### Install the gem

``` ruby
# bundler
gem 'pushpop'

# not bundler
gem install 'pushpop'
```

##### Require job files and run

Once the gem is available you can load or require Pushpop job files. Once each file loads the jobs it contains are ready to be run or scheduled. Here's that sequence:

``` ruby
load 'some_job.rb'

# you could run the jobs once
Pushpop.run

# or schedule and run the jobs with clockwork
Pushpop.schedule
Clockwork.manager.run
```

The `pushpop` gem does not declare dependencies other than `clockwork` and `keen`. If you're using
Pushpop plugins like Sendgrid or Twilio you'll need to bundle and require those dependencies separately.

## Contributing

Issues and pull requests are very welcome!

##### Wishlist

+ Add plugins for more data collection and email/SMS/notification services
+ Add a web interface that shows job names, previous job results, and countdowns to the next run
+ Add a web interface for previewing emails in the browser
+ Add beautiful email templates with support for typical Keen IO query responses (groups, series, etc)

##### Testing

Please make sure the specs pass before you submit your pull request. Pushpop has a full set of specs (including plugins). Run them like this:

``` shell
$ bundle exec rake spec
```

## Inspirations

> "Technology shouldn't require all of our attention, just some of it, and only when necessary."
> [calmtechnology.com](http://calmtechnology.com/)

Dashboards and reports are human presentation vehicles. They require our attention in order to gain meaning. That's great when we're actively seeking answers and want to explore. But as a means to become aware of interesting, timely events it's neither effective nor efficient. A tool like Pushpop works better in those cases. It's a calmer technology.
