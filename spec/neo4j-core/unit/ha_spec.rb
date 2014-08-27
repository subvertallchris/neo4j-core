require 'spec_helper'

describe 'high availability' do
  describe 'query clauses' do
    let(:query_clauses) { Neo4j::Core::QueryClauses }
    it 'respond to :writable?' do
      expect(query_clauses::Clause.writable?).to be_falsey
    end

    context 'read-only clauses' do
      it 'responds false on inherited classes' do
        expect(query_clauses::WhereClause.writable?).to be_falsey
      end
    end

    context 'writable clauses' do
      it 'responds true to writable classes' do
        expect(query_clauses::CreateClause.writable?).to be_truthy
      end
    end
  end
end
