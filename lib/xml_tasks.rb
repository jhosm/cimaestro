module Build
  class MergeXslFilesTask < Task
    attr_reader :xsl_files

    def setup
      @excluded_path_fragment = @build_spec.get_spec_for(@rake_name, :excluded_path_fragment)

      @xsl_files = @build_spec.get_spec_for(
              @rake_name,
                      :xsl_files,
                      FileList[
                              File.join(@build_spec.working_dir_path, ProjectType::SITE + "*", "**", "*.xsl"),
                                      File.join(@build_spec.working_dir_path, ProjectType::SITE + "*", "**", "*.xslt")
                      ]
      )

    end

    def execute
      return if @xsl_files == nil
      @xsl_files.each do | current_xsl_path |
        xsl_being_merged = Document.new File.read(current_xsl_path), :compress_whitespace => :all

        include_elems = xsl_being_merged.elements.to_a("//xsl:include or //include")
        while include_elems.length >= 1
          include_elems.each do |include_elem|
            merge_xsl(include_elem, current_xsl_path)
          end
          include_elems = xsl_being_merged.elements.to_a("//xsl:include or //include")
        end

        File.open(current_xsl_path, "w") do |file|
          xsl_being_merged.write file
        end
      end
    end

    def merge_xsl(include_elem, current_xsl_path)
      include_path = build_include_path(include_elem, current_xsl_path)

      included_elems = get_included_elems(include_path)
      return if included_elems == nil

      replace_include_elements(include_elem, included_elems)
    end

    def build_include_path(include_elem, current_xsl_path)
      href = include_elem.attributes["href"]
      href.gsub!(@excluded_path_fragment, '')
      if href.index('/') == 0
        include_path = File.join(@build_spec.extract_project_path(current_xsl_path), href)
      else
        include_path = File.join(File.dirname(current_xsl_path), href)
      end

      include_path
    end

    def get_included_elems(include_path)
      included_xsl = Document.new File.read(include_path)
      included_xsl.root.elements
    end

    def replace_include_elements(include_elem, included_xsl_elems)
      included_xsl_elems.each do |included_xsl_elem|
        include_elem.parent.insert_after(include_elem, included_xsl_elem)
      end
      include_elem.parent.delete_element(include_elem)
    end
  end

  class ValidateAndMinimizeXmlFilesTask < Task
    attr_reader :xml_files

    def setup

      @xml_files = @build_spec.get_spec_for(
              @rake_name,
                      :xml_files,
                      FileList[
                              File.join(@build_spec.working_dir_path, "**", "*.xml"),
                                      File.join(@build_spec.working_dir_path, "**", "*.xsl"),
                                      File.join(@build_spec.working_dir_path, "**", "*.xslt"),
                                      File.join(@build_spec.working_dir_path, "**", "*.xsd")
                      ]
      )
    end

    def execute
      @xml_files.each do |xml_file|
        begin
          xml_contents = File.read(xml_file)
          Document.new xml_contents
          File.open(xml_file, "w") do |file|
            file.write xml_contents.gsub(/>\s+</, "><")
          end
        rescue
          @logger.log_msg "'#{xml_file}' is not a well formed xml."
          raise
        end
      end
    end
  end
end
