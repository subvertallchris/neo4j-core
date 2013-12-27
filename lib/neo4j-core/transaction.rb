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
      rescue NoMethodError => e
          _raise_invalid_session_error(session, e)
      end

      def run(session = Session.current, &block)
        session.run_tx(&block)
      rescue NoMethodError => e
        _raise_invalid_session_error(session, e)
      end

      private
        def _raise_invalid_session_error(session, e)
          # STDERR.puts e
          raise Neo4j::Session::InvalidSessionTypeError.new(session.class)
        end
    end
  end
end
