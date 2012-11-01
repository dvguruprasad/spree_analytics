require 'spec_helper'

class UpsellSpec
    describe "Upsell" do
        context ".identify_substitutions" do
            it "should return 0 substitutions when there is only one search behavior" do
                behaviors = [create_search(product_price = 100)]
                substitutions = Upsell.identify_substitutions(behaviors)
                substitutions.count.should eql(0)
            end

            it "should return 0 substitutions if the only behavior is purchase" do
                behaviors = [FactoryGirl.create(:purchase_behavior)]
                substitutions = Upsell.identify_substitutions(behaviors)
                substitutions.count.should eql(0)
            end

            it "should return 0 substitutions when there are multiple search behaviors" do
                behaviors = [create_search(product_price = 100), create_search(product_price = 200)]
                substitutions = Upsell.identify_substitutions(behaviors)
                substitutions.count.should eql(0)
            end

            it "should return 0 substitutions when a product is searched for and purchased" do
                behaviors = create_search_and_purchase(product_price = 100)
                substitutions = Upsell.identify_substitutions(behaviors)
                substitutions.count.should eql(0)
            end

            it "should return 0 substitution when a product is searched for and another with a lower cost bought" do
                behaviors = [create_search(100)] + create_search_and_purchase(product_price = 50)

                substitutions = Upsell.identify_substitutions(behaviors)
                substitutions.count.should eql(0)
            end

            it "should return 1 substitution when a product is searched for and another with a higher cost bought" do
                search_1 = create_search(product_price = 100)
                search_and_purchase_2 = create_search_and_purchase(product_price = 150)

                behaviors = [search_1] + search_and_purchase_2

                substitutions = Upsell.identify_substitutions(behaviors)
                substitutions.count.should eql(1)
                substitutions.first.searched_product.should eql(search_1.product)
                substitutions.first.bought_product.should eql(search_and_purchase_2.first.product)
                substitutions.first.count.should eql(1)
            end

            it "should consider only the last searched product with a lower price in identifying upsell" do
                search_1 = create_search(product_price = 100)
                search_2 = create_search(product_price = 100)
                search_and_purchase_3 = create_search_and_purchase(product_price = 150)

                behaviors = [search_1, search_2] + search_and_purchase_3

                substitutions = Upsell.identify_substitutions(behaviors)
                substitutions.count.should eql(1)
                substitutions.first.searched_product.should eql(search_2.product)
                substitutions.first.bought_product.should eql(search_and_purchase_3.first.product)
                substitutions.first.count.should eql(1)
            end

            it "should not consider a purchase after an upsell is identified, as another upsell" do
                search_1 = create_search(product_price = 100)
                search_2 = create_search(product_price = 100)
                search_and_purchase_3 = create_search_and_purchase(product_price = 150)
                search_and_purchase_4 = create_search_and_purchase(product_price = 250)

                behaviors = [search_1, search_2] + search_and_purchase_3 + search_and_purchase_4

                substitutions = Upsell.identify_substitutions(behaviors)
                substitutions.count.should eql(1)
                substitutions.first.searched_product.should eql(search_2.product)
                substitutions.first.bought_product.should eql(search_and_purchase_3.first.product)
                substitutions.first.count.should eql(1)
            end

            it "should not consider two consecutive purchases of two different products an upsell even when the price of the latter is higher" do
                search_and_purchase_1 = create_search_and_purchase(product_price = 150)
                search_and_purchase_2 = create_search_and_purchase(product_price = 250)

                behaviors = search_and_purchase_1 + search_and_purchase_2

                substitutions = Upsell.identify_substitutions(behaviors)
                substitutions.count.should eql(0)
            end

        end

        def create_search(product_price)
            searched_variant = FactoryGirl.create(:variant, price: product_price)
            searched_product = searched_variant.product
            FactoryGirl.create(:search_behavior, product: searched_product.id, price: product_price)
        end

        def create_search_and_purchase(product_price)
            bought_variant = FactoryGirl.create(:variant, price: product_price)
            bought_product = bought_variant.product
            search = FactoryGirl.create(:search_behavior, product: bought_product.id, price: product_price)
            line_items = [FactoryGirl.create(:line_item, price: product_price, variant: bought_variant)]
            order = line_items.first.order
            purchase = FactoryGirl.create(:purchase_behavior, order: order.id, products: [bought_product.id])
            [search, purchase]
        end
    end
end
