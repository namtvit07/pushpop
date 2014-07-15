require 'spec_helper'

describe Pushpop::CLI do

  def start(str=nil)
    Pushpop::CLI.start(str ? str.split(" ") : [])
  end

  it 'prints help by default' do
    _, options = start
    expect(_).to be_empty
  end

  describe 'with -v' do
    it 'prints the version' do
      _, options = start('-v')
      expect(_).to match('Pushpop version')
    end
  end

  describe 'jobs:describe' do
    it 'prints job information' do
      _, options = start('jobs:describe --file spec/jobs')
      expect(_.name).to eq('Simple Math')
    end
  end

  describe 'jobs:run_once' do
    it 'runs jobs once' do
      _, options = start('jobs:run_once --file spec/jobs')
      expect(_.first).to equal(30)
    end
  end

end
