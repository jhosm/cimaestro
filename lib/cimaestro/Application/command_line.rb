module CIMaestro
  module Application
    class CommandLine
      class << self
        def show_usage
          puts "Usage: cimaestro [command] [options]"
          puts "---"
          puts "Available commands:"
          ObjectSpace.each_object(Class) do |klass|
            if klass.ancestors.include? CommandLineCommand and klass != CommandLineCommand then
              command_desc = "  " + klass.to_s.split("::").last.gsub(/Command$/, '').downcase
              command_desc = command_desc.ljust(32)
              command_desc << "- " << klass.new.desc if klass.method_defined?(:desc)
              puts command_desc
            end
          end
          puts "Type cimaestro [command] -h to show available options."
        end

        def select_command(argv)
          command = argv.first

          if command == nil then
            show_usage()

            exit
          end

          return BuildCommand.new if command.start_with?("--")

          command_class_name = ("CIMaestro::Application::#{command.to_s.camelize}Command")
          begin
            klass = command_class_name.to_class
          rescue NameError
            raise UnknownApplicationCommandException, "Command '#{command}' is not supported."
          end

          raise UnknownApplicationCommandException, "The class that should execute command '#{command}' is not a subclass of CommandLineCommand." unless klass.ancestors.include? CommandLineCommand

          result = klass.new

          result
        end

        def run(args = ARGV)
          begin
            command = self.select_command(args)
            args.shift
            command.run(args)
          rescue OptionNotSpecifiedException => onse
            puts onse.message
            command.run(['-h'])
            return 1
          rescue UnknownApplicationCommandException => uace
            puts uace.message
            puts
            show_usage
            return 2
          rescue Exception => e
            puts e.message
            #puts e.backtrace
            return 999
          end
          return 0
        end
      end
    end
  end
end