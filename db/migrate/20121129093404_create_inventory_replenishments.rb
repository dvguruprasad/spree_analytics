class CreateInventoryReplenishments < ActiveRecord::Migration
  def change
      create_table :spree_inventory_replenishments do |table|
          table.integer :product_id
          table.date :replenishment_date
          table.integer :quantity
          table.timestamps
      end
  end
end
