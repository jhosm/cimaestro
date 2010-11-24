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
$:.unshift "rspec"

require 'required_references'

namespace :cimaestro do
  desc "do a full build"
  task :default => [:clean_rcov_files, :clean_rspec_files, :verify_rcov]

  desc "Clean up intermediate files of rcov"
  task :clean_rcov_files => 'spec_and_rcov' do
    rm_rf 'coverage.data'
  end

  desc "Clean up intermediate files of rspec"
  task :clean_rspec_files => 'spec_and_rcov' do
    rm Dir.glob('*sh_log.txt')
    rm Dir.glob('_config.yaml')
    rm_rf 'lib/_Projectos'
  end
  
  desc "Run all specs with rcov"
  RSpec::Core::RakeTask.new(:spec_and_rcov) do |t|
    t.pattern = 'rspec/**/*_spec.rb'
#    t.rspec_opts = ['--colour', '--format', 'profile', '--timeout', '20', '--diff']
    t.rspec_opts = ['--colour', '--format', 'progress']
    t.rcov = true
    t.rcov_path = 'rcov'
    t.rcov_opts = ['--exclude', "features,kernel,load-diff-lcs\.rb,instance_exec\.rb,^spec/*,bin/spec,examples,/gems,/Library/Ruby,/System/Library/,/Applications/RubyMine,^.rvm/rubies*,#{ENV['GEM_HOME']},JetBrains"]
    t.rcov_opts << '--sort coverage --text-summary --aggregate coverage.data --failure-threshold 60'

  end

  desc "Verify and run all with rcov"
  task :verify_rcov => 'spec_and_rcov' do
  end

#  Rcov::RcovTask.new(:verify_rcov => 'cimaestro:spec_and_rcov') do |t|
#    t.threshold = 78.42
#    t.index_html = 'coverage/index.html'
#  end

  task 'install' do
    sh 'rake gem'
    sh "gem install pkg/cimaestro-#{CIMaestro::CIMaestro::VERSION}.gem"
  end
end
