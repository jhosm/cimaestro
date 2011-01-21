module CIMaestro
  module Application
    class CommandLine
      class << self
        def show_usage
          puts "Usage: cimaestro [command] [options]"
          puts "---"
          puts "Available commands:"
          ObjectSpace.each_object(Class) do |class_in_object_space|
            # search all subclasses of CommandLineCommand
            if class_in_object_space.ancestors.include? CommandLineCommand and class_in_object_space != CommandLineCommand then
              # generate description for each subclass found by parsing its name plus the description it provides, for e.g.
              # InstallCommand => "install <InstallCommand.new.desc>"
              command_desc = "  " + class_in_object_space.to_s.split("::").last.gsub(/Command$/, '').downcase
              command_desc = command_desc.ljust(32)
              #? why isn't desc a class (static) method?
              command_desc << "- " << class_in_object_space.new.desc if class_in_object_space.method_defined?(:desc)
              puts command_desc
            end
          end
          puts "Type cimaestro [command] -h to show available options."
        end

        def select_command(argv)
          command = argv.first

          if command == nil then
            show_usage()

            return nil
          end

          # user is running the cimaestro command
          return BuildCommand.new if command.start_with?("--")

          command_class_name = ("CIMaestro::Application::#{command.to_s.camelize}Command")
          begin
            command_class = command_class_name.to_class
          rescue NameError
            raise UnknownApplicationCommandException, "Command '#{command}' is not supported."
          end

          raise UnknownApplicationCommandException, "The class that should execute command '#{command}' is not a subclass of CommandLineCommand." unless command_class.ancestors.include? CommandLineCommand

          result = command_class.new

          result
        end

        def run(args = ARGV)
          begin
            command = self.select_command(args)
            unless command == nil then
              args.shift
              command.run(args)
            end
          rescue ::CIMaestro::Exceptions::InvalidBuildSpecException => onse
            puts onse.message
            # TODO: create method show_usage in CommandLineCommand
            command.run(['-h'])
            return 1
          rescue UnknownApplicationCommandException => uace
            puts uace.message
            puts
            show_usage
            return 2
          rescue Exception => e
            puts e.message
            puts e.backtrace
            return 999
          end
          return 0
        end
      end
    end
  end
end