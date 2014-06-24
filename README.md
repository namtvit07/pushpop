<p align="center">
<img align="center" src="http://f.cl.ly/items/0z182V2i3X0Q0Y3I2A2G/pushpop-logo.png"> 
</p>

[![Build Status](https://travis-ci.org/pushpop-project/pushpop.svg)](https://travis-ci.org/pushpop-project/pushpop)

### A framework for scheduled integrations between popular services

<hr>
<img src="http://f.cl.ly/items/1I421w263a10340a0u2q/Screen%20Shot%202014-04-16%20at%204.35.47%20PM.png" width="45%" alt="Pingpong Daily Response Time Report">
&nbsp;&nbsp;&nbsp;
<img src="http://f.cl.ly/items/3F3X2s2d2A1I1o0V3p1n/image.png" width="45%" alt="There were 5402 Pageviews today!">
<hr>

## Overview

Pushpop is a powerful framework for taking actions and integrating services at regular intervals.
This can be used to do anything from scheduled data collection to alerting based on patterns in data.

Pushpop includes support for sending notifications and reports based on events captured with [Keen IO](https://keen.io).
See plugins for more services on the [Pushpop organization](https://github.com/pushpop-project) home page.

Pushpop is packaged as a Ruby gem. It can be added to existing Ruby projects or used in new ones.

#### Ideas for using Pushpop

##### Alerts

+ Send an email when your site has been busier than usual in the last hour
+ Send an SMS if the performance of your signup funnel dramatically changes

##### Recurring reports

+ Send a sales report to your inbox every day at noon
+ Send analytics reports to your customers every week
 
##### Monitoring

+ Track the performance of web services and APIs
+ Store sensors values for analysis and alerting

#### Example Pushpop job

Pushpop organized work into jobs. Here's a Pushpop job that uses the `keen` and `sendgrid` plugins to send a nightly email. The email contains the day's number of pageviews:

``` ruby
require 'pushpop-keen'
require 'pushpop-sendgrid'

job do

  every 24.hours, at: '00:00'

  keen do
    event_collection  'pageviews'
    analysis_type     'count'
    timeframe         'last_24_hours'
  end

  sendgrid do |response, _|
    to        'josh+pushpop@keen.io'
    from      'josh+pushpop@keen.io'
    subject   'Pushpop Daily Pageviews Report'
    body      "There were #{response} pageviews today!"
  end

end
```

Keen IO provides the analytics data behind the report. The email is sent by [Sendgrid](https://sendgrid.com) via the [sendgrid](https://github.com/pushpop-project/pushpop-sendgrid) Pushpop plugin.

Pushpop syntax is short and sweet, but because Pushpop is pure Ruby it's also quite powerful.

### Get Started

Excited to try out Pushpop on your own projects? Here's a few options to choose from:

#### The Quickstart

Setup Pushpop locally and run your first job in minutes.

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

#### Steps

##### Clone the Pushpop starter project

[pushpop-starter](https://github.com/pushpop-project/pushpop-starter) is a template-style repository with a few key files to help you get up and running quickly.

Clone it to get started:

``` shell
$ git clone git@github.com:pushpop-project/pushpop-starter.git
```

Enter the `pushpop-starter` directory and install dependencies.

``` shell
$ cd pushpop-starter
$ gem install bundler
$ bundle install
```

##### Test the included job

There is an example job in `jobs/example_job.rb` of the pushpop-starter repository. It simply prints output to the console. Run this job via a rake task to make sure your configuration is setup properly.

``` shell
$ bundle exec rake jobs:run_once[jobs/example_job.rb]
```

You should see the following output (followed by a logging statement):

``` html
Hey Pushpop, let's do a math!
<pre>The number 30!</pre>
```

That's all there is to it. To run the job repeatedly at the times specified by `every` just change `run_once` to `run`:

``` shell
$ bundle exec rake jobs:run[jobs/example_job.rb]
```

Make sure to leave the process running in your terminal, or send it to the background.

##### Next steps

+ Write and test more jobs. See the [Pushpop API Documentation](#pushpop-api-documentation) below for more examples of what you can do.
+ See [pushpop-recipes](https://github.com/pushpop-project/pushpop-recipes) for reusable code and inspiration.
+ Continue on to the [Deploy Guide](#deploy-guide) to deploy the job you just created.

## Deploy Guide

#### Heroku

These instructions are for Heroku, but should be relevant to most environments.

##### Prerequisites

You'll need a [Heroku](https://heroku.com/) account, and the [Heroku toolbelt](https://toolbelt.heroku.com/) installed.

##### Create a new Heroku app

Make sure you're inside a Pushpop project directory (e.g. pushpop-starter), than create a new Heroku app.

``` shell
$ heroku create
```

This will create a Heroku app and add a new git remote destination called `heroku` to your git configuration.

##### Commit changes

If you created a new job from the Quickstart guide, you'll want to commit that code before deploying.

``` shell
$ git commit -am 'Created my first Pushpop job'
```

##### Deploy code to Heroku

Now that your code is commited and config variables pushed we can begin a deploy. We'll also need to scale the number of worker processes to 1.

``` shell
$ git push heroku master
$ heroku scale worker=1
```

##### Tail logs to confirm it's working

To see that jobs are running and that there are no errors, tail the logs on Heroku.

``` shell
$ heroku logs --tail
```

Note that if you have jobs that are set to run at specific times of day you might not see output for a while.

Another note - by default this will run all jobs in the `jobs` folder. You might want to delete the `example_job.rb` file in a separate commit once you've got the hang of things. You can change this behavior by editing the Procfile.

#### Other environments

Pushpop is deployed as one long-running Ruby process. Anywhere you can run this process you can run Pushpop. Here's the command:

``` shell
$ bundle exec rake jobs:run
```

Many of the Pushpop plugins require environment variables to communicate with other services. [foreman](https://github.com/ddollar/foreman), which is included in the Heroku toolbelt, provides a convenient idiom for storing environment variables in a .env file and loading them at runtime. Just add `foreman run` before the above command to run with the .env file loaded:

``` shell
$ foreman run bundle exec rake jobs:run
```

If you are on Windows foreman [won't work](https://github.com/pushpop-project/pushpop/issues/2). Here's a list of [foreman alternatives](http://nikolas.demiridis.gr/post/65679016070/heroku-for-windows-junkies-some-foreman-alternatives).

Since this process should be long-lived you probably want to monitor the process via something like [supervisord](http://supervisord.org/).

## Rake Tasks

Pushpop comes with some rake tasks to make command line interaction and deployment easier.

All `jobs:*` rake tasks optionally take a single filename as a parameter. The file is meant to contain one or more Pushpop jobs. If no filename is specified, all jobs in the jobs folder are required.

Specifying a specific file looks like this:

``` shell
$ bundle exec rake jobs:run[jobs/just_this_job.rb]
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

The community-driven [pushpop-recipes](https://github.com/pushpop-project/pushpop-recipes) repository contains jobs and templates
for doing common things with Pushpop. Check it out for some inspiration!

## Plugins

Plugins are packaged as gems. See the [Pushpop organization](https://github.com/pushpop-project) page for a sampling of popular plugins.

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

See [pushpop-plugin](https://github.com/pushpop-project/pushpop-plugin) for a repository that you can clone to make creating and packaging plugins easier.

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

The `pushpop` gem does not declare dependencies other than `clockwork`. If you're using Pushpop plugins like Keen, Sendgrid or Twilio you'll need to add those to your gemfile and require them in job files.

## Contributing

Issues and pull requests are very welcome. One of the goals of the pushpop-project is to get an many unique contributors as possible. Beginners welcome too!

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
