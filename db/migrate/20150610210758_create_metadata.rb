class CreateMetadata < ActiveRecord::Migration
  def change
    create_table :metadata do |t|
      t.text :mets
      t.text :manifest

      t.timestamps null: false
    end
  end
end
