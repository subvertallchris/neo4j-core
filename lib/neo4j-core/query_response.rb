# module Neo4j::Core
#   class QueryResponse
#     attr_accessor :query, :options, :_params, :clauses

#     def initialize(query, options={}, params={}, clauses=[])
#       @session        = options[:session] || Neo4j::Session.current
#       @write_session  = options[:session] || Neo4j::Session.current_writer
#       @read_session   = options[:session] || Neo4j::Session.current_reader

#       @query    = query
#       @options  = options
#       @_params   = params
#       @clauses  = clauses
#     end

#     def response
#       cypher = query.to_cypher
#       response = ActiveSupport::Notifications.instrument('neo4j.cypher_query', context: options[:context] || 'CYPHER', cypher: cypher, params: _params) do
#         session = preferred_session
#         session._query(cypher, _params)
#       end
#       if !response.respond_to?(:error?) || !response.error?
#         response
#       else
#         response.raise_cypher_error
#       end
#     end

#     def preferred_session
#       writable? ? @write_session : @read_session
#     end

#     def writable?
#       @clauses.any?(&:writable?)
#     end
#   end
# end