# configuration override example
# it's also possible to register participants and execute them in this flow or replace existing participants

Ruote.process_definition :name => 'setup_custom_build_spec' do
   set "field:merge_xsl_files" => { 'name' => 'Dexter Shipping', 'address' => [ 'Orchard Road', 'Singapore' ]}
end