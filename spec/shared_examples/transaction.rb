module Neo4j
  shared_examples "Transaction" do
    # Do some arbitrary shit
    def do_some_arbitrary_shit
      skinny_pete = Node.new({name: "Skinny Pete", review: "Yo. Awesome style of talking man!"}, "Breaking Bad")
      pinkman = Node.new({name: "Jessie Pinkman", review: "The drug dealer yo!"}, "Breaking Bad")
      pinkman.create_rel_to skinny_pete, "Drug Dealer", type: "sub-dealer"
    end

    describe "method" do
      describe "begin" do
        it "begins a new transaction" do
          transaction = Transaction.begin
          transaction.success
          transaction.close
          expect(transaction).to be_true
        end
      end

      describe "run" do
        context "runs the block passed in a new transaction and closes the transaction" do
          it "returns the result of the block and wether the transaction was successful or not (defaults to successful" do
            _, success = Transaction.run do |t|
              do_some_arbitrary_shit
            end
            expect(success).to be_true # Successful by default
          end

          it "passes the transaction into the block to allow you to mark it as a succss or failure" do
            _, success = Transaction.run do |t|
              do_some_arbitrary_shit
              t.success
            end
            expect(success).to be_true
          end

          it "commits or rollbacks on the basis of last call of success or failure on the transaction" do
            _, success = Transaction.run do |t|
              do_some_arbitrary_shit
              t.success
              t.failure
            end
            expect(success).to be_false
          end

          it "is unaffected by close method calls. The transaction is closed automatically once the block finishes executing." do
            _, success = Transaction.run do |t|
              do_some_arbitrary_shit
              t.success
              t.close
              t.failure
            end
            # Running close inside the block has no effect.
            # The entire block is commited or rollbacked only after it has finished executing
            expect(success).to be_false
          end
        end
      end
    end
  end
end