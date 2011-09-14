class ChangeTemplatesToLayouts < ActiveRecord::Migration
  class AbstractPage < ActiveRecord::Base
    set_table_name 'pages'
  end

  def self.up
    AbstractPage.update_all("type = 'Layout'", "type = 'Template'")
  end

  def self.down
  end
end
