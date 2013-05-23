require "fpgrowth/models/transaction"

module FpGrowth
  module FpTree
    module Builder
      class FirstPass

        attr_accessor :supports
        @supports = Hash.new 0

        # Scan data and find support for each item
        # @param transactions FpGrowth::Transaction
        #
        #
        def scan(transactions)
          @supports= Hash.new(0)
          for transaction in transactions
            for item in transaction
              @supports[item] += 1
            end

          end
          return @supports
        end

        # discard infrequent items
        # @param supports Hash
        #
        def pruning(supports=@supports)
          sum=0
          for val in supports.values
            sum+=val
          end
          average = (sum / supports.size).floor
          supports.delete_if { |key, value| value < (average - (average % 10)) }
          return supports
        end

        # Ordonner les items en fonction de le support
        # Cet ordre est utilisé pour la construction du Tree lors de la seconde passe
        #
        def sort(supports=@supports)
          Hash[(supports.sort_by {|_key, value| value}.reverse)]

        end

        # Actually make the first pass
        #
        def execute(transactions)
          scan(transactions)
          pruning()
          sort()
        end

      end
    end
  end
end
