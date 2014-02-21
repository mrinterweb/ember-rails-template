#!/usr/bin/env ruby
require 'bundler/setup'

AVAILABLE_GENERATORS = %w[component controller model resource route template view]
unless AVAILABLE_GENERATORS.include?(ARGV[0])
  puts "available generators are: #{AVAILABLE_GENERATORS.join(', ')}"
  exit 1
end

unless ARGV[1] =~ /[a-z\-0-9]+/i
  puts "Please see the documentation for what the second argument should look like"
  puts `rails generate ember:#{ARGV[0]} --help`
  exit 1
end

gen  = ARGV.shift
name = ARGV.shift
puts `rails generate ember:#{gen} #{name} #{ARGV.join(' ')}`
