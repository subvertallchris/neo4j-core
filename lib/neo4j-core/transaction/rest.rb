module Neo4j
  module Transaction
    class Rest < Placebo
      def initialize(session)
        @session = session
        @tx = @session.neo.begin_transaction "start n=node(*) return n"
        @tx
        # Mark for failure by default
        failure
      end

      def keep_alive
        @session.neo.keep_transaction @tx
      end

      def <<(query, params={}, formats=nil)
        query = [query, params] unless query.is_a?(Array)
        query << formats if formats.is_a?(Array)
        @session.neo.in_transaction @tx, query
      end

      def close
        if success?
          @session.neo.commit_transaction @tx
        else
          @session.neo.rollback_transaction @tx
        end
        id = self.class.id_mapper(@session)
        Thread.current[id] = nil if Thread.current[id] == self
      end

      class << self
        def begin_tx(session)
          id = id_mapper(session)
          # Fetch the transaction associated with session. If none is found then begin a new one.
          Thread.current[id] || Thread.current[id] = new(session)
        end
        
        # Identity mapper
        def id_mapper(session)
          "Neo4j::#{session}"
        end
      end
    end
  end
end
