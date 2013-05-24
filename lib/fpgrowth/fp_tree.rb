require_relative 'fp_tree/node'

require 'graphviz'
require 'etc'

module FpGrowth
  module FpTree
    class FpTree
      attr_reader :root, :heads, :supports

      def initialize(supports={})
        @root = Node.new()
        @heads = Hash.new nil
        @supports = supports
        #initialiser les clés
        for k in @supports.keys
          @heads[k]=nil
        end
      end

      def item_order_lookup
        unless @lookup
          @lookup = {}
          @supports.keys.each_with_index do |item, index|
            @lookup[item] = index
          end
        end
        return @lookup

      end

      def find_lateral_leaf_for_item(item)
        cursor = heads[item]
        while cursor != nil and cursor.lateral != nil do
          cursor = cursor.lateral
        end
        return cursor
      end

      def graphviz
        g = GraphViz.new(:G, :type => :digraph)
        nodonode = {}
        nodonode[self.root]=g.add_nodes(self.root.to_s, :label => "nil")

        for row in self.heads.values
          node=row
          while node != nil
            nodonode[node]= g.add_nodes(node.to_s, :label => node.item + " : " + node.support.to_s)
            node = node.lateral
          end
        end

        for child in self.root.children
          g.add_edges(nodonode[self.root], nodonode[child])
        end

        for row in self.heads.values
          node=row
          while node != nil
            for child in node.children
              g.add_edges(nodonode[node], nodonode[child])
            end
            node = node.lateral
          end
        end


        for row in self.heads.values
          node=row
          while node != nil

            g.add_edges(nodonode[node], nodonode[node.lateral], :style => :dashed, :constraint => :false) if node.lateral
            node = node.lateral
          end
        end

        g.output(:png => "./graphs/#{Etc.getlogin}-#{items_count}-items-#{Time.now.to_s.gsub(" ", "-")}.png")

      end

      def items_count
        sum=0
        for val in supports.values
          sum+=val
        end
        return sum

      end

    end
  end
end

require_relative 'fp_tree/builder'