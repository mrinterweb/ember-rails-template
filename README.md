ember-rails-template
====================

This template is an interactive configuration that will help get your rails application all set up for ember development.

    rake rails:template https://raw2.github.com/mrinterweb/ember-rails-template/master/ember-template.rb

This has only been tested with modifying existing rails apps.

Since the template prompts with questions about how you want to set up your app, it installs the highline gem first, and then exits. This means you need to run bundle install. Then, rerun the rake same task.

Some of the stuff this template can do: install bower, phantomjs, rspec, ember-rails, guard, teaspoon (with QUnit), download recent ember libs with jquery.

If you're starting with a new rails app, I'd recommend starting with this:

    rails new app --skip-javascript --skip-test-unit --template "http://emberjs.com/edge_template.rb"
