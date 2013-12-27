module Neo4j
  module Transaction
    class Placebo
      def success
        @success = true
      end

      def failure
        @success = false
      end
      
      def close
      end

      def success?
        @success
      end

      def self.run(tx)
        placebo = new
        placebo.success # Mark for success by default
        result = yield(placebo) if block_given?
        if placebo.success?
          tx.success
        else
          tx.failure
        end
        tx.close
        return result, placebo.success?
      rescue Exception => e
        # Roll back the transaction
        tx.failure
        tx.close
        raise e # Let the exception bubble up
      end
    end
  end
end
