Sequel.migration do
    change do
        create_table :logs do
            Integer :id
            String :url, :null => false
            String :referrer, :null => true
            DateTime :created_at, :null => false
            String :hash, :null => false
            index [:id, :url, :created_at]
            index [:id, :url, :referrer, :created_at]
        end
    end
end
