Sequel.migration do
  up do
    create_table(:to_watches) do
      primary_key :id
      text :comment
      text :link, :null => false
      text :title
      TrueClass :watched, :default => false
    end
  end
  
  down do
    drop_table(:to_watches)
  end
end
