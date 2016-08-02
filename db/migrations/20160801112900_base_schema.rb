Sequel.migration do
    change do
        create_table :logs do
            Integer :id
            String :url, :null => false
            String :referrer, :null => true
            DateTime :created_at, :null => false
            String :hash, :null => false
            index [:created_at, :url, :referrer]
            index [:url, :referrer, :created_at]
        end
    end
end
