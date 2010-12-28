class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :audits, :force => true do |t|
      t.integer  :auditable_id
      t.string   :auditable_type
      t.integer  :<%= human_model %>_id
      t.string   :<%= human_model %>_type
      t.string   :username
      t.string   :action
      t.text     :changes
      t.integer  :version, :default => 0
      t.datetime :created_at
    end

    add_index :audits, [:auditable_id, :auditable_type], :name => 'auditable_index'
    add_index :audits, [:<%= human_model %>_id, :<%= human_model %>_type], :name => '<%= human_model %>_index'
    add_index :audits, :created_at
  end

  def self.down
    drop_table :audits
  end
end
