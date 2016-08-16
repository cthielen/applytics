# This migration is MySQL dependent (as is our project).
Sequel.migration do
    change do
        create_table :logs do
            primary_key :id
            String :url, :null => false
            String :referrer, :null => true
            DateTime :created_at, :null => false
            String :hash, :null => false
            index [:created_at, :url, :referrer]
            index [:url, :referrer, :created_at]
        end

        # Our spec calls for a MD5 sum which is the result of Ruby's Hash.to_s.
        # We'll recreate this using a MySQL trigger (for performance), and MD5(CONCAT()).
        # Note we have to coalesce the possibly null value of 'referrer' as MySQL's
        # CONCAT() will return NULL if any parameter is NULL.
        run 'CREATE TRIGGER GenerateMD5Hash BEFORE INSERT ON logs FOR EACH ROW SET NEW.hash = MD5(CONCAT("{:id=>", NEW.id, ", :url=>\"", NEW.url, "\", :referrer=>\"", COALESCE(NEW.referrer,\'\'), "\", :created_at=>", NEW.created_at, "}"));'
    end
end
