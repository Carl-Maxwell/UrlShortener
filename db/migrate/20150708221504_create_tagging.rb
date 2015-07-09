class CreateTagging < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.integer :topic_id
      t.integer :shortened_url_id

      t.timestamps
    end
  end
end
