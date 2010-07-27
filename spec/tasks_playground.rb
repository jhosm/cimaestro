$: << File.join(File.dirname(__FILE__), "..")
require '../lib/cimaestro'
include Build

build_spec = BuildSpec.new("aSystem", "Release", "1.5.8.7")
build_spec.base_path = "../../../../../_Projectos"

task = PurgeTask.new "purge_task", build_spec, ConsoleLogger.new
task.setup
task.execute
