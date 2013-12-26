require "spec_helper"
require "shared_examples/transaction"

module Neo4j
  describe "Embedded Transaction", api: :embedded do
    include_examples "Transaction"
  end
end
