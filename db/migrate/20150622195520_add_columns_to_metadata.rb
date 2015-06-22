class AddColumnsToMetadata < ActiveRecord::Migration
  def change
    add_column :metadata, :abstract, :text
    add_column :metadata, :thumbnail, :string
  end
end
