puts "Exemplos: "
puts "Executar build completo -> ruby run_build.rb SYSTEM=STQ CODELINE=Mainline CCNetLabel=1.2.3.4   SOURCE_CONTROL=local "
puts
puts "Executar task 'merge_xsl_files', sem dependencias -> ruby run_build.rb merge_xsl_files SYSTEM=STQ CODELINE=Mainline CCNetLabel=1.2.3.4   SOURCE_CONTROL=local NO_DEPENDENCIES=true"
puts

require "rake"
FileUtils.mkpath '../../../../../_Tools/Build/cimaestro/' unless File.exists?('../../../../../_Tools/Build/cimaestro/')
FileUtils.cp FileList["./**"], '../../../../../_Tools/Build/cimaestro/'

FileUtils.cp FileList["../../../../STQ/Mainline/Solution/Site-Backoffice/workflows/papiro/xsl/*.*"], '../../../../STQ/Mainline/Integration/Site-Backoffice/workflows/papiro/xsl'

rake_command = "exec('rake.bat', \"-Cc:/netdados/dnc-gds/_Tools/Build/cimaestro/\", \"BASE_PATH=../../../_Projectos\", \"CCNetRequestSource=IntervalTrigger\", "
ARGV.each do |arg|
  rake_command += "\"" + arg + "\", "
end
rake_command.chomp!(", ")
rake_command += ")"

puts rake_command
eval(rake_command)
