require "spec_helper"
require "shared_examples/transaction"

module Neo4j
  describe Transaction::Rest, api: :rest do
    include_examples "Transaction"
  end
end
