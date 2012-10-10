class CusomModelExtensions < Spree::Extension
    User.instance_eval do
        def foo
            p "foobar"
        end
    end
end
