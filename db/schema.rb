Sequel.migration do
  change do
    create_table(:logs) do
      primary_key :id, :type=>"int(11)"
      column :url, "varchar(255)", :null=>false
      column :referrer, "varchar(255)"
      column :created_at, "datetime", :null=>false
      column :hash, "varchar(255)", :null=>false
      
      index [:created_at, :url, :referrer]
      index [:url, :referrer, :created_at]
    end
    
    create_table(:schema_migrations) do
      column :filename, "varchar(255)", :null=>false
      
      primary_key [:filename]
    end
  end
end
Sequel.migration do
  change do
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20160801112900_base_schema.rb')"
  end
end
