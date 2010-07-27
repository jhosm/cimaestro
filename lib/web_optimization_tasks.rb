require "required_references"

module Build

  class MinifyJavascriptTask < Task
    include Build::ShellUtils
    GENERATED_JS_DIR = "GeneratedJS"
    
    def setup
      @files_to_minify = build_spec.get_file_list(["js"], rake_name, :files_to_minify, build_spec.get_projects_of([ProjectType::SITE])).
        exclude do |file|
          not file.include? GENERATED_JS_DIR
      end
    end

    def execute
      @files_to_minify.each do |file|
        exec_and_log("java -jar #{File.join(build_spec.tools_dir_path, "ClosureCompiler", "compiler.jar")} --create_source_map=\"#{File.basename(file)}.map\" --js=\"#{file}\" --js_output_file=\"#{file}x\"")
        FileUtils.mv file + "x", file
      end
    end
  end

  class MakeVersionedFileNamesTask < Task
    attr_reader :files_to_version

    def setup
      @files_to_version = build_spec.get_file_list(["xsl", "xslt", "htm", "html", "css"], rake_name, :files_to_version)
    end

    def execute
      versionizer = FilenameVersionizer.new
      versionizer.versionize_and_copy_files @files_to_version, build_spec.version
    end
  end

  class ReplaceCssReferencesTask < Task
    attr_reader :css_referencing_files

    def setup
      @css_referencing_files = build_spec.get_file_list(["xsl", "xslt", "htm", "html", "asp", "aspx"], rake_name, :css_referencing_files)
      @files_to_version = build_spec.get_file_list(["css"], rake_name, :files_to_version)
    end

    def execute
      versionizer = FilenameVersionizer.new
      @css_referencing_files.each do |css_referencing_file|
        content = File.read(css_referencing_file)
        @files_to_version.each do |css_file|
          string_pattern = File.basename(css_file) + '((?:"|\')\s+rel=(?:"|\')stylesheet(?:"|\'))'
          pattern = Regexp.new(string_pattern, Regexp::IGNORECASE)
          #puts string_pattern + '->' + versionizer.versionize(css_file, build_spec.version) + '\1' 
          content.sub!(pattern,  versionizer.versionize(css_file, build_spec.version) + '\1')
        end
        File.open(css_referencing_file, "w") do |file|
          file.write content
        end
      end
    end
  end

  class MergeWebFilesTask < Task
    GENERATED_JS_DIR = "GeneratedJS"

    def setup

      @excluded_path_fragment = build_spec.get_spec_for(rake_name, :excluded_path_fragment)
      @vdir = build_spec.get_spec_for(rake_name, :generated_js_base_path) + "/" + GENERATED_JS_DIR

      @js_referencing_files = {}
      if !build_spec.get_spec_for(rake_name, :js_referencing_files, []).empty? then
        @js_referencing_files[""] = build_spec.get_file_list(["xsl", "xslt", "htm", "html", "asp", "aspx"], rake_name, :js_referencing_files)
      else
        build_spec.get_projects_of(ProjectType::SITE).each do |project|
          @js_referencing_files[project.full_name] = build_spec.get_file_list(["xsl", "xslt", "htm", "html", "asp", "aspx"], rake_name, "", project)
        end
      end

    end

    def execute
      @files_not_merged = []
      @merged_file_names = {}

      @js_referencing_files.each do |prj_full_name, files_to_scan|
        files_to_scan.each do |file_to_scan|
          files_to_merge = find_files_to_merge(file_to_scan, prj_full_name)

          if (files_to_merge.size > 0) then
            contents = merge_files(files_to_merge)

            if !contents.empty? then

              save_merged_file(contents, file_to_scan, prj_full_name)
              replace_file_references(file_to_scan)
            end
          end
        end
      end
    end

    private

    def replace_file_references(file_referencing_contents)
      file_name = build_merged_file_name(file_referencing_contents)
      contents_to_scan = ""
      File.open(file_referencing_contents, "r") do |file|
        contents_to_scan = file.read
      end

      inserted_reference_to_merged_file = false
      @file_references_matches.each_index do |index|
        file_reference = @file_references_matches[index]
        next if @files_not_merged.include?(file_reference)

        replace_value = ""
        if (!inserted_reference_to_merged_file) then
          replace_value = "<script src='#{build_merged_file_reference(file_name)}'>/**/</script>"
          inserted_reference_to_merged_file = true
        end

        logger.log_msg "..Replacing file reference #{@script_tag_matches[index]} with '#{replace_value}'."
        logger.log_msg "..Could not find #{@script_tag_matches[index]}." if contents_to_scan[@script_tag_matches[index]] == nil

        contents_to_scan[@script_tag_matches[index]] = replace_value
      end

      File.open(file_referencing_contents, "w+") do |file|
        file.puts contents_to_scan
      end
    end

    def save_merged_file(contents, file_referencing_contents, prj_full_name)
      file_name = build_merged_file_name(file_referencing_contents)
      file_path = build_merged_file_path(file_name, prj_full_name)

      logger.log_msg "..Saving merged file at #{file_path}."

      mkpath File.dirname(file_path)
      File.open(file_path, "w+") do | file |
        file.puts contents
      end
    end

    def build_merged_file_reference(file_name)
      (@vdir + "/" + file_name).gsub(/\\/, '/')
    end

    def build_merged_file_path(file_name, prj_full_name)
      File.join(build_spec.working_dir_path, prj_full_name, GENERATED_JS_DIR, file_name)
    end

    def build_merged_file_name(file_referencing_contents)
      if @merged_file_names.has_key?(file_referencing_contents) then
        file_name = @merged_file_names[file_referencing_contents]
      else
        file_name = UUID.new
        file_name = build_spec.version + file_name + ".js"
        @merged_file_names[file_referencing_contents] = file_name
      end

      file_name
    end

    def merge_files(files_to_merge)
      result = ""
      files_to_merge.each do |file|
        if !File.exists?(file) then
          logger.log_msg "..Could not find #{file}, although it's referenced."
          mark_file_as_not_merged(file)
          next
        end

        result += "\r\n"
        result += "\r\n"
        result += "/* FILE ---> "
        result += file
        result += " */"
        result += "\r\n"
        File.open(file, "r") do |orig_file|
          result += orig_file.read
        end
      end
      result
    end

    def mark_file_as_not_merged(file)
      @file_references_matches.each do |file_match|
        relative_path = get_file_reference_relative_path(file_match)
        if file.index(relative_path) != nil then
          @files_not_merged.push(file_match)
        end
      end
    end

    def find_files_to_merge(file_to_scan, prj_full_name)
      file_references = find_file_references(file_to_scan);
      create_list_of_files_to_merge(file_references, prj_full_name);
    end

    def find_file_references(file_to_scan)
      logger.log_msg "Searching script tags in #{file_to_scan}."

      file_contents = ""
      File.open(file_to_scan, 'r') do |file|
        file_contents = file.read
      end

      script_tag_file_references_regex = /<script.+?src=(?:\"|').+?\.js(?:\"|')(?:.*?<\/script>)/i
      @script_tag_matches = file_contents.scan(script_tag_file_references_regex)
      @script_tag_matches ||= []

      logger.log_msg "..Found #{@script_tag_matches.size} matches."

      find_file_references_regex =       /<script.+?src=(?:\"|')(.+?\.js)(?:\"|')(?:.*?<\/script>)/i
      @file_references_matches = file_contents.scan(find_file_references_regex)
      @file_references_matches ||= []
      @file_references_matches
    end

    def create_list_of_files_to_merge(file_references, prj_full_name)
      result = []
      file_references.each do |file_reference|
        relative_path = get_file_reference_relative_path(file_reference).to_s
        relative_path.gsub!(@excluded_path_fragment, '')
        result.push(File.join(build_spec.working_dir_path, prj_full_name, relative_path))
      end
      result
    end

    def get_file_reference_relative_path(file_reference)
      relative_path = remove_initial_path_separator(file_reference)
      relative_path.to_s
    end

    def remove_initial_path_separator(relative_path)
      relative_path = relative_path[1, relative_path.length] if relative_path =~ /\//
      relative_path
    end
  end
end