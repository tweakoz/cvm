C/C++ Version Manager
=====================

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

First, I use a lot of libraries that need to be installed on the server as well. Ubuntu has packages for most of them, but they are outdated for me. So I need to download the sources and recompile the latest version...

...in fact no ! Not the latest version but the same exact version my app is currently using. Which version was it already ?

Then one of the lib needs another lib with another specific version requirement. So I not only need to install it as well, but I must also pass its emplacment to the other lib, or it would try to use the old system one instead...

One of the lib needs the cmake tool. Of course, the default system version is too old. So I need to download and recompile cmake...

Then cmake detects the system libraries and not the recent one I just installed... Aaaaaaaaaaaargh !!!

(...and so on for a lot of libs and tools...)

Oh, and I'm also planning to use latest gcc 4.7 to play with C++ 2011. Just thinking of the future pain nearly depress me...

One more thing : I want to try the GNU standard lib "debug mode" which require recompilation of... just every lib !

You got it. It's not only tiring to manually install and recompile everything again and again for each server install, it's just *impossible* at some level.

So I thought to automatize it.

I used to do some rails development, and I had a tool called "Ruby Version Manager" (RVM) which, together with an util called "Bundler" was doing exactly that for Ruby.

A quick look on the internet showed no existing tool/competitor --> Let's do this !!



Installation
============

Requirements
------------
C++VM is in pure shell. (Would have been a heresy to use python ;)
C++VM need the Offirmo Shell Library  : https://github.com/Offirmo/offirmo-shell-lib

Installation
------------
Get a copy of the files and set your path to point to the "bin" dir.

Check if it works by typing : (after relaunching your shell for the PATH alteration to take effect of course !)

 `cvm`

It should display some help.


Usage
=====
write a "compfile" (component file) like this one, for a Wt app :

    ## C++ VM component set definition
    ## see https://github.com/Offirmo/cvm
    ##
    ## Thanks to this file and the C++VM tool,
    ## all exact dependencies are installed.
    
    c++vm_minimum_required_version 1.0.1
    
    # if no particular gcc version is required
    # let's use the system one
    require compiler.gcc,   version : system
    require lib.std,        version : system
    
    require lib.UnitTest++, version : 1.4+
    
    # need a recent version
    require lib.Boost,      version : 1.51+
    
    # sqlite is an optional dependency of Wt. We want a decent version.
    require lib.sqlite,      version : 3.7+
    # we worked with an exact version of Wt
    require lib.Wt,         version : 2.3.2, require : lib.sqlite

then type :

    `cvm new wtapp01`
    `cvm set_compfile <your compfile>`
    `cvm upgrade`

You may now build your app, wrapped by cvm to make the new libs available.

Example with make : `cvm_exec make`

Example with cmake :

    `cvm_exec cmake -Wdev ../myapp`
    `cvm_exec make`
    `cm_exec <call to your freshly built app>`

An interesting command is : `cvm status`


Currently available components
==============================

Libs
----

 - Boost
 - bzip2
 - graphicmagic
 - python-dev
 - sqlite
 - UnitTest++
 - Wt
 - zlib

Tools
-----

 - autotools
 - cmake
 - git
 - 

Coming soon
-----------

 - svn
 - mysql
 - postgresql
 - python
 - python_setuptools

TODO
====

- Better doc ;)

