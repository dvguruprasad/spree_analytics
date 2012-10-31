require 'spec_helper'

class ProductDecoratorSpec
    describe "Product" do
        context "#least_priced_variant" do
            it "should return nil if the product has no variants" do
                product = FactoryGirl.create(:product)
                product.least_priced_variant.should eql(nil)
            end

            it "should return the least priced variant if the product has more than one variant" do
                variant_1 = FactoryGirl.create(:variant, price: 100)
                variant_2 = FactoryGirl.create(:variant, price: 200)
                product = FactoryGirl.create(:product, :variants => [variant_1, variant_2])
                product.least_priced_variant.should eql(variant_1)
                product.least_priced_variant.price.should eql(100)
            end
        end
    end
end
