class TabsHelperGenerator < Rails::Generators::Base #:nodoc:
  source_root File.expand_path('../templates', __FILE__)

  desc "Creates helper resources in relevant public destinations."
  def create_resources
    directory "public"
    inject_into_class "app/controllers/application_controller.rb", ApplicationController do
      "  helper :tabs\n"
    end
  end
end
