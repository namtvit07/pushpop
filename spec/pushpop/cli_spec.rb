require 'spec_helper'

describe Pushpop::CLI do

  def start(str=nil)
    Pushpop::CLI.start(str ? str.split(" ") : [])
  end

  it 'prints help by default' do
    _, options = start
    expect(_).to be_empty
  end

end
