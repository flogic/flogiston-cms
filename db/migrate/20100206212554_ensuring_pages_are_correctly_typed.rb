class EnsuringPagesAreCorrectlyTyped < ActiveRecord::Migration
  def self.up
    # anything without 'type' set was a Page and should explicitly be a Page now
    AbstractPage.update_all("type = 'Page'", 'type is null')
  end

  def self.down
  end
end
