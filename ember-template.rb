# require 'pry'

# ----------------------- highline gem --- START
begin
  require 'highline/import'
rescue LoadError
  gem_group :development do
    gem 'highline'
  end

  puts "just added the highline gem to your Gemfile"
  puts "please bundle install and rerun the rake command"
  exit 1
end
# ----------------------- highline gem --- END

class Prompt
  def initialize(question, color=nil)
    @question = question
    @color = color || :yellow
  end

  def yes_no(options={})
    agree(HighLine.color(@question, @color)) do |q|
      if default = options[:default]
        q.default = default
      end
    end
  end

  # for some reason HighLine verify was not working so I wrote this
  def ask_and_verify(condition=nil, options={}, &block)
    answer = nil
    loop do
      q_block = -> {}
      if default = options[:default]
        q_block = ->(q) { q.default = default }
      end
      answer = ask(HighLine.color(@question, @color), &q_block)

      case condition.class.name
      when 'Regexp'
        break if answer =~ condition
      when 'String'
        break if answer == condition
      when 'Array'
        break if condition.include?(answer)
      end

      if block_given? && block.call(answer)
        break
      end

      break if !block_given? and condition.nil?

      options[:error] ||= "Didn't get that. Try again."
      puts HighLine.color(options[:error], :red)
    end
    answer
  end

end

class FileManipulator

  def initialize(path)
    @path = path
    lines
  end

  def insert_before(matcher, subject)
    subject = "#{subject}\n"
    lines.insert(find_index(matcher), subject)
    self
  end

  def insert_after(matcher, subject)
    subject = "#{subject}\n"
    lines.insert(find_index(matcher) + 1, subject)
    self
  end

  def insert(position, subject)
    subject = "#{subject}\n"
    case position
    when :beginning
      lines.insert(0, subject)
    when Integer
      lines.insert(position, subject)
    when :end
      lines << subject
    else
      raise 'postion must be an integer, :beginning, :end'
    end
    self
  end

  def write!
    File.write(@path, lines.join)
  end

  private

  def find_index(matcher)
    proc = case matcher.class.name
    when 'Regexp'
      ->(l) { l =~ matcher }
    when 'String'
      ->(l) { l == matcher }
    end
    lines.find_index(&proc)
  end

  def lines
    @lines ||= File.readlines(@path)
  end

end

# a = Prompt.new('foo?').ask_and_verify(nil, default: 'bar')
# puts "answer: #{a}"
# exit 0
# ----------------------- .bowerrc --- START

# check for bower and optionally install bower
unless system('which bower')
  puts "Could not find npm executable: bower
  http://bower.io
  This template uses bower to manage installing javascript dependencies."

  if system('which npm')
    puts "looks like node and npm are already installed."

    if Prompt.new('Would you like for bower to be installed?').yes_no(default: 'y')
      if response = system('npm install -g bower')
        puts "bower was successfully installed"
      else
        puts "There was an error installing bower: #{response}"
        exit 1
      end
    else
      puts "All you should need to do to install bower is: npm install -g bower"
      exit 1
    end
  else
    puts "In order to install bower, you must have node installed and npm in your path"
    puts "Please consult documentation at http://nodejs.org/"
    exit 1
  end
end
  
file '.bowerrc', <<EOS
{
  "directory" : "vendor/assets/javascripts"
}
EOS

# ----------------------- .bowerrc --- END

# ----------------------- rspec --- START
use_rspec = Prompt.new('Would you like to use rspec').yes_no(default: 'y')
if use_rspec
  puts "I can tell that You make all kinds of great decisions, and likely prosper in life."
  gem_group :development, :test do
    gem 'rspec-rails'
  end
  run 'bundle install'
  generate 'rspec:install'

  rspec_config_options = <<-EOS
    config.generators do |gen|
      gen.test_framework :rspec,
                         fixtures: true,
                         view_specs: false,
                         helper_specs: false,
                         routing_specs: false
      gen.factory_girl true
    end
EOS
  puts "Take a look at this:\n#{rspec_config_options}"
  puts "Now imagine it in your config/application.rb"
  if Prompt.new("Is it ok if I add that to config/application.rb?").yes_no(default: 'y')
    FileManipulator.new('config/application.rb').insert_after(/ < Rails::Application/, rspec_config_options).write!
  else
    puts "Ok. I understand. I won't mess with that file."
  end
end
# ----------------------- rspec --- END

# ----------------------- ember-rails --- START
use_coffeescript = Prompt.new('Would you like to use CoffeeScript?').yes_no(default: 'y')
puts "I see that you're cool like me :)" if use_coffeescript

if !@app_name.blank? && Prompt.new("Do you want your ember app to be named: #{@app_name}? If no, we'll ask next.").yes_no(default: 'y')
  ember_app_name = @app_name
else 
  ember_app_name = Prompt.new("What would your Ember app named? (maybe just plain old: App)").ask_and_verify(/^[a-z\-_]+$/i, error: 'Must contain any of the following: letters, numbers, -, _', default: 'App')
end

puts "boostraping ember"
run "rails generate ember:bootstrap -n #{ember_app_name} -je #{use_coffeescript ? 'coffee' : 'js'}"
if use_coffeescript
  remove_file 'app/assets/javascripts/application.js'
  application_coffee = 'app/assets/javascripts/application.js.coffee'
  # add jquery at the beginning of 
  puts "adding require jquery to #{application_coffee}"
  FileManipulator.new(application_coffee).
    insert(:beginning, '#= require jquery').write!
end
# ----------------------- ember-rails --- START

puts "Now let's fetch the ember libs"
# ember_channel = Prompt.new("What version of ember would you like to install?").ask_and_verify(%w[release beta canary], default: 'release')
if Prompt.new('Would you like to install ember.js and dependencies?').yes_no(default: 'y')
  ember_channel = choose do |c|
    c.prompt = HighLine.color("What version of ember would you like to install?", :yellow)
    c.choices(*%w[release beta canary])
  end
  if %w[beta canary].include?(ember_channel)
    install_ember_data = Prompt.new("Do you want ember-data as well?").yes_no(default: 'y')
  else
    install_ember_data = false
  end
  run "rails generate ember:install --channel=#{ember_channel} #{install_ember_data ? '' : '--ember-only'}"

  jquery_version = choose do |c|
    c.prompt = "Pick your jquery version. (1.10.x is more compatible. 2.0.x is best for \"modern\" browsers)"
    c.choices('1.10.2', '2.0.3')
  end
  run "bower install jquery##{jquery_version}"
end


# ----------------------- teaspoon --- START
if Prompt.new('How about I install guard and teaspoon to run your ember application tests with QUnit?').yes_no(default: 'y')
  gem_group :test do
    gem 'guard'
    gem 'guard-rspec' if use_rspec
  end

  # I am still not sure why this also has to be in the development group
  gem_group :test, :development do
    gem 'teaspoon'
    gem 'guard-teaspoon'
  end

  run 'bundle install'
  run 'guard init'
  if use_rspec
    # the QUnit generator is nasty and only installs for TestUnit
    # So now for some fun getting it to work with rspec
    run "rails generate teaspoon:install#{use_coffeescript ? ' --coffee' : ''}"

    path = 'config/initializers/teaspoon.rb'
    File.write(path, File.read(path).gsub('teaspoon-jasmine', 'teaspoon-qunit'))

    # set teaspoon so it doesn't start on a random port
    # path = 'spec/teaspoon_env.rb'
    # File.write(path, File.read(path).sub(/#(config.server_port\s+)= nil/, "#{$1}= 3100"))
  else
    run "rails generate teaspoon:install --framework=qunit#{use_coffeescript ? ' --coffee' : ''}"
  end
end
# ----------------------- teaspoon --- END

# ----------------------- phantomjs --- START
phantomjs_installed = false
if Prompt.new('Would you like to install phantomjs?').yes_no(default: 'y')
  if system('which phantomjs')
    puts "phantomjs already installed"
    phantomjs_installed = true
  else
    puts 'It is recommended to install phantomjs'
    if Prompt.new('would you like to install phantomjs').yes_no(default: 'y')
      puts 'installing phantomjs. Please be patient'
      if response = system('npm install -g phantomjs')
        puts 'phantomjs installed'
        phantomjs_installed = true
      else
        puts "There was an error installing phantomjs: #{response}"
        exit 1
      end
    end
  end
end
if phantomjs_installed
  gem_group :development, :test do
    gem 'phantomjs'
  end
end
# ----------------------- phantomjs --- END


