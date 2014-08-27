module Neo4j
  class Session

    @@current_session = @@current_reader = @@current_writer = nil
    @@all_sessions = {}
    @@factories = {}

    # @abstract
    def close
      self.class.unregister(self)
    end

    # Only for embedded database
    # @abstract
    def start
      raise "not impl."
    end

    # Only for embedded database
    # @abstract
    def shutdown
      raise "not impl."
    end

    # Only for embedded database
    # @abstract
    def running
      raise "not impl."
    end

    # @return [:embedded_db | :server_db]
    def db_type
      raise "not impl."
    end

    def auto_commit?
      true # TODO
    end

    # @abstract
    def begin_tx
      raise "not impl."
    end

    class CypherError < StandardError
      attr_reader :error_msg, :error_status, :error_code
      def initialize(error_msg, error_code, error_status)
        super(error_msg)
        @error_msg = error_msg
        @error_status = error_status
      end
    end


    # Performs a cypher query.  See {Neo4j::Core::Query} for more details, but basic usage looks like:
    #
    # @example Using cypher DSL
    #   Neo4j::Session.query.match("(c:person)-[:friends]->(p:person)").where(c: {name: 'andreas'}).pluck(:p).first[:name]
    #
    # @example Show the generated Cypher
    #   Neo4j::Session.query..match("(c:person)-[:friends]->(p:person)").where(c: {name: 'andreas'}).return(:p).to_cypher
    #
    # @example Use Cypher string instead of the cypher DSL
    #   Neo4j::Session.query("MATCH (c:person)-[:friends]->(p:person) WHERE c.name = \"andreas\" RETURN p").first[:p][:name]
    #
    # @return [Neo4j::Core::Query, Enumerable] return a Query object for DSL or a Enumerable if using raw cypher strings
    # @see http://docs.neo4j.org/chunked/milestone/cypher-query-lang.html The Cypher Query Language Documentation
    #
    def query(options = {})
      raise 'not implemented, abstract'
    end

    # Same as #query but does not accept an DSL and returns the raw result from the database.
    # Notice, it might return different values depending on which database is used, embedded or server.
    # @abstract
    def _query(*params)
      raise 'not implemented'
    end

    class << self
      # Creates a new session to Neo4j
      # @see also Neo4j::Server::CypherSession#open for :server_db params
      # @param db_type the type of database, e.g. :embedded_db, or :server_db
      def open(db_type=:server_db, url='http://localhost:7474', params={})
        if db_type != :server_db && params[:name]
          raise "Multiple sessions is currently only supported for Neo4j Server connections."
        end
        create_session(db_type, url, params)
      end

      def create_session(db_type, url='http://localhost:7474', params={})
        unless (@@factories[db_type])
          raise "Can't connect to database '#{db_type}', available #{@@factories.keys.join(',')}"
        end
        @@factories[db_type].call(url, params)
      end

      def current
        @@current_session
      end

      def current_reader
        @@current_reader
      end

      def current_writer
        @@current_writer
      end

      def current!
        raise "No session, please create a session first with Neo4j::Session.open(:server_db) or :embedded_db" unless current
        current
      end

      # @see Neo4j::Session#query
      def query(options = {})
        current!.query(options)
      end

      def named(name)
        @@all_sessions[name] || raise("No session named #{name}.")
      end

      def set_current(session, default)
        if (default || default.nil?) || !!@@current_session
          @@current_session = session
        end
        @@current_session
      end

      def set_current_writer(session, default)
        @@current_writer = session
        set_current_reader(session, default) unless @@current_reader
        set_current(session, default)
      end

      def set_current_reader(session, default)
        @@current_reader = session
        set_current_writer(session, default) unless @@current_writer
        set_current(session, default)
      end

      # Registers a callback which will be called immediately if session is already available,
      # or called when it later becomes available.
      def on_session_available(&callback)
        if (Neo4j::Session.current)
          callback.call(Neo4j::Session.current)
        end
        add_listener do |event, data|
          callback.call(data) if event == :session_available
        end
      end

      def add_listener(&listener)
        self._listeners << listener
      end

      def _listeners
        @@listeners ||= []
        @@listeners
      end

      def _notify_listeners(event, data)
        _listeners.each {|li| li.call(event, data)}
      end

      def register(session, name = nil, default = nil, ha_state = false)
        !ha_state ? standalone_register(session, name, default) : ha_register(session, name, default, ha_state)
      end

      def standalone_register(session, name, default)
        @@all_sessions[name] = session if name
        set_current_writer(session, default)
        set_current_reader(session, default)
        @@current_session
      end

      def ha_register(session, name, default, ha_state)
        @@all_sessions[name] = name if name
        @ha_status = true
        ha_state == :master ? set_current_writer(session, default) : set_current_reader(session, default)
        @@current_session
      end

      def ha_status
        !!@ha_status
      end

      def unregister(session)
        @@current_session = nil if @@current_session == session
      end

      def inspect
         "Neo4j::Session available: #{@@factories && @@factories.keys}"
      end

      def register_db(db, &session_factory)
        puts "replace factory for #{db}" if @@factories[db]
        @@factories[db] = session_factory
      end
    end
  end
end
