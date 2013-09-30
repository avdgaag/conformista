require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Migration.verbose = false

ActiveRecord::Migration.create_table :posts do |t|
  t.string :title
  t.timestamps
end

ActiveRecord::Migration.create_table :comments do |t|
  t.text :body
  t.timestamps
end

class Post < ActiveRecord::Base
  validates :title, presence: true
end

class Comment < ActiveRecord::Base
  validates :body, presence: true
end
