ember-rails-template
====================

This template is an interactive configuration that will help get your rails application all set up for ember development with ember-rails.

This is not your average Rails template. This thing will cook and serve you breakfast in bed.

I realized that getting a rails project fully configured with ember-rails was not quite as easy as I had hoped. That's why I made this handy dandy tool.

Usage
=====

    rake rails:template https://raw2.github.com/mrinterweb/ember-rails-template/master/ember-template.rb

This has only been tested with modifying existing rails apps.

Since the template prompts with questions about how you want to set up your app, it installs the highline gem first, and then exits. This means you need to run bundle install. Then, rerun the rake same task.

Some of the stuff this template can do: 

* clean up your gemfile (goodby turbolinks)
* install bower
* phantomjs
* rspec
* ember-rails
* guard
* teaspoon with QUnit (testing suite)
* download recent ember libs with jquery correct version of jquery
* adds a handy generator shortcut
* and more!

If you're starting with a new rails app, I'd recommend starting with this:

    rails new app --skip-javascript --skip-test-unit

Thoughts
========

After getting further into this I started thinking that I should just merge this into ember-rails. It would take a decent amount of refactoring to get this into ember-rails. I also learned a thing or two about rails templates. Things like, there are easier ways to prompt the user and insert things into files.
