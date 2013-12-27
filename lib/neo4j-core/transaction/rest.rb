module Neo4j
  module Transaction
    class Rest < Placebo
      def initialize(session)
        @session = session
        @tx = @session.neo.begin_transaction
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
        if @success
          @session.neo.commit_transaction @tx
        else
          @session.neo.rollback_transaction @tx
        end
      end
    end
  end
end
