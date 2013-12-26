module Neo4j
  module Session
    # A session to an embedded instance of Neo4J
    class Embedded
      # @!attribute
      #   @return [Boolean] Auto Transaction flag. Enabled by default.
      attr_accessor :auto_tx

      # Create a new session to an embedded database.
      #
      # @param path [String] a path to the location of the embedded database.
      # @param auto_tx [Boolean] an optional flag to set auto transaction (defaults to true).
      #
      # @return [Embedded] a new embedded session.
      def initialize(path = "neo4j", auto_tx = true)
        raise "Cannot start a embedded session without JRuby" if RUBY_PLATFORM != 'java'
        @db_location = path
        @running = false
        @auto_tx = auto_tx
      end

      # @return [Boolean] wether the session is running or not.
      def running?
        @running
      end

      # @return [Java::OrgNeo4jKernel::EmbeddedGraphDatabase] the Java graph database backing this session.
      def database
        @db
      end

      # @return [Boolean] wether the session started successfully.
      def start
        return false if @started
        @started = true
        @db = Java::OrgNeo4jGraphdbFactory::GraphDatabaseFactory.new.new_embedded_database(@db_location)
        @running = true
      end

      # @return [Boolean] wether the session stopped successfully.
      def stop
        return false if @stopped
        @db.shutdown
        @running = false
        @stopped = true
      end

      def begin_tx
        @db.begin_tx
      end

      # Nodes
      # Create a new node. If auto_tx is true then we begin a new transaction and commit it after the creation
      def create_node(attributes, labels)
        if @auto_tx
          node, result = Transaction.run(self) { _create_node(attributes, labels) }
          node = nil unless result
          node
        else
          _create_node(attributes, labels)
        end
      end

      def load(id)
        @db.get_node_by_id(id)
      end

      def load_rel(id)
        @db.get_relationship_by_id(id)
      end

      def to_s
        @db_location
      end

      private
        def _create_node(attributes, labels)
          labels.map! { |label| Java::OrgNeo4jGraphdb::DynamicLabel.label(label) }
          node = @db.create_node(*labels)
          node.props = attributes
          node
        end
    end
  end
end
