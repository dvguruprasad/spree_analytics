class RfmController < ApplicationController
  respond_to :html, :xml, :json

  def index
  end

  def monetary_customer_distribution
    monetary_range = Range.new(params[:price_range].first.to_i, params[:price_range].last.to_i)
    monetary_ranges = monetary_range.split(params[:bucket_size].to_i)
    distribution = Spree::User.monetary_distribution(monetary_ranges)
    data = create_chart_data(distribution, :products_sold_for_price_range)
    json_response = Report.new('Price Range', labels_for_order_value(monetary_ranges).values, data, colors[0]).to_json
    respond_with(json_response)
  end

  def recency_customer_distribution
    recency_range_in_days = Range.new(0,number_of_days[params[:bucket_type]]*params[:number_of_buckets].to_i)
    recency_ranges_in_days = recency_range_in_days.split(params[:number_of_buckets].to_i)
    distribution = Spree::User.recency_distribution(recency_ranges_in_days)
    data = create_chart_data(distribution, :products_sold_in_date_range)
    json_response = Report.new('Recency In Days', labels_for_order_value(recency_ranges_in_days).values, data, colors[0]).to_json
    respond_with(json_response)
  end

  def frequency_customer_distribution
    transactions_frequency_range = Range.new(params[:order_range].first.to_i,params[:order_range].last.to_i)
    transactions_frequency_ranges  = transactions_frequency_range.split(params[:bucket_size].to_i)
    distribution = Spree::User.frequency_distribution(transactions_frequency_ranges)
    data = create_chart_data(distribution, :products_by_transaction_frequency)
    json_response = Report.new('Number Of Orders', labels_for_order_value(transactions_frequency_ranges).values, data, colors[0]).to_json
    respond_with(json_response)
  end

  private
  def create_chart_data(distribution, products_range_call)
    index = 0
    data = distribution.keys.map do |range|
      color = colors[index]
      index += 1
      products = Spree::Product.send(products_range_call, range)
      drilldown_data = Report.new(range.to_s, products[:product_names], products[:data], color)
      { :y => distribution[range], :color => color , :drilldown => drilldown_data }
    end
  end
  def colors
    ["#4572A7", "#AA4643", "#89A54E", "#80699B", "#3D96AE", "#DB843D", "#92A8CD", "#A47D7C", "#B5CA92"]
  end

  def number_of_days
    {"weekly" => 7,
     "monthly" => 30,
     "quarterly"=> 90,
     "half_yearly"=> 183
    }
  end
  def labels_for_order_value(ranges)
    labels = {}
    ranges.each_with_index do |r,index|
      labels[index] = r.to_s
    end
    labels
  end
end

class Range
  def split(number_of_buckets)
    range_list = []
    range_size = (min == 0)? (max-min) : (max - min + 1)
    steps = (range_size / number_of_buckets.to_f).ceil
    step(steps) do |x|
      y = (x + steps) < max ? (x + steps): max
      x = (x == min) ? x : x + 1
      range_list << Range.new(x,y) if x <= max
    end
    range_list
  end
end
