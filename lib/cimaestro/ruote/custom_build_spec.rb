#exemplo de override de configuração
#também se pode registar um ou mais participantes e executá-los neste fluxo ou subsitutir participantes já existentes.

Ruote.process_definition :name => 'setup_custom_build_spec' do
   set "field:merge_xsl_files" => { 'name' => 'Dexter Shipping', 'address' => [ 'Orchard Road', 'Singapore' ]}
end