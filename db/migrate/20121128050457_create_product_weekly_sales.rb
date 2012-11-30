class CreateProductWeeklySales < ActiveRecord::Migration
  def change
      create_table :spree_product_weekly_sales do |table|
          table.integer :product_id
          table.date :week_start_date
          table.date :week_end_date
          table.integer :sales_units
          table.float :revenue
          table.integer :target_sales_units
          table.float :target_revenue
          table.float :cost
          table.timestamps
      end
  end
end
