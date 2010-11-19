=begin

Notas:
* rake faz parte do standard
* ruote tem menos utilizadores, qual o seu futuro? qual a robustez?
* workitems t�m de poder ser serializados em JSON... BuildConfig teria de ser modificado.
* ruote tem potencial para suportar tudo o que desenvolvermos
* ruote tem ruote-kit -> interface web de administra��o e servi�o REST
* ruote - investigar se oferece, de base, uma forma de consultar o hist�rico dos processos j� executados.
* ruote - 40 horas para converter de rake... 
=end

require 'rubygems'
require 'ruote'
require 'ruote/storage/fs_storage'

# preparing the engine

engine = Ruote::Engine.new(
        Ruote::Worker.new(
                Ruote::FsStorage.new(
                        'ruote_work')))

# Adicionar logger b�sico que subscreve as mensagens enviadas pelo ruote.
engine.add_service('s_cimaestrologger', 'lib/cimaestro/ruote/puts_logger', 'PutsLogger')

# spike para demonstrar como carregar customiza��es espec�ficas.
engine.register_participant 'setup_build_specification' do |workitem|
  workitem.fields['custom_spec_wf'] = File.dirname(__FILE__) + "/custom_build_spec.rb" if File.exist?(File.dirname(__FILE__) + "/custom_build_spec.rb")
end

#participante por omiss�o
engine.register_participant /.*/ do |workitem|
  puts "I received a message #{workitem.participant_name}"
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


  #Sugest�o. Definir estes fluxos externamente e regist�-los nas engine variables.
  #Assim podem ser usados noutras defini��es de fluxos. Ver http://ruote.rubyforge.org/exp/subprocess.html.
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

# se quisermos executar outro fluxo, passamos aqui outra defini��o, guardada na configura��o do sistema. Mera sugest�o.
engine.variables["build_process_definition"] = pdef

# launching, creating a process instance
wfid = engine.launch(engine.variables["build_process_definition"])

engine.wait_for(wfid)
# blocks current thread until our process instance terminates


