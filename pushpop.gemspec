# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'pushpop/version'

Gem::Specification.new do |s|

  s.name        = "pushpop"
  s.version     = Pushpop::VERSION
  s.authors     = ["Josh Dzielak"]
  s.email       = "josh@keen.io"
  s.homepage    = "https://github.com/keenlabs/pushpop"
  s.summary     = "Send alerts and recurring reports based on Keen IO events"
  s.description = "Pushpop is a simple but powerful Ruby app that sends notifications about events captured with Keen IO."

  s.add_dependency "clockwork"
  s.add_dependency "keen"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
