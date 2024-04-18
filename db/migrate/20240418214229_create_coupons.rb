class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.string :code
      t.integer :discount_amount
      t.boolean :percent_off, default: true
      t.references :merchant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
