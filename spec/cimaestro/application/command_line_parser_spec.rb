require "spec_helper"

module CIMaestro
  module Application
    class Parser
      include CommandLineParser
    end

    describe CommandLineParser do

      it "should parse switch options" do
        options_definition = { :switch => ['-s', '--switch', '']}

        result = Parser.new.parse(["--switch"], options_definition) do |parser, options, options_values|
          parser.on(* options[:switch]) { |specified| options_values[:switch] = specified }
        end
        result.switch.should be_true
      end

      it "should parse options without default values" do
        options_definition = { :mandatory => ['-m NAME', '--mandatory NAME', ''] }

        result = Parser.new.parse(["-m", "a_name"], options_definition) do |parser, options, options_values|
          parser.on(* options[:mandatory]) { |name| options_values[:mandatory] = name }
        end
        result.mandatory.should == "a_name"
      end

      it "should set a switch to false when it's not specified" do
        options_definition = { :switch => ['-s', '--switch', '']}

        result = Parser.new.parse([], options_definition) do |parser, options, options_values|
          parser.on(* options[:switch]) { |specified| options_values[:switch] = specified }
        end
        result.switch.should be_false
      end
    end
  end
end