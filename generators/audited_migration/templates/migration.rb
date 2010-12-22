class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :audits, :force => true do |t|
      t.column :auditable_id, :integer
      t.column :auditable_type, :string
      t.column :<%= human_model %>_id, :integer
      t.column :<%= human_model %>_type, :string
      t.column :username, :string
      t.column :action, :string
      t.column :changes, :text
      t.column :version, :integer, :default => 0
      t.column :created_at, :datetime
    end

    add_index :audits, [:auditable_id, :auditable_type], :name => 'auditable_index'
    add_index :audits, [:<%= human_model %>_id, :<%= human_model %>_type], :name => '<%= human_model %>_index'
    add_index :audits, :created_at
  end

  def self.down
    drop_table :audits
  end
end
