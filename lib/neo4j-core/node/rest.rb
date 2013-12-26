require "neo4j-core/property_container"

module Neo4j
  module Node
    class Rest
      include PropertyContainer::Rest
      attr_reader :session # The Rest session this node belongs to.
      attr_reader :id # The neo id of this node.
      attr_reader :node # The neography hash containing information about the node.

      # Initialize the node with a neography node and a REST session
      #
      # @param node [Hash] a neogrpahy node hash.
      # @param session [Session::Rest] the session this node was initialized to.
      #
      # @return [Node::Rest] a new rest node.
      def initialize(node, session)
        @session = session # Set the session
        @node = node # Set the node
        @id = node["self"].split('/').last.to_i # Set the id
      end

      def to_s
        "REST Node[#{@id}]"
      end

      # Create a unidirectional relationship starting from this node to another node.
      #
      # @param end_node [Node::Rest] the end node for the unidirectional relationship.
      # @param type [String, Symbol] the type of this relationship.
      # @param attributes [Hash] a hash of the initial property-value pairs.
      #
      # @return [Relationship::Rest] a new relationship between *start_node* and *end_node*.
      def create_rel_to(end_node, type, attributes = {})
        return nil if @session.url != end_node.session.url
        attributes.delete_if { |key, value| value.nil? }
        neo_rel = @session.neo.create_relationship(type, @node, end_node.node, attributes)
        return nil if neo_rel.nil?
        rel = Relationship::Rest.new(neo_rel, @session)
      rescue NoMethodError => e
        _raise_doesnt_exist_anymore_error(e)
      end

      private
        def _get_properties(*keys)
          @session.neo.get_node_properties(@node, *keys)
        end

        def _reset_properties(attributes)
          @session.neo.reset_node_properties(@node, attributes)
        end

        def _set_private_vars_to_nil
          @node = @session = nil
        end

        def _delete
          @session.neo.delete_node(@node)
        end

        def _destroy
          @session.neo.delete_node!(@node)
        end
    end
  end
end