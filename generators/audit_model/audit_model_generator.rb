class AuditModelGenerator < Rails::Generator::NamedBase
  def initialize(runtime_args, runtime_options = {})
    runtime_args << 'user' if runtime_args.empty?
    super
    @human_model = runtime_args[0] ? runtime_args[0].underscore : 'user'
  end

  def manifest
    # puts "*** [AuditModelGenerator.manifest] - File.join(File.dirname(__FILE__), '..', '..', 'lib', 'acts_as_audited') = #{File.join(File.dirname(__FILE__), '..', '..', 'lib', 'acts_as_audited')}"
    record do |m|
      m.directory(File.join('app', 'models'))
      m.template('model.rb', "app/models/audit.rb", :assigns => { :human_model => @human_model })
    end
  end

  protected

  def banner
    "Usage: #{$0} audit_model [human_model_name]"
  end
end
