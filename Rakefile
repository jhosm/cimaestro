# -*- ruby -*-

require 'rubygems'
require "bundler"
Bundler.setup

require 'hoe'
require 'spec/rake/verify_rcov'

Hoe.spec 'cimaestro' do
  developer('CIMaestro', 'cimaestro@googlegroups.com')
end

$:.unshift "lib"

namespace :cimaestro do
  desc "do a full build"
  task :default => [:cleanup_rcov_files, :verify_rcov]

  desc "Clean up intermediate files of rcov"
  task :cleanup_rcov_files do
    rm_rf 'coverage.data'
  end
  
  desc "Run all specs with rcov"
  Spec::Rake::SpecTask.new(:spec_and_rcov) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ['--options', 'spec/spec.opts']
    t.rcov = true
    t.rcov_dir = 'coverage'
    t.rcov_opts = ['--exclude', "features,kernel,load-diff-lcs\.rb,instance_exec\.rb,^spec/*,bin/spec,examples,/gems,/Library/Ruby,#{ENV['GEM_HOME']}"]
    t.rcov_opts << '--sort coverage --text-summary --aggregate coverage.data'
  end


  RCov::VerifyTask.new(:verify_rcov => 'cimaestro:spec_and_rcov') do |t|
    t.threshold = 78.5
    t.index_html = 'coverage/index.html'
  end
end
