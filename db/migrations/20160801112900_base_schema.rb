Sequel.migration do
    change do
        create_table :logs do
            primary_key :id
            String :url, :null => false
            String :referrer, :null => true
            DateTime :created_at, :null => false
            String :hash, :null => false
        end
    end
end
