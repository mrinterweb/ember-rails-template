ember-rails-template
====================

This template is an interactive configuration for existing rails applications that will help get your application all set up for ember development with [ember-rails](https://github.com/emberjs/ember-rails). The template asks you questions about how you would like your application configured and then configures your application accordingly.

I made this template because I realized that getting a rails project fully configured with ember-rails was not quite as easy as I had hoped. There are more things to do, and this template is the quickest and easiest way to get everything else configured.

Usage
=====

    rake rails:template LOCATION=https://raw2.github.com/mrinterweb/ember-rails-template/master/ember-template.rb

Some of the stuff this template can do (based on your choices): 

* install the emberjs.com/edge_template.rb
* clean up your gemfile (goodbye turbolinks)
* install gems
* configuraiton for CoffeeScript or JavaScript
* install bower
* phantomjs
* rspec
* set up ember-rails
* guard
* teaspoon with QUnit (JavaScript testing suite)
* download recent ember libs with the correct version of jquery
* adds a handy generator shortcut
* and more!

If you're starting with a new rails app, I'd recommend starting with this:

    rails new my_project --skip-javascript --skip-test-unit

* <sub>Since the JavaScript dependencies are managed for you by the template, you can skip them.</sub>
* <sub>Skip the test unit only if you plan on not using test unit.</sub>

Watch the thrilling screencast!
==============================
[![Youtube ScreenShot](https://img.youtube.com/vi/KaBbGUVQrAw/0.jpg)](https://www.youtube.com/watch?v=KaBbGUVQrAw&feature=youtu.be)

The template no longer requires the highline gem dependency.

Q&A
===

### How does this compare with ember-appkit-rails?

I prefer writing CoffeeScript to JavaScript. Ember AppKit Rails assumes that all the files you will be writing will be js files, and the file extension changes from ".js" to ".es6". There is a keyword conflict between CoffeeScript and ES6 modules "require" & "import". CoffeeScript does not get much love from the ES6 transpiler so I tend to avoid ES6 modules until better CoffeeScript support is added. I understand the need for dependency management, but I don't believe in alienating a large group of users just so ES6 modules can be used. Since the template does not currently help configure any dependency management that remains a responsibility of the user.

Also I do not prefer how Ember AppKit Rails adds ember javascript folders directly into app instead of app/assets/javascripts. This means that your models and controller directories are no longer just for ruby files. I do not find that this plays nicely with existing rails applications and conflicts with rails conventions.

### How do I ask a question about ember-rails-template or request a feature?

Ask me on Twitter [@mrinterweb](https://twitter.com/mrinterweb), or ask me on [reddit](http://www.reddit.com/r/emberjs/comments/1ym4w4/rails_template_that_helps_configure_emberrails/)

Thoughts
========

After getting further into this I started thinking that I should just merge this into ember-rails. It would take a decent amount of refactoring to get this into ember-rails. I also learned a thing or two about rails templates. Writing my own CLI class in place of highline was entertaining.
