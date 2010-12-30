module CollectiveIdea #:nodoc:
  module ActionController #:nodoc:
    module Audited #:nodoc:
      def audit(*models)
        ActiveSupport::Deprecation.warn("#audit is deprecated. Declare #acts_as_audited in your models.", caller)

        options = models.extract_options!

        # Parse the options hash looking for classes
        options.each_key do |key|
          models << [key, options.delete(key)] if key.is_a?(Class)
        end

        models.each do |(model, model_options)|
          model.send :acts_as_audited, model_options || {}
        end
      end
    end
  end
end

ActionController::Base.class_eval do
  extend CollectiveIdea::ActionController::Audited
end

class AuditSweeper < ActionController::Caching::Sweeper #:nodoc:
  def current_user_method
    "current_#{CollectiveIdea::Acts::Audited.human_model}".to_sym
  end

  def before_create(audit)
    raise "Got here"
    audit.send("#{CollectiveIdea::Acts::Audited.human_model}=".to_sym, current_user) unless audit.send(CollectiveIdea::Acts::Audited.human_model)
  end

  def current_user
    controller.send current_user_method if controller.respond_to?(current_user_method, true)
  end
end

