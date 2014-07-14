require 'thor'
require 'pushpop'

module Pushpop
  class CLI < Thor

    desc 'version', 'Print the Pushpop version'
    map %w(-v --version) => :version

    def version
      "Pushpop version #{Pushpop::VERSION}".tap do |s|
        puts s
      end
    end


  end
end


