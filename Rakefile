# frozen_string_literal: true

require 'rake/testtask'

desc 'Run all tests'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << '.'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
  t.warning = false
end

desc 'Run tests for MatchingType'
Rake::TestTask.new(:test_matching_type) do |t|
  t.libs << 'test'
  t.libs << '.'
  t.test_files = FileList['test/matching_type_test.rb']
  t.verbose = true
end

desc 'Run tests for CSVMatcher'
Rake::TestTask.new(:test_csv_matcher) do |t|
  t.libs << 'test'
  t.libs << '.'
  t.test_files = FileList['test/csv_matcher_test.rb']
  t.verbose = true
end

task default: :test
