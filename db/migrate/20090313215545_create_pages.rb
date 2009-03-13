class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages, :force => true do |t|
      t.string :title, :handle
      t.text :contents
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
