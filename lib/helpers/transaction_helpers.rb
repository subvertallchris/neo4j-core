module Neo4j
  module TransactionHelpers
    # Used by objects to run a block of code inside a fresh transaction associated
    def run_in_transaction(&block)
      # Retrieve appropriate session based on current type
      # REST:
      #   Session: self
      #   Entity: @session
      # Embedded:
      #   Session: self
      #   Entity: get_graph_database
      if respond_to?(:get_graph_database)
        tx = get_graph_database.begin_tx
        result = yield if block_given?
        tx.success
        tx.close
      else
        session = @session || self
        result, _ = if session.auto_tx
                      Transaction.run(session, &block)
                    else
                      send method, *args
                    end
      end
      result
    end
  end
end
