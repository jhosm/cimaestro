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
$:.unshift "spec"

require 'lib/required_references'

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
  Spec::Rake::SpecTask.new(:spec_and_rcov) do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ['--options', 'spec/spec.opts']
    t.rcov = true
    t.rcov_dir = 'coverage'
    t.rcov_opts = ['--exclude', "features,kernel,load-diff-lcs\.rb,instance_exec\.rb,^spec/*,bin/spec,examples,/gems,/Library/Ruby,#{ENV['GEM_HOME']},JetBrains"]
    t.rcov_opts << '--sort coverage --text-summary --aggregate coverage.data'
  end


  RCov::VerifyTask.new(:verify_rcov => 'cimaestro:spec_and_rcov') do |t|
    t.threshold = 81.8
    t.index_html = 'coverage/index.html'
  end

  task 'install' do
    sh 'rake gem'
    sh "gem install pkg/cimaestro-#{CIMaestro::CIMaestro::VERSION}.gem"
  end
end
