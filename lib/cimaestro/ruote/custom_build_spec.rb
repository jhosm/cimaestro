#exemplo de override de configura��o
#tamb�m se pode registar um ou mais participantes e execut�-los neste fluxo ou subsitutir participantes j� existentes.

Ruote.process_definition :name => 'setup_custom_build_spec' do
   set "field:merge_xsl_files" => { 'name' => 'Dexter Shipping', 'address' => [ 'Orchard Road', 'Singapore' ]}
end