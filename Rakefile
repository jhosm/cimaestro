# -*- ruby -*-
require 'rubygems'
require "bundler"
Bundler.setup

require 'hoe'
require 'rspec/core/rake_task'
require 'rcov'

#Hoe.spec 'cimaestro' do
#  developer('CIMaestro', 'cimaestro@googlegroups.com')
#end
$:.unshift "lib"
$:.unshift "spec"
require 'lib/required_references'

namespace :cimaestro do
  desc "do a full build"
  task :default => [:clean_rcov_files, :clean_rspec_files, :spec_and_rcov]

  desc "Clean up intermediate files of rcov"
  task :clean_rcov_files => 'spec_and_rcov' do
    rm_rf 'coverage.data'
  end

  desc "Clean up intermediate files of spec"
  task :clean_rspec_files => 'spec_and_rcov' do
    rm Dir.glob('*sh_log.txt')
    rm Dir.glob('_config.yaml')
    rm_rf 'lib/_Projectos'
  end
  
  desc "Run all specs with rcov"
  RSpec::Core::RakeTask.new(:spec_and_rcov) do |t|
    t.pattern = 'spec/**/*_spec.rb'
    t.rspec_opts = ['--colour', '--format', 'progress']
    t.rcov = true
    t.rcov_path = 'rcov'
    t.rcov_opts = '--exclude features,kernel,load-diff-lcs.rb,instance_exec.rb,^spec/*,bin/spec,.rvm,examples,/gems,/Library/Ruby,JetBrains '
    t.rcov_opts << '--sort coverage --text-summary --aggregate coverage.data --failure-threshold 78.6'

  end

  task 'install' do
    sh 'rake gem'
    sh "gem install pkg/cimaestro-#{CIMaestro::CIMaestro::VERSION}.gem"
  end
end
