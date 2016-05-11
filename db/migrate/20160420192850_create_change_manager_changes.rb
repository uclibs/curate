class CreateChangeManageChanges < ActiveRecord::Migration
  def change
    create_table :change_manager_changes do |t|
      t.string :change_type
      t.boolean :change_cancelled
      t.datetime :change_notified
      t.string :change_owner
      t.string :change_target
      t.string :change_context
      
      t.timestamps
    end
  end
end
