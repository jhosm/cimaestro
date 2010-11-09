#run this script and compare the output with Manifest.txt, to make sure that it is updated.
Dir.glob("**/*.*").each do |path|
  puts path unless path.match(/(^coverage)|(^pkg\/cimaestro)|(^Gemfile\.lock)/) 
end