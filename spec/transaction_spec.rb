require "spec_helper"

module Neo4j
  describe Transaction do
    describe "class method begin" do
      context "with invalid session" do
        it "raises error" do
          expect { Transaction.begin(:FAKE_SESSION) }.to raise_error(Session::InvalidSessionTypeError)
        end
      end
    end

    describe "class method run" do
      context "with invalid session" do
        it "raises error" do
          expect do
            Transaction.run(:FAKE_SESSION) do |t|
              t.success
            end
          end.to raise_error(Session::InvalidSessionTypeError)
        end
      end
    end
  end
end
