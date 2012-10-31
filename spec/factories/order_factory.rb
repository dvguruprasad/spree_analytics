FactoryGirl.define do
  factory :order_with_line_items, :parent => :order do
    ignore do
        number_of_line_items 1
    end
    after_create do |order|
      number_of_line_items.times { FactoryGirl.create(:line_item, :order => order) }
    end
  end
end
