C/C++ Version Manager
=====================

*XXX this project is under active development and is not yet usable XXX*

C/C++ Version Manager is a tool for managing/installing all the dependencies/components of a C/C++ app :
- compiler
- libraries
- misceanellous build tools

Each component is automatically installed with required version and mode (debug/release).

Inspired from the great RVM (Ruby Version Manager) : https://rvm.io// and the Bundler tool : http://gembundler.com/gemfile.html

C++VM is available at : https://github.com/Offirmo/cvm

C++VM has a redmine : http://www.hostedredmine.com/projects/cvm




Introduction 
============

The user story
--------------
Right now I'm writing a C++ web app (yes !). I try to deploy it on my ubuntu server. Unfortunately, it's not as simple as copying sources and compiling...

First, I use a lot of libraries that need to be installed on the server as well. Ubuntu has packages for most of them, but they are outdated. So I need to download the sources and recompile the latest version...

...in fact no ! Not the latest version but the same exact version my app is currently using. Which version was it already ?

Then one of the lib needs another lib with another specific version requirement. So I not only need to install it as well, but I must also pass its emplacment to the other lib, or it would try to use the old system one instead...

One of the lib needs the cmake tool. Of course, the default system version is too old. So I need to download and recompile cmake...

...and so on for a lot of libs and tools...

Oh, and I'm also planning to use latest gcc 4.7 to play with C++ 2011

One more thing : I want to try the GNU standard lib "debug mode" which require recompilation of... just every lib with it.

You got it. It's not only tiring to manually install and recompile everything again and again for each server install, it's just *impossible* at some level.

So I thought to automatize it.

I used to do some rails development, and I had a tool called "Ruby Version Manager" (RVM) which, together with an util called "Bundler" was doing exactly that for Ruby.

A quick look on the internet showed no existing tool/competitor --> Let's do this !!


Requirements
------------
C++VM is in pure shell.
C++VM need the Offirmo Shell Library  : https://github.com/Offirmo/offirmo-shell-lib

Installation
------------
Get a copy of the files and set your path to point to the "bin" dir.

Check if it works by typing : (after relaunching your shell for the PATH alteration to take effect of course !)

 `c++vm`

It should display some help.

Now you... TODO

TODO
====

- Better doc ;)

