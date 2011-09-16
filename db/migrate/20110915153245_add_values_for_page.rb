class AddValuesForPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :values, :text
  end

  def self.down
    remove_column :pages, :values
  end
end
