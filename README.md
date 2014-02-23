ember-rails-template
====================

This template is an interactive configuration that will help get your rails application all set up for ember development with ember-rails. The template asks you questions about how you would like your application configured and then configures your application accordingly.

I made this gem because I realized that getting a rails project fully configured with ember-rails was not quite as easy as I had hoped. There are more things to do, and this template is the quickest and easiest way to get everything else configured.

Usage
=====

    rake rails:template LOCATION=https://raw2.github.com/mrinterweb/ember-rails-template/master/ember-template.rb

Some of the stuff this template can do: 

* clean up your gemfile (goodbye turbolinks)
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

Watch the thrilling screencast!
==============================
[![Youtube ScreenShot](https://img.youtube.com/vi/KaBbGUVQrAw/0.jpg)](https://www.youtube.com/watch?v=KaBbGUVQrAw&feature=youtu.be)

The template no longer requires the highline gem dependency.

Thoughts
========

After getting further into this I started thinking that I should just merge this into ember-rails. It would take a decent amount of refactoring to get this into ember-rails. I also learned a thing or two about rails templates. Things like, there are easier ways to prompt the user and insert things into files.
