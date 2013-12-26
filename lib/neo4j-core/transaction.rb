require "neo4j-core/transaction/placebo_transaction"

module Neo4j
  module Transaction
    class << self
      # Begins a transaction
      #
      # @param session [Session::Rest, Session::Embedded] the current running session
      #
      # @return [Transaction::Rest, Java::OrgNeo4jKernel::PlaceboTransaction] a new transaction if one is not currently running.
      #   Otherwise it returns the currently running transaction.
      def begin(session = Session.current)
        session.begin_tx
      rescue NoMethodError
          _raise_invalid_session_error(session)
      end

      def run(session = Session.current, &block)
        PlaceboTransaction.run self.begin(session), &block
      end

      private
        def _raise_invalid_session_error(session)
          raise Neo4j::Session::InvalidSessionTypeError.new(session.class)
        end
    end
  end
end
