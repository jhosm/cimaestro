= cimaestro

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

  1. Install Ruby with RubyInstaller for Windows.
  2. In order to build gem's native extensions:
        Install DevKit, available on the the RubyInstaller site.
  3. gem install rake
  4. gem install bundler
  5. bundle install 

UBUNTU

  1.  Install Ruby Version Manager
  2.  In order to be able to build cimaestro with rake:
        rvm package install openssl
  3.   If it throws an error:
        Probably you don't have zlib1g-dev installed. In Ubuntu, use sudo apt-get install zlib1g-dev.
  4.  In order to be able to install gems (Don't worry if it throws an error):
        rvm package install zlib.
  5.  rvm install 1.8.7 --with-openssl-dir=$HOME/.rvm/usr
  6.  rvm use 1.8.7
  7.  If step 4 throwed and error, follow the steps depicted in the solution section at https://gist.github.com/469647.
  6.  rvm gemset create cimaestro
  7.  rvm gemset use cimaestro
  8.  gem install bundler
  9.  cd to cimaestro directory
  10. bundle install --local --binstubs [GEM_HOME]/bin. to know GEM_HOME value, type rvm info.

ALL

After the previous platform-specific steps do:
  $ rake cimaestro:default (all the tests should pass)

To create a new cimaestro gem:
  $ Make sure Manifest.txt contains all the files to be contained in the gem
  $ At the CIMaestro project root directory:
    $ Do a "bundle pack" (check bundler site for more info)
    $ run "rake gem", and the gem file will be in the "pkg" directory.

== LICENSE:

  FIX (choose license)


