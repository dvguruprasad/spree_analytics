require 'spec_helper'
class ProductWeeklySalesSpec
    describe ProductWeeklySales do
        describe ".sales_including_forecasts" do
            context "when no sales information present" do
                it "should return empty array" do
                    sales = ProductWeeklySales.sales_including_forecasts(Date.new(2012, 1, 2), 6)

                    sales.should be_empty
                end
            end

            context "when no sales found after a given start date" do
                it "should return empty array" do
                    create_weekly_sales(:week_start_date => Date.new(2012, 1, 2), :sales_units => 20)
                    create_weekly_sales(:week_start_date => Date.new(2012, 1, 9), :sales_units => 30)
                    week_start_date = Date.new(2012, 1, 16)
                    number_of_weeks = 1
                    sales = ProductWeeklySales.sales_including_forecasts(week_start_date, number_of_weeks)

                    sales.should be_empty
                end
            end

            context "when sales found after a given start date" do
                it "should return records for number of weeks passed" do
                    create_weekly_sales(:week_start_date => Date.new(2012, 1, 2), :sales_units => 20)
                    create_weekly_sales(:week_start_date => Date.new(2012, 1, 9), :sales_units => 30)
                    create_weekly_sales(:week_start_date => Date.new(2012, 1, 16), :sales_units => 40)
                    week_start_date = Date.new(2012, 1, 9)
                    number_of_weeks = 2
                    sales = ProductWeeklySales.sales_including_forecasts(week_start_date, number_of_weeks)

                    sales.should have(2).sales
                    sales.first.sales_units.should eql 30
                    sales.last.sales_units.should eql 40
                end

                it "should return as many available if number of weeks exceeds number of records present" do
                    create_weekly_sales(:week_start_date => Date.new(2012, 1, 2), :sales_units => 20)
                    create_weekly_sales(:week_start_date => Date.new(2012, 1, 9), :sales_units => 30)
                    week_start_date = Date.new(2012, 1, 2)
                    number_of_weeks = 6
                    sales = ProductWeeklySales.sales_including_forecasts(week_start_date, number_of_weeks)

                    sales.should have(2).sales
                end
            end

            context "when date passed is not the first day of the week" do
                it "should raise error" do
                    expect { ProductWeeklySales.sales_including_forecasts(Date.new(2012, 1, 2) + 2, 6) }.to raise_error(RuntimeError, "week_start_date should be the beginning of a week(monday)")
                end
            end

            context "when forecasts are available" do
                it "should return forecasts when passed in number of weeks exceeds sales data available" do
                    create_weekly_sales(:week_start_date => Date.new(2012, 1, 2), :sales_units => 20)
                    create_weekly_sales(:week_start_date => Date.new(2012, 1, 9), :sales_units => 30)
                    create_weekly_sales_forecast(:week_start_date => Date.new(2012, 1, 16), :sales_units => 25)
                    week_start_date = Date.new(2012, 1, 2)
                    number_of_weeks = 4
                    sales = ProductWeeklySales.sales_including_forecasts(week_start_date, number_of_weeks)

                    sales.should have(3).sales
                    sales.last.should be_an_instance_of(ProductWeeklySalesForecast)
                end

                it "should not return forecasts when sales data for the number of weeks passed in is available" do
                    create_weekly_sales(:week_start_date => Date.new(2012, 1, 2), :sales_units => 20)
                    create_weekly_sales(:week_start_date => Date.new(2012, 1, 9), :sales_units => 30)
                    create_weekly_sales_forecast(:week_start_date => Date.new(2012, 1, 16), :sales_units => 25)
                    week_start_date = Date.new(2012, 1, 2)
                    number_of_weeks = 2

                    sales = ProductWeeklySales.sales_including_forecasts(week_start_date, number_of_weeks)
                    sales.should have(2).sales
                    sales.each do |sale|
                        sale.should be_an_instance_of(ProductWeeklySales)
                    end
                end

                it "should return all forecasts when no sales available" do
                    create_weekly_sales_forecast(:week_start_date => Date.new(2012, 1, 9), :sales_units => 20)
                    create_weekly_sales_forecast(:week_start_date => Date.new(2012, 1, 16), :sales_units => 25)
                    week_start_date = Date.new(2012, 1, 2)
                    number_of_weeks = 2

                    sales = ProductWeeklySales.sales_including_forecasts(week_start_date, number_of_weeks)
                    sales.should have(2).sales
                    sales.each do |sale|
                        sale.should be_an_instance_of(ProductWeeklySalesForecast)
                    end
                end
            end

            def create_weekly_sales(data)
                Factory.create(:product_weekly_sales, :week_start_date => data[:week_start_date], :week_end_date => data[:week_start_date] + 6, :sales_units => data[:sales_units])
            end

            def create_weekly_sales_forecast(data)
                Factory.create(:product_weekly_sales_forecast, :week_start_date => data[:week_start_date], :week_end_date => data[:week_start_date] + 6, :sales_units => data[:sales_units])
            end
        end
    end
end
