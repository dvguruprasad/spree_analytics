Deface::Override.new(:virtual_path => "spree/products/_cart_form",
                     :name => "cart_form_class_change",
                     :set_attributes => 'div#product-variants',
                     :attributes => {:class => "columns six alpha"})

Deface::Override.new(:virtual_path => "spree/products/show",
:name => "left_content_separator_div_beginning",
:replace => "[data-hook='product_show']",
:partial => "spree/products/content_show")

Deface::Override.new(:virtual_path => "spree/products/show",
:name => "show_substitutions",
:insert_after => "[data-hook='product_show']",
:partial => "spree/products/substitutes")


#Deface::Override.new(:virtual_path => "spree/shared/_search",
#                     :name => "change_search_button_to_image",
#                     :replace => "code[erb-loud]:contains('submit_tag t(:search)')",
#                     :text => "<img src=\"http://localhost:3000/spree/products/1039/mini/Large_754611993b6c6f6d29920b7845f526bf.jpeg?1344265468\" />")
