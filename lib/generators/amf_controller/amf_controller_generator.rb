class AmfControllerGenerator < Rails::Generator::NamedBase

  attr_reader :amf_controller_name, :singular_name, :plural_name

  def initialize(runtime_args, runtime_options = {})
    super
    @amf_controller_name = name
    @singular_name = name.tableize.singularize
    @plural_name = name.tableize

  end

  def manifest
    record do |m|
     m.template('controller.rb', "app/controllers/#{@amf_controller_name.tableize}_controller.rb")
    end
  end

end
