class AddPictureColumnToGram < ActiveRecord::Migration
  def change
    add_column :grams, :picture, :string
    add_index :grams, :picture
  end
end
