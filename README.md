C/C++ Version Manager
=====================

C/C++ Version Manager. A tool for automatically managing your C/C++ dependencies :
- compiler
- libraries
- misceanellous build tools
Each component is automatically installed with specific versions and modes (debug/release).

Inspired from the great RVM (Ruby Version Manager) : https://rvm.io// and the Bundler tool : http://gembundler.com/gemfile.html

- cvm is available at : https://github.com/Offirmo/cvm
- Slideshow presenting the tool : http://fr.slideshare.net/Offirmo/introducing-cvm
- cvm has a tracker : https://www.pivotaltracker.com/projects/710241



Introduction 
============

The user story
--------------
Right now I'm writing a C++ app. It is ready to be deployed to the production server. Unfortunately...

First, I use libraries that need to be installed as well. Ubuntu has packages for most of them, but they are outdated in this case. So I need to install them from source, latest version...

...in fact no ! Not the latest version but the same exact version my app is currently using. Which version was it already ?

Then one of the libs needs another lib with another specific version requirement. So I not only need to install it as well, but I must also pass its emplacment to the other lib, or it would try to use the system one instead...

One of the lib needs the cmake tool. Of course, the default system version is too old. So I need to download and recompile cmake...

Then cmake, when compiling the lib, detects the system libraries and not the recent one I just installed... Aaaaaaaaaaaargh !!!

(...and manx more problems for a lot of libs and tools...)

Oh, and I'm also planning to use latest gcc 4.7 to play with C++ 2011. Or maxbe cjang. Just thinking of the future pain of recompiling everything nearly depress me...

One more thing : I want to try the GNU standard lib "debug mode" which require recompilation of... just every lib !

You got it. It's not only tiring to manually install and recompile everything again and again for each server install, it's just *impossible* at some level.

So I thought to automatize it.

I used to do some rails development, and I had a tool called "Ruby Version Manager" (RVM) which, together with an util called "Bundler" was doing exactly that for Ruby.

A quick look on the internet showed no existing tool/competitor --> Let's do this !!



Installation
============

Requirements
------------
cvm is in pure shell. (Would have been a heresy to use python ;)

Installation
------------
Get a copy of the files and set your path to point to the "bin" dir.

Check if it works by typing : (after relaunching your shell for the PATH alteration to take effect of course !)

 `cvm`

It should display some help.
If it does not, check that 


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

