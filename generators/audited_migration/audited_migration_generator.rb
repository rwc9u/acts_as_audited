class AuditedMigrationGenerator < Rails::Generator::NamedBase
  def initialize(runtime_args, runtime_options = {})
    super
    @human_model = runtime_args[1] ? runtime_args[1].underscore : 'user'
  end

  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', :assigns => { :human_model => @human_model }
    end
  end

  protected

  def banner
    "Usage: #{$0} audited_migration add_audits_table [human_model_name]"
  end
end