# Extend the Java RelationshipProxy
Java::OrgNeo4jKernelImplCore::RelationshipProxy.class_eval do
  include Neo4j::PropertyContainer::Embedded
  include Neo4j::TransactionHelpers

  def type
    run_in_transaction { _type }
  end

  def start
    run_in_transaction { _start }
  end

  def end
    run_in_transaction { _end }
  end

  def to_s
    "Embedded Relationship[#{getId}]"
  end

  def other_node(node)
    run_in_transaction { _other_node node }
  end

  def nodes
    run_in_transaction { get_nodes }
  end

  private
    def _destroy
      nodes = get_nodes
      delete
      nodes.each { |node| node.delete }
    end

    def _type
      get_type.name
    end

    def _start
      get_start_node
    end

    def _end
      get_end_node
    end

    def _other_node(node)
      case node
      when start
        self.end
      when self.end
          start
      else
        nil
      end
    end
end
