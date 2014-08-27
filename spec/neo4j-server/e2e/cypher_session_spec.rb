require 'spec_helper'

module Neo4j::Server

  describe CypherSession, api: :server do

    def open_session
      create_server_session
    end

    def open_named_session(name, default = nil)
      create_named_server_session(name, default)
    end

    it_behaves_like "Neo4j::Session"

    describe 'named sessions' do

      before { Neo4j::Session.current && Neo4j::Session.current.close }
      after { Neo4j::Session.current && Neo4j::Session.current.close }

      it 'stores a named session' do
        name = :test
        test = open_named_session(name)
        expect(Neo4j::Session.named(name)).to eq(test)
      end

      it 'does not override the current session when default = false' do
        default = open_session
        current = Neo4j::Session.current
        expect(current).to eq(default)
        name = :tesr
        named = open_named_session(name)
        expect(current).to eq(default)
        expect(named).not_to eq(default)
      end

      it 'makes the new session current when default = true' do
        default = open_session
        expect(Neo4j::Session.current).to eq(default)
        name = :test
        test = open_named_session(name, true)
        expect(Neo4j::Session.current).to eq(test)
      end
    end

    describe '_query' do
      let(:a_node_id) do
        session.query.create("(n)").return("ID(n) AS id").first[:id]
      end

      it 'returns a result containing data,columns and error?' do
        result = session._query("START n=node(#{a_node_id}) RETURN ID(n)")
        expect(result.data).to eq([[a_node_id]])
        expect(result.columns).to eq(['ID(n)'])
        expect(result.error?).to be false
      end

      it "allows you to specify parameters" do
        result = session._query("START n=node({myparam}) RETURN ID(n)", myparam: a_node_id)
        expect(result.data).to eq([[a_node_id]])
        expect(result.columns).to eq(['ID(n)'])
        expect(result.error?).to be false
      end

      it 'returns error codes if not a valid cypher query' do
        result = session._query("SSTART n=node(0) RETURN ID(n)")
        expect(result.error?).to be true
        expect(result.error_msg).to match(/Invalid input/)
        expect(result.error_status).to eq('SyntaxException')
        expect(result.error_code).not_to be_empty
      end
    end

    describe 'high-availability checks' do
      include HaMethods #see spec_helper
      let(:ha_session) { Neo4j::Session }
      let(:endpoint_master_response) {double("an HTTParty response for master", code: 200, 
        body: '{"management": "http://foo:7474/db/manage/", "data": "http://foo:7474/db/data/"}')
      }
      let(:endpoint_slave_response) {double("an HTTParty response for slave", code: 200, 
        body: '{"management": "http://foo:7475/db/manage/", "data": "http://foo:7475/db/data/"}')
      }

      context 'when configured as HA' do
        before do
          Neo4j::Session.class_variable_set(:@@current_writer, nil)
          Neo4j::Session.class_variable_set(:@@current_reader, nil)
        end

        context 'with writer set first' do
          before do
            master_connect
          end

          it 'sets writer and reader immediately' do
            expect(ha_session.current_writer).to eq @s1
            expect(ha_session.current_reader).to eq @s1
          end

          it 'replaces reader when the second session is established' do
            slave_connect
            expect(ha_session.current_writer).to eq @s1
            expect(ha_session.current_reader).to eq @s2
          end
        end

        context 'with reader set first' do
          before do 
            Neo4j::Session.class_variable_set(:@@current_writer, nil)
            Neo4j::Session.class_variable_set(:@@current_reader, nil)
            slave_connect
          end

          it 'sets writer and reader immediately' do
            expect(ha_session.current_reader).to eq @s2
            expect(ha_session.current_writer).to eq @s2
          end

          it 'replaces writer when the second session is established' do
            master_connect
            expect(ha_session.current_writer).to eq @s1
            expect(ha_session.current_reader).to eq @s2
          end
        end
      end

      context 'when configured as standalone' do
        it 'sets both reader and writer immediately to the same session' do
          standalone_connect
          expect(ha_session.current_writer).to eq @s3
          expect(ha_session.current_reader).to eq @s3
        end
      end
    end
  end

end
