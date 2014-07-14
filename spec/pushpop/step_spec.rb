require 'spec_helper'

SPEC_TEMPLATES_DIRECTORY ||= File.expand_path('../../templates', __FILE__)

describe Pushpop::Step do

  describe 'initialize' do

    it 'sets a name, a plugin, and a block' do
      empty_proc = Proc.new {}
      step = Pushpop::Step.new('foo', 'foopie', &empty_proc)
      expect(step.name).to eq('foo')
      expect(step.plugin).to eq('foopie')
      expect(step.block).to eq(empty_proc)
    end

    it 'auto-generates a name if not given and plugin not given' do
      empty_proc = Proc.new {}
      step = Pushpop::Step.new(&empty_proc)
      expect(step.name).not_to be_nil
      expect(step.plugin).to be_nil
      expect(step.block).to eq(empty_proc)
    end

    it 'sets name to plugin name if not given' do
      empty_proc = Proc.new {}
      step = Pushpop::Step.new(nil, 'whee', &empty_proc)
      expect(step.name).to eq('whee')
      expect(step.plugin).to eq('whee')
      expect(step.block).to eq(empty_proc)
    end

    it 'does not require a plugin' do
      empty_proc = Proc.new {}
      step = Pushpop::Step.new('foo', &empty_proc)
      expect(step.name).to eq('foo')
      expect(step.block).to eq(empty_proc)
    end

  end

  describe 'run' do

    it 'calls the block with the same args' do
      arg1, arg2 = nil
      times_run = 0
      empty_proc = Proc.new { |a1, a2| arg1 = a1; arg2 = a2; times_run += 1 }
      step = Pushpop::Step.new('foo', &empty_proc)
      step.run('foo', 'bar')
      expect(arg1).to eq('foo')
      expect(arg2).to eq('bar')
      expect(times_run).to eq(1)
    end

    it 'executes the block bound to the step' do
      _self = nil
      step = Pushpop::Step.new(nil, nil) do
        _self = self
      end
      step.run
      expect(_self).to eq(step)
    end

  end

  describe 'template' do
    it 'renders the named template with the response binding' do
      step = Pushpop::Step.new
      expect(step.template('spec.html.erb', 500, {}, SPEC_TEMPLATES_DIRECTORY).strip).to eq('<pre>500</pre>')
    end

    it 'renders the named template with the step_response binding' do
      step = Pushpop::Step.new
      expect(step.template('spec.html.erb', nil, { test: 600 }, SPEC_TEMPLATES_DIRECTORY).strip).to eq('<pre>600</pre>')
    end
  end

end
