= cimaestro

* http://www.cimaestro.com

== DESCRIPTION:

CIMaestro is a rake-based build system, with a heavy bias on convention over configuration. It has three main goals:
* To be dead simple to use. CIMaestro should be transparent to the team's day-to-day routines;
* To gently nudge the team in the right direction, helping them to learn more about their application, to comprehend
and follow the best practices of their trade, and thus, to build a high quality product.
* To automate all that can be automated to ensure a high-quality application. If you want it to be done, it has to
be completely automated.

== FEATURES:

CIMaestro has the following major features:
* Consistency
    * It gives a consistent structure to your projects,
* Versioning
    * CIMaestro applies the build version to the source code as well as to the publish artifacts (sites, components),
    ensuring the installed artifacts on a given environment (notably Production) area traceable to the sources
* XML
    * Verifies well-formedness
    * Removes whitespace (useful it you're sending XML over the wire)
    * Merges and versions XSLT files (useful if you're sending XSLT to be executed on the browser)
* Javascript
    * Ensures javascript files are syntactically valid
    * Minifies javascript files
    * Merges all the referenced javascript file on a web page into one (useful to minimize the number of browser
    requests)
* CSS
    * Merges and versions css files referenced on a web page into one
* Dependencies
    * Ensures you sources are compiled against the correct dependencies
* Compilation
    * Compiles you sources
* .Net specific
    * Ensures all your .Net artifacts share common assembly attributes like version or copyright notices
    * Creates a version binding policy for your strong named assemblies (useful when you want to ensure your team uses a certain version of an assembly)
* Quality assurance
    * Runs Unit Tests (including Javascript)
    * Does a static analysis of the sources
    * Gathers metrics from the sources
    * Is is possible to set thresholds that must be met for the build to be successful
    * The thresholds are updated automatically when you raise the base. If you achieve a certain quality, you don't want to let it degrade
* Publishing
    * Puts your artifacts on a well-know location with a consistent structure

== SYNOPSIS:

  At the command line, type:
  $ cimaestro

== REQUIREMENTS:

* Ruby... :)
* bundler gem
* All the 3rd tools that you want to use in your build process

== INSTALL:

* gem install cimaestro
* cimaestro install -h,
    and follow the instructions.

== DEVELOPERS:

After cloning the git repo (git@github.com:jhosm/cimaestro.git) to your file system, run:

WINDOWS

  $ Install Ruby with RubyInstaller for Windows.
  $ In order to build gem's native extensions:
        Install DevKit, available on the the RubyInstaller site.

UBUNTU

  $ Install Ruby Version Manager
  $ In order to be able to install gems:
        rvm package install zlib. If it gives an error, follow the steps depicted in the solution section at https://gist.github.com/469647.
  $ In order to be able to build cimaestro with rake:
        rvm package install openssl
  $ rvm install 1.8.7 --with-openssl-dir=$HOME/.rvm/usr
  $ rvm gemset create cimaestro
  $ rvm gemset use cimaestro
  $ gem install bundler
  $ cd to cimaestro directory
  $ bundle install --local.

ALL

After the previous platform-specific steps do:
  $ bundle exec rake verify_rcov, and all the tests should pass

To create a new cimaestro gem:
  $ Make sure Manifest.txt contains all the files to be contained in the gem
  $ At the CIMaestro project root directory:
    $ Do a "bundle pack" (check bundler site for more info)
    $ run "rake gem", and the gem file will be in the "pkg" directory.

== LICENSE:

  FIX (choose license)


