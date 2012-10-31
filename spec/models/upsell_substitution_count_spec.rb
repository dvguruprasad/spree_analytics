require 'spec_helper'

class UpsellSubstitutionCountSpec
    describe "UpsellSubstitutionCount" do
        context ".identify_substitutions" do
            it "should return 0 substitutions when there is only one search behavior" do
                behaviors = [FactoryGirl.create(:search_behavior)]
                substitutions = UpsellSubstitutionCount.identify_substitutions(behaviors)
                substitutions.count.should eql(0)
            end

            it "should return 0 substitutions when there are only multiple search behaviors" do
                behaviors = [FactoryGirl.create(:search_behavior), FactoryGirl.create(:search_behavior)]
                substitutions = UpsellSubstitutionCount.identify_substitutions(behaviors)
                substitutions.count.should eql(0)
            end

            it "should return 0 substitutions when a product is searched for and purchased" do
                product = FactoryGirl.create(:product)
                search_behavior = FactoryGirl.create(:search_behavior, product: product.id) 
                order = FactoryGirl.create(:order)
                purchase_behavior = FactoryGirl.create(:purchase_behavior, products: [product.id], order: order.id)
                behaviors = [search_behavior, purchase_behavior]
                substitutions = UpsellSubstitutionCount.identify_substitutions(behaviors)
                substitutions.count.should eql(0)
            end

            it "should return 0 substitution when a product is searched for and another with a lower cost bought" do
                searched_variant = FactoryGirl.create(:variant, price: 100)
                searched_product = FactoryGirl.create(:product, variants: [searched_variant])
                search_behavior = FactoryGirl.create(:search_behavior, product: searched_product.id, price: 100)

                bought_variant = FactoryGirl.create(:variant, price: 50)
                bought_product = bought_variant.product
                line_items = [FactoryGirl.create(:line_item, price: 50, variant: bought_variant)]
                order = line_items.first.order
                purchase_behavior = FactoryGirl.create(:purchase_behavior, order: order.id, products: [bought_product.id])
                behaviors = [search_behavior, purchase_behavior]

                substitutions = UpsellSubstitutionCount.identify_substitutions(behaviors)
                substitutions.count.should eql(0)
            end

            it "should return 1 substitution when a product is searched for and another with a higher cost bought" do
                searched_variant = FactoryGirl.create(:variant, price: 100)
                searched_product = FactoryGirl.create(:product, variants: [searched_variant])
                search_behavior = FactoryGirl.create(:search_behavior, product: searched_product.id, price: 100)

                bought_variant = FactoryGirl.create(:variant, price: 150)
                bought_product = bought_variant.product
                line_items = [FactoryGirl.create(:line_item, price: 150, variant: bought_variant)]
                order = line_items.first.order
                purchase_behavior = FactoryGirl.create(:purchase_behavior, order: order.id, products: [bought_product.id])
                behaviors = [search_behavior, purchase_behavior]

                substitutions = UpsellSubstitutionCount.identify_substitutions(behaviors)
                substitutions.count.should eql(1)
            end
        end
    end
end
