=begin

Notas:
* ruote tem ruote-kit -> interface web de administração e serviço REST
* ruote - investigar se oferece, de base, uma forma de consultar o histórico dos processos já executados.
=end

require 'rubygems'
require 'ruote'
require 'ruote/storage/fs_storage'
require 'log4r'

log = Log4r::Logger.new("simple")        # create a logger
log.add( Log4r::StdoutOutputter.new('stdout', :formatter=>Log4r::PatternFormatter.new( :pattern => "%m")))

# preparing the engine

engine = Ruote::Engine.new(
        Ruote::Worker.new(
                Ruote::FsStorage.new(
                        'ruote_work')))

# Adicionar logger básico que subscreve as mensagens enviadas pelo ruote.
engine.add_service('s_cimaestrologger', 'lib/cimaestro/ruote/puts_logger', 'PutsLogger')

# spike para demonstrar como carregar customizaçõees específicas.
engine.register_participant 'setup_build_specification' do |workitem|
  workitem.fields['custom_spec_wf'] = File.dirname(__FILE__) + "/custom_build_spec.rb" if File.exist?(File.dirname(__FILE__) + "/custom_build_spec.rb")
end

#participante por omissão
engine.register_participant /.*/ do |workitem|
   Log4r::Logger['simple'].debug "I received a message #{workitem.participant_name}"
end

# O processo de build do CIMaestro
pdef = Ruote.process_definition :name => 'test' do
  sequence do
    prepare_build_spec
    purge_working_directory
    get_sources
    build_web_sources
    compile_dot_net_sources
    validate_dot_net
    publish
  end


  define 'prepare_build_spec' do
    load_config
    setup_build_specification
    subprocess :ref => '${custom_spec_wf}', :if => '${custom_spec_wf}'
  end

  define 'build_web_sources' do
    merge_xsl_files
    validate_and_minimize_xml_files
    version_sites
    merge_web_files
    minify_javascript
    replace_css_references
    make_versioned_file_names
  end

  define 'compile_dot_net_sources' do
    update_dependencies
    set_common_assembly_attributes
    compile_dot_net_projects
    create_strong_named_assembly_policy
  end

  define 'validate_dot_net' do
    run_dot_net_unit_tests
    analyze_code
    compute_code_metrics
  end

  define 'publish' do
    publish_artifacts
  end
end

engine.variables["build_process_definition"] = pdef

# launching, creating a process instance
wfid = engine.launch(engine.variables["build_process_definition"])

engine.wait_for(wfid)
