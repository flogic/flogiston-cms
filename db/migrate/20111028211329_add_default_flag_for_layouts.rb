class AddDefaultFlagForLayouts < ActiveRecord::Migration
  def self.up
    add_column :pages, :default, :boolean
  end

  def self.down
    remove_column :pages, :default
  end
end
