require 'set'

# Audit saves the changes to ActiveRecord models.  It has the following attributes:
#
# * <tt>auditable</tt>: the ActiveRecord model that was changed
# * <tt><%= human_model %></tt>: the <%= human_model %> that performed the change; a string or an ActiveRecord model
# * <tt>action</tt>: one of create, update, or delete
# * <tt>changes</tt>: a serialized hash of all the changes
# * <tt>created_at</tt>: Time that the change was performed
#
class Audit < ActiveRecord::Base
  belongs_to :auditable, :polymorphic => true
  belongs_to :<%= human_model %>, :polymorphic => true

  before_create :set_version_number, :set_audit_<%= human_model %>

  serialize :changes

  cattr_accessor :audited_class_names
  self.audited_class_names = Set.new

  class << self
    def audited_classes
      self.audited_class_names.map(&:constantize)
    end

    # All audits made during the block called will be recorded as made
    # by +user+. This method is hopefully threadsafe, making it ideal
    # for background operations that require audit information.
    def as_user(user, &block)
      Thread.current[:acts_as_audited_<%= human_model %>] = user
      yield
      Thread.current[:acts_as_audited_<%= human_model %>] = nil
    end

    def manual_audit(<%= human_model %>, action, auditable = nil)
      attribs = { :action => action }

      case <%= human_model %>
      when ActiveRecord::Base
        attribs[:<%= human_model %>] = <%= human_model %>
      when String
        attribs[:username] = <%= human_model %>
      end

      case auditable
      when ActiveRecord::Base
        attribs[:auditable] = auditable
      when String
        attribs[:auditable_type] = auditable
      end

      Audit.create attribs
    end
  end

  # Allows <%= human_model %> to be set to either a string or an ActiveRecord object
  def <%= human_model %>_as_string=(<%= human_model %>) #:nodoc:
    # reset both either way
    self.<%= human_model %>_as_model = self.username = nil
    <%= human_model %>.is_a?(ActiveRecord::Base) ?
      self.<%= human_model %>_as_model = <%= human_model %> :
      self.username = <%= human_model %>
  end
  alias_method :<%= human_model %>_as_model=, :<%= human_model %>=
  alias_method :<%= human_model %>=, :<%= human_model %>_as_string=

  def <%= human_model %>_as_string #:nodoc:
    self.<%= human_model %>_as_model || self.username
  end
  alias_method :<%= human_model %>_as_model, :<%= human_model %>
  alias_method :<%= human_model %>, :<%= human_model %>_as_string

  def revision
    clazz = auditable_type.constantize
    returning clazz.find_by_id(auditable_id) || clazz.new do |m|
      Audit.assign_revision_attributes(m, self.class.reconstruct_attributes(ancestors).merge({:version => version}))
    end
  end

  def ancestors
    self.class.find(:all, :order => 'version',
      :conditions => ['auditable_id = ? and auditable_type = ? and version <= ?',
      auditable_id, auditable_type, version])
  end

  # Returns a hash of the changed attributes with the new values
  def new_attributes
    (changes || {}).inject({}.with_indifferent_access) do |attrs,(attr,values)|
      attrs[attr] = Array(values).last
      attrs
    end
  end

  # Returns a hash of the changed attributes with the old values
  def old_attributes
    (changes || {}).inject({}.with_indifferent_access) do |attrs,(attr,values)|
      attrs[attr] = Array(values).first
      attrs
    end
  end

  def self.reconstruct_attributes(audits)
    attributes = {}
    result = audits.collect do |audit|
      attributes.merge!(audit.new_attributes).merge!(:version => audit.version)
      yield attributes if block_given?
    end
    block_given? ? result : attributes
  end

  def self.assign_revision_attributes(record, attributes)
    attributes.each do |attr, val|
      if record.respond_to?("#{attr}=")
        record.attributes.has_key?(attr.to_s) ?
          record[attr] = val :
          record.send("#{attr}=", val)
      end
    end
    record
  end

private

  def set_version_number
    max = self.class.maximum(:version,
      :conditions => {
        :auditable_id => auditable_id,
        :auditable_type => auditable_type
      }) || 0
    self.version = max + 1
  end

  def set_audit_<%= human_model %>
    self.<%= human_model %> = Thread.current[:acts_as_audited_<%= human_model %>] if Thread.current[:acts_as_audited_<%= human_model %>]
    nil # prevent stopping callback chains
  end

end
