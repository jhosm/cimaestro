require 'cimaestro/configuration/build_config'
module RuoteSpecHelper
  def get_required_workitem_for_process_startup
    {'build_config' => BuildConfig.new("system", "mainline", 'c:').to_ostruct}
  end
end
