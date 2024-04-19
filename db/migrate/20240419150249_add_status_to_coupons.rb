class AddStatusToCoupons < ActiveRecord::Migration[7.1]
  def change
    add_column :coupons, :status, :integer, default: 0
  end
end
