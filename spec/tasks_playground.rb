$: << File.join(File.dirname(__FILE__), "..")
require '../lib/cimaestro'
include Build

build_spec = BuildSpec.new("../../../../../_Projectos", "aSystem", "Release", "1.5.8.7")

task = PurgeTask.new "purge_task", build_spec, ConsoleLogger.new
task.setup
task.execute
