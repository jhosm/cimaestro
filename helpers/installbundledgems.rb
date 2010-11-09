require "FileUtils"
puts "USAGE:"
puts "ruby #{__FILE__} u - uninstall bundled gems"
puts "ruby #{__FILE__} i - install bundled gems"
FileUtils.cd("vendor/cache") do

  Dir.glob("*.*").each do |path|
  
    filename_without_ext = File.basename(path).split('.').first
    splitted_filename = filename_without_ext.split('-')
    if ARGV[0] == "u" then
      splitted_filename.pop
      system "gem uninstall #{splitted_filename.join("-")}"
    end
    if ARGV[0] == "i" then
      system "gem install #{splitted_filename.join("-")}"
    end
  end
end
