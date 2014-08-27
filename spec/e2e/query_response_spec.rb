require 'spec_helper'

describe "Neo4j::Core::QueryResponse" do
  let(:query_response) do
    query = Neo4j::Core::Query.new
    Neo4j::Core::QueryResponse.new(query, {}, {}, [])
  end
  let(:current_reader) { double("Neo4j::Session.current_reader") }
  let(:current_writer) { double("Neo4j::Session.current_writer") }

  before do
    query_response.instance_variable_set(:@write_session, current_writer)
    query_response.instance_variable_set(:@read_session, current_reader)
  end

  it 'finds writable queries' do
    query_response.instance_variable_set(:@clauses, [Neo4j::Core::QueryClauses::CreateClause, Neo4j::Core::QueryClauses::WhereClause])
    expect(query_response.preferred_session).to eq current_writer
  end

  it 'finds readable queries' do
    query_response.instance_variable_set(:@clauses, [Neo4j::Core::QueryClauses::MatchClause, Neo4j::Core::QueryClauses::WhereClause])
    expect(query_response.preferred_session).to eq current_reader
  end
end
