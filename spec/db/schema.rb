
ActiveRecord::Schema.define(:version => 0) do

  create_table :custom_domains, :force => true do |t|
    t.string :domain_name
    t.string :table_name_prefix
  end

  ['foo_', 'bar_'].each do |table_name_prefix|
    create_table "#{table_name_prefix}articles".to_sym, :force => true do |t|
      t.string :title
      t.text :body
    end
  end
end
