class CreateProductWeeklyInventoryPositions < ActiveRecord::Migration
  def change
      create_table :spree_product_weekly_inventory_positions do |table|
          table.integer :product_id
          table.date :week_start_date
          table.date :week_end_date
          table.integer :closing_position
          table.timestamps
      end
  end
end
