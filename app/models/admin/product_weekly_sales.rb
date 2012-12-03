module Admin
  class ProductWeeklySales < ActiveRecord::Base
    self.table_name= "spree_product_weekly_sales"

    def self.by_taxon_id(taxon_id)
      products_sales = ProductWeeklySales.find_all_by_taxon_id(taxon_id)
      sales_aggregate_by_product = {}
      product_ids = ProductWeeklySales.select(:product_id).uniq.map { |pws| pws.product_id }

      product_ids.each do |p_id|
        weekly_sales_by_product = products_sales.select{ |ps| ps.product_id == p_id }
        sales_aggregate_by_product[p_id] = sales_aggregate(weekly_sales_by_product)
      end
      sales_aggregate_by_product
    end

    def self.sales_aggregate(product_weekly_sales)
      total_revenue = product_weekly_sales.inject(0) { |sum, pws| sum + pws.revenue }
      total_target_revenue = product_weekly_sales.inject(0) { |sum, pws| sum + pws.target_revenue }
      start_time = product_weekly_sales.inject do |min, pws|
        min.week_start_date < pws.week_start_date ? min : pws
      end.week_start_date

      end_time = product_weekly_sales.inject do |max, pws|
        max.week_end_date > pws.week_end_date ? min : pws
      end.week_end_date
      number_of_weeks = product_weekly_sales.count
      {"total_revenue" => total_revenue, "total_target_revenue" => total_target_revenue,
       "start_time" => start_time, "end_time" => end_time, "number_of_weeks" => number_of_weeks}
    end
  end
end
