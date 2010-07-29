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
    * Creates a version binding policy for your strong named assemblies (useful when you want to ensure your team uses a
    certain version of an assembly)
* Quality assurance
    * Runs Unit Tests (including Javascript)
    * Does a static analysis of the sources
    * Gathers metrics from the sources
    * Is is possible to set thresholds that must be met for the build to be successful
    * The thresholds are updated automatically when you raise the base. If you achieve a certain quality, you don't want
    to let it degrade
* Publishing
    * Puts you artifacts on a well-know location with a consistent structure

== SYNOPSIS:

  FIX (code sample of usage)

== REQUIREMENTS:

* Ruby... :)
* All the 3rd tools that you want to use in your build process

== INSTALL:

* gem install cimaestro
* cimaestro -s [gempath],
    where gempath is the location where you want to put the gems upon CIMaestro depends. If you
    don't give gempath, then it installs them on a private location.

== DEVELOPERS:

After checking out the source (git@github.com:jhosm/cimaestro.git), run:

  $ bundle install, on the home directory
  $ rake verify_rcov, and all the tests should pass

== LICENSE:

  FIX (choose license)


