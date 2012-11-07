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
