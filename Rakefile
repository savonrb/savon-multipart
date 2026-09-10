# frozen_string_literal: true

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w[-c]
end

desc 'Run the spec suite'
task default: :spec

desc 'Run the spec suite'
task test: :spec
