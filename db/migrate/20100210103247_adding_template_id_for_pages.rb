class AddingTemplateIdForPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :template_id, :integer
  end

  def self.down
    remove_column :pages, :template_id
  end
end
