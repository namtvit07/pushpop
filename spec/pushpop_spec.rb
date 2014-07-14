require 'spec_helper'

describe 'job' do
  it 'has a name' do
    job 'foo-main' do end
    expect(Pushpop.jobs.first.name).to eq('foo-main')
  end
end

describe Pushpop do

  describe 'add_job' do
    it 'adds a job to the list' do
      empty_proc = Proc.new {}
      Pushpop.add_job('foo', &empty_proc)
      expect(Pushpop.jobs.first.name).to eq('foo')
    end
  end

  describe 'random_name' do
    it 'is 8 characters and alphanumeric' do
      expect(Pushpop.random_name).to match(/^\w{8}$/)
    end
  end

end
