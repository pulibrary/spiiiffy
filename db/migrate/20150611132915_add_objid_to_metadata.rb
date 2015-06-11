class AddObjidToMetadata < ActiveRecord::Migration
  def change
    add_column :metadata, :objid, :string
  end
end
