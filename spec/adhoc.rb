$:.unshift "../lib"
require "required_references"
system_build_conf = BuildConfig.new
        global_build_conf = BuildConfig.new

        system_build_conf.system_name = "yourSystem"
        global_build_conf.system_name = "globaaallll"
        global_build_conf.base_path = "z:/"
        global_build_conf.source_control.repository_path = '\\wow'

        system_build_conf.merge!(global_build_conf)
        system_build_conf.system_name.should == "yourSystem"
        system_build_conf.base_path.should == "z:/"
        system_build_conf.source_control.repository_path == '\\wow'
