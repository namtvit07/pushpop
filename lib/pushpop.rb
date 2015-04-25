require 'active_support/all'
require 'logger'
require 'clockwork'
require 'pushpop/version'
require 'pushpop/job'
require 'pushpop/step'
require 'pushpop/cli'

module Pushpop
  class << self

    @@jobs = []

    @@logger = lambda {
      logger = Logger.new($stdout)
      if ENV['DEBUG']
        logger.level = Logger::DEBUG
      elsif ENV['RACK_ENV'] == 'test'
        logger.level = Logger::FATAL
      else
        logger.level = Logger::INFO
      end
      logger
    }.call

    def logger
      @@logger
    end

    def jobs
      @@jobs
    end

    # for jobs and steps
    def random_name
      (0...8).map { (65 + rand(26)).chr }.join
    end

    def add_job(name=nil, &block)
      self.jobs.push(Job.new(name, &block))
      self.jobs.last
    end

    def run
      self.jobs.map &:run
    end

    def schedule
      self.jobs.map &:schedule
    end

    def load_plugin(name)
      load "#{File.expand_path("../plugins/#{name}", __FILE__)}.rb"
    end
  end
end

# add into main
def job(name=nil, &block)
  Pushpop.add_job(name, &block)
end
