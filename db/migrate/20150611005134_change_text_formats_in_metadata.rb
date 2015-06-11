class ChangeTextFormatsInMetadata < ActiveRecord::Migration
 def up
   change_column :metadata, :mets, :longtext
   change_column :metadata, :manifest, :longtext

 end

 def down
   change_column :metadata, :mets, :text
   change_column :metadata, :manifest, :text
 end
end
