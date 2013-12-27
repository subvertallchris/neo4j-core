# Extend the Java NodeProxy
Java::OrgNeo4jKernelImplCore::NodeProxy.class_eval do
  include Neo4j::PropertyContainer::Embedded
  include Neo4j::TransactionHelpers

  def to_s
    "Embedded Node[#{getId}]"
  end

  def create_rel_to(end_node, name, attributes = {})
    run_in_transaction { _create_rel_to end_node, name, attributes }
  end

  private
    def _destroy
      get_relationships.each { |r| r.delete }
      delete
    end

    def _create_rel_to(end_node, name, attributes)
      return nil if get_graph_database != end_node.get_graph_database
      type = Java::OrgNeo4jGraphdb::DynamicRelationshipType.with_name(name)
      rel = create_relationship_to(end_node, type)
      if (rel.isType(type))
        rel.props = attributes
        rel
      else
        nil
      end
    end
end
