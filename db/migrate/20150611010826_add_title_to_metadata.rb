class AddTitleToMetadata < ActiveRecord::Migration
  def change
    add_column :metadata, :title, :string
  end
end
