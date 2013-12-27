require "helpers/argument_helpers"
require "helpers/transaction_helpers"
require "neo4j-core/session"
require "neo4j-core/property_container"
require "neo4j-core/node"
require "neo4j-core/node/rest"
require "neo4j-core/relationship"
require "neo4j-core/relationship/rest"
require "neo4j-core/transaction"
require "neo4j-core/transaction/placebo"
require "neo4j-core/transaction/rest"

# If the platform is Java then load all java related files.
if RUBY_PLATFORM == 'java'
  require "java"
  require "neo4j-community"
  require "neo4j-core/node/embedded"
  require "neo4j-core/relationship/embedded"
end

# @author Ujjwal Thaakar
module Neo4j
end
