module Recommendation
    class PearsonCoefficient
        def self.compute(vector_1, vector_2)
            n = vector_1.size
            return 0 if n == 0
            sum1 = vector_1.inject(0.0){|sum, value| sum + value}
            sum2 = vector_2.inject(0.0){|sum, value| sum + value}

            sum_sq1 = vector_1.inject(0.0){|sum, value| sum += (value ** 2)}
            sum_sq2 = vector_2.inject(0.0){|sum, value| sum += (value ** 2)}

            sum_of_products = 0
            vector_1.each_with_index do |value, index|
                sum_of_products += value * vector_2[index]
            end

            num = sum_of_products - (sum1 * sum2) / n
            den = Math.sqrt(((sum_sq1 - ((sum1 ** 2) / n)) * (sum_sq2 - ((sum2 ** 2) / n))).abs)
            return 0 if den == 0
            num/den
        end
    end
end
