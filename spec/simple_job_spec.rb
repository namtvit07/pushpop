require 'spec_helper'

describe 'run a job end to end' do
  it 'runs and return template contents' do
    require File.expand_path('../jobs/simple_job', __FILE__)
    expect(Pushpop.jobs.length).to eq(1)
    expect(Pushpop.jobs.first.run).to eq([30, { "return 10" => 10, "increase by 20" => 30}])
  end
end
