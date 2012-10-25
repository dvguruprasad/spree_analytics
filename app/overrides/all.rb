Deface::Override.new(:virtual_path => "spree/products/show",
                     :name => "show_substitutions",
                     :insert_after => "[data-hook='product_show']",
                     :partial => "spree/products/substitutes")
