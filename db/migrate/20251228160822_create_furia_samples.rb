class CreateFuriaSamples < ActiveRecord::Migration
  def change
    create_table :furia_samples do |t|
      t.text :data, limit: 16.megabytes - 1, null: false
      t.datetime :created_at, null: false
      t.index :created_at, order: :desc
    end
  end
end
