require 'pry'
require 'readline'

module Color
  COLORS = %w[black red green yellow blue magenta cyan white]
  COLORS.each_with_index do |color, i|
    define_method(color.to_sym) do |str|
      wrapper(i, str)
    end
  end

  def color(str, color)
    unless color.kind_of?(Integer)
      color = COLORS.find_index(color.to_s)
    end
    wrapper(color.to_s, str)
  end

  private

  def wrapper(color_code, str)
    "\033[3#{color_code}m#{str}\033[0m"
  end

end

class Prompt
  include Color
  class InvalidResponse < StandardError; end
  class EmptyResponse < StandardError; end

  def initialize(question, color=nil, options={})
    @question = question
    @color = color || :yellow
    @options = options
  end

  def yes_no(options={})
    set_options(options)
    accepted_answers = %w[yes no y n]
    answer = ask do
      validate(prompt, accepted_answers)
    end
    %w[y yes].include?(answer)
  end

  # for some reason HighLine verify was not working so I wrote this
  def ask_and_verify(conditions=nil, options={})
    set_options(options)
    conditions ||= @options[:conditions]
    ask do
      if conditions.kind_of?(Array)
        putsc "available selections:"
        conditions.each_with_index do |con, i|
          putsc "#{i+1}: #{con}"
        end
      end
      validate(prompt, conditions)
    end
  end

  def ask(options={}, &block)
    set_options(options)
    default = @options[:default]
    max_retry = 5
    default_str = default ? " |#{default}|" : ""
    begin
      putsc @question+default_str, @color
      yield
    rescue InvalidResponse => e
      max_retry -= 1
      if max_retry > 0
        putsc @options[:error] || e.message
        retry
      else
        putsc "you may be confused. Get your head straight", :red
        exit 1
      end
    end
  end

  private

  def prompt
    Readline.readline
  end

  def putsc(str, color_sym=:yellow)
    puts color(str, color_sym)
  end

  def validate(answer, accepted_answers)
    return @options[:default] if answer.blank? and @options[:default]
    case accepted_answers.class.name
    when 'Regexp'
      unless answer =~ accepted_answers
        raise InvalidResponse, "Answer must match format #{accepted_answers}"
      end
    when 'Array'
      if answer.kind_of?(String) && answer =~ /^[0-9]+$/
        answer = accepted_answers[answer.to_i - 1] 
      end
      unless accepted_answers.include?(answer)
        raise InvalidResponse, "Please answer with one of the following: #{accepted_answers.join(', ')}"
      end
    else
      raise "unexpected accepted_answers type: #{accepted_answers.class.name}"
    end
    answer
  end

  def set_options(options)
    if !options.empty? || @options.nil?
      @options = options
    end
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
      raise 'position must be an integer, :beginning, :end'
    end
    self
  end
  
  def comment(pattern, options={})
    comment_type = options[:comment_type] || :ruby
    comment_types = { ruby: '#', javascript: '//', coffeescript: '#' } 
    i = find_index(pattern)
    lines[i] = "#{comment_types[comment_type]} #{lines[i]}" if i
    self
  end

  def delete_line(pattern)
    i = find_index(pattern)
    lines.delete_at i if i
    self
  end

  def write!
    File.write(@path, lines.join)
  end

  def find_index(matcher)
    proc = case matcher.class.name
    when 'Regexp'
      ->(l) { l =~ matcher }
    when 'String'
      ->(l) { l == matcher }
    end
    lines.find_index(&proc)
  end

  private

  def lines
    @lines ||= File.readlines(@path)
  end

end

FileManipulator.new('Gemfile').
  comment(/gem.+jquery\-rails/).
  comment(/gem.+turbolinks/).
  comment(/gem.+jbuilder/).
  write!

# ----------------------- Question and Answer Time --- START
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

answers = OpenStruct.new

class Pretty
  include Color
end
pretty = Pretty.new

edge_ember_template_path = File.join(File.dirname(__FILE__), 'edge_template.rb')
unless File.exists?(edge_ember_template_path)
  edge_ember_template_path = 'https://raw2.github.com/mrinterweb/ember-rails-template/master/edge_template.rb'
end
puts "Slightly modified edge_template path: #{edge_ember_template_path}"
if answers.use_edge_template = Prompt.new("Would you like to install a slightly modified template based on the one found at http://emberjs.com/edge_template.rb").yes_no(default: 'y')
  run "rake rails:template LOCATION=#{edge_ember_template_path}"
end

bower_installed = false
if system('which bower')
  bower_installed = true
else
  answers.install_bower = Prompt.new('Would you like for bower to be installed?').yes_no(default: 'y')
end
answers.use_rspec = Prompt.new('Would you like to use rspec').yes_no(default: 'y')
if answers.use_rspec
  puts pretty.color("Take a look at this:\n#{rspec_config_options}", :yellow)
  puts pretty.color("Now imagine it in your config/application.rb", :yellow)
  answers.insert_rspec_config_options = Prompt.new("Is it ok if I add that to config/application.rb?").yes_no(default: 'y')
  unless answers.insert_rspec_config_options
    puts "Ok. I understand. I won't mess with that file."
  end
end

answers.use_coffeescript = Prompt.new('Would you like to use CoffeeScript?').yes_no(default: 'y')
puts "I see that you're cool like me :)" if answers.use_coffeescript

rails_app_name = File.basename(Rails.root.to_s).camelize
puts pretty.color("Now it's time to pick your Ember application name. I'd recommend something short and sweet.", :yellow)
puts pretty.color("This name will be all over your code.", :yellow)
if Prompt.new("Do you want your ember app to be named: #{rails_app_name}? If no, we'll ask next.").yes_no(default: 'y')
  answers.ember_app_name = rails_app_name
else 
  answers.ember_app_name = Prompt.new("What would you like your Ember app named? (maybe just plain old: App)").ask_and_verify(/^[a-z\-_]+$/i, error: 'Must contain any of the following: letters, numbers, -, _', default: 'App')
end

answers.install_ember = Prompt.new('Would you like to install ember.js and dependencies?').yes_no(default: 'y')
if answers.install_ember
  answers.ember_channel = Prompt.new("What version of ember would you like to install?").ask_and_verify(%w[release beta canary])
  # answers.ember_channel = choose do |c|
  #   c.prompt = pretty.color("What version of ember would you like to install?", :yellow)
  #   c.choices(*%w[release beta canary])
  # end
  if %w[beta canary].include?(answers.ember_channel)
    answers.install_ember_data = Prompt.new("Do you want ember-data as well?").yes_no(default: 'y')
  else
    answers.install_ember_data = false
  end
  answers.jquery_version = Prompt.new("Pick your jquery version. (1.10.x is more compatible. 2.0.x is best for \"modern\" browsers)").
    ask_and_verify(['1.10.2', '2.0.3'])
  # answers.jquery_version = choose do |c|
  #   c.prompt = "Pick your jquery version. (1.10.x is more compatible. 2.0.x is best for \"modern\" browsers)"
  #   c.choices('1.10.2', '2.0.3')
  # end
end
answers.install_teaspoon = Prompt.new('How about I install guard and teaspoon to run your ember application tests with QUnit?').yes_no(default: 'y')
answers.install_phantomjs = Prompt.new('Would you like to install phantomjs?').yes_no(default: 'y')
# ----------------------- Question and Answer Time --- END

# ----------------------- Bower and Node --- START
if answers.install_bower
  puts "Could not find npm executable: bower
  http://bower.io
  This template uses bower to manage installing JavaScript dependencies."

  if system('which npm')
    puts "looks like node and npm are already installed."
    if answers.install_bower
      if response = system('npm install -g bower')
        puts "bower was successfully installed"
        bower_installed = true
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
# ----------------------- Bower and Node --- END

# ----------------------- phantomjs --- START
phantomjs_installed = false
if answers.install_phantomjs
  if system('which phantomjs')
    puts "phantomjs already installed"
    phantomjs_installed = true
  else
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
# ----------------------- phantomjs --- END

# ----------------------- install gems --- START
# check if ember-rails gem is available


fm = FileManipulator.new('Gemfile')
gem 'active_model_serializers' unless fm.find_index(/gem.+active_model_serializers/)
gem 'ember-rails' unless fm.find_index(/gem.+ember-rails/)
gem 'ember-source' unless fm.find_index(/gem.+ember-source/)

gem_group :development, :test do
  gem 'rspec-rails' if answers.use_rspec
  gem 'teaspoon' if answers.install_teaspoon
  gem 'guard-teaspoon' if answers.install_teaspoon
  gem 'phantomjs' if phantomjs_installed
end

gem_group :test do
  gem 'guard' if answers.install_teaspoon
  gem 'guard-rspec' if answers.use_rspec
end

puts pretty.color("Installing gems. Please be patient.", :green)
run_bundle
# ----------------------- install gems --- END

# ----------------------- rspec --- START
if answers.use_rspec
  generate 'rspec:install'
  if answers.insert_rspec_config_options
    FileManipulator.new('config/application.rb').insert_after(/ < Rails::Application/, rspec_config_options).write!
  end
end
# ----------------------- rspec --- END

# ----------------------- ember-rails --- START

# add the ember app name to config/application
FileManipulator.new('config/application.rb').
  insert_after(/ < Rails::Application/, "    config.ember.app_name = '#{answers.ember_app_name.camelize}'").write!

puts "boostraping ember"
generate "ember:bootstrap", "-n #{answers.ember_app_name}", "-je #{answers.use_coffeescript ? 'coffee' : 'js'}"
if answers.use_coffeescript
  remove_file 'app/assets/javascripts/application.js'
  application_coffee = 'app/assets/javascripts/application.js.coffee'
  # add jquery at the beginning of 
  puts "adding require jquery to #{application_coffee}"
  FileManipulator.new(application_coffee).
    insert(:beginning, '#= require jquery').write!
end

# ----------------------- ember-rails --- START
puts "Now let's fetch the ember libs"
if answers.install_ember
  generate "ember:install", "--channel=#{answers.ember_channel}", ('--ember-only' if answers.install_ember_data)
  if bower_installed
    run "bower install jquery##{answers.jquery_version}"
  else
    puts pretty.color("Bower is not installed you are going to need download jquery yourself", :red)
  end
end
# ----------------------- ember-rails --- END

# ----------------------- teaspoon --- START
if answers.install_teaspoon
  run 'guard init'
  if answers.use_rspec
    # the QUnit generator is nasty and only installs for TestUnit
    # So now for some fun getting it to work with rspec
    generate "teaspoon:install", (' --coffee' if answers.use_coffeescript)

    path = 'config/initializers/teaspoon.rb'
    File.write(path, File.read(path).gsub('teaspoon-jasmine', 'teaspoon-qunit'))

    # set teaspoon so it doesn't start on a random port
    # path = 'spec/teaspoon_env.rb'
    # File.write(path, File.read(path).sub(/#(config.server_port\s+)= nil/, "#{$1}= 3100"))
  else
    generate "teaspoon:install", "--framework=qunit", ('--coffee' if answers.use_coffeescript)
  end
end
# ----------------------- teaspoon --- END

# ----------------------- genember bin stub --- START
genember_target = 'genember'
unless File.exists?(genember_target)
  source_genember = File.join(File.dirname(__FILE__), 'genember.rb')
  if File.exists?(source_genember)
    file genember_target, File.read(source_genember)
  else
    # go fetch it from github
    require 'open-uri'
    file genember_target, open('https://raw2.github.com/mrinterweb/ember-rails-template/master/genember.rb').read
  end
  puts 'Just added a handy shortcut to "rails generate ember:* *" called genember as a binstub.'
end
unless File.executable?(genember_target)
  File.chmod(0755, genember_target)
end
if system "ln -s app/assets/javascripts js"
  puts "just added a symlink to your javascripts folder. It's a time saver"
end
# ----------------------- genember bin stub --- END

