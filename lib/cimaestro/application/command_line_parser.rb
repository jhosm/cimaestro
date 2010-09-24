module CIMaestro
  module Application
    module CommandLineParser

      def parse_options(parser, options, options_values)
        options.each do |name, definition|
          parser.on(*definition) do |value|
            if is_switch?(definition) then
              options_values[name] = true
            else
              options_values[name] = value
            end
          end
        end
      end

      def is_switch?(option_definition)
        option_definition[0].index(' ') == nil
      end

      def parse(args, options_definition_orig)
        options_definition = options_definition_orig.clone

        options =  options_definition.merge(options_definition) {|key, value, newval|  value[:option]}

        options_values = {}
        parser = OptionParser.new do |parser|
          parse_options(parser, options, options_values)
          yield parser, options, options_values if block_given?

          # Set a banner, displayed at the top
          # of the help screen.
          parser.banner = "Usage: cimaestro [command] [options] [task]"

          # This displays the help screen, all programs are
          # assumed to have this option.
          parser.on('-h', '--help', 'Display this screen') do
            puts parser
            exit
          end
    
          parser.on_tail('-V', '--version', "Show version") do
            puts CIMaestro::CIMaestro::VERSION
            exit
          end
        end

        #Remove all non-switch options without defaults
        options_with_defaults =  options_definition.delete_if {|key, value| !is_switch?(value[:option]) and not value.include?(:default)}

        options_defaults = options_with_defaults.merge(options_with_defaults) {|key, value, newval|  value[:default] || false}

        parser.parse!(args)

        options_values.reverse_merge!(options_defaults)

        missing_options = options.keys - options_values.keys
        if missing_options.size > 0 then
          raise OptionNotSpecifiedException, "Command option '#{options[missing_options[0]][0]}' was not specified." if options.keys - options_values.keys != []
        end

        OpenStruct.new(options_values)
      end
    end
  end
end