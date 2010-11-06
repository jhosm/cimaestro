module CIMaestro
  module Application
    module CommandLineParser

      def parse_options(parser, options, options_values)
        options.each do |name, definition|

          parser.on(* definition) do |value|
            name_parts = name.to_s.split('!')
            option = options_values
            name_parts.each_index do |i|
              if name_parts.size - 1 > i then
                option.new_ostruct_member(name_parts[i])
                option.send(name_parts[i] + "=", OpenStruct.new)
                option = option.send(name_parts[i])
              end
            end

            option.new_ostruct_member(name_parts.last)
            if is_switch?(definition) then
              option.send(name_parts.last + "=", true)
            else
              option.send(name_parts.last + "=", value)
            end
          end
        end
      end

      def is_switch?(option_definition)
        option_definition[0].index(' ') == nil
      end

      def parse(args, options_definition)
        options =  options_definition

        options_values = OpenStruct.new
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

        parser.parse!(args)

        options_values
      end
    end
  end
end