require 'rake'
require "bundler/gem_tasks"
require 'tasks'

def jar_path
  spec = Gem::Specification.find_by_name("neo4j-community")
  gem_root = spec.gem_dir
  gem_root + "/lib/neo4j-community/jars"
end

def assert_platform
  if RUBY_PLATFORM != 'java'
    puts "Cannot run tests for Embedded server since you're not running JRuby"
    exit
  end
end

desc "Run neo4j-core specs"
namespace :test do
  desc "Validity modules"
  task :validity do
    spec_files = Dir["spec/*.rb"].map do |sf|
      case sf
      when "spec/helpers.rb", "spec/spec_helper.rb"
        nil
      else
        sf
      end
    end.join(' ').strip
    success = system("rspec #{spec_files}")
    abort("RSpec neo4j-core for validity module implementation failed") unless success
  end

  desc "Run specific validity features"
  namespace :validity do
    desc "Run validity specs for Session"
    task :session do
      success = system('rspec spec/session_spec.rb')
      abort("Session validity specs failed") unless success
    end

    desc "Run validity specs for nodes"
    task :nodes do
      success = system('rspec spec/node_spec.rb')
      abort("nodes validity specs failed") unless success
    end

    desc "Run validity specs for transactions"
    task :transactions do
      success = system('rspec spec/transaction_spec.rb')
      abort("Transaction validity specs failed") unless success
    end
  end

  desc "REST implementation"
  task :rest do
    success = system('rspec spec/rest')
    abort("RSpec neo4j-core for REST implementation failed") unless success
  end

  desc "Run specific REST features"
  namespace :rest do
    desc "Run REST specs for Session"
    task :session do
      success = system('rspec spec/rest/session_spec.rb')
      abort("REST Session specs failed") unless success
    end

    desc "Run REST specs for nodes"
    task :nodes do
      success = system('rspec spec/rest/node_spec.rb')
      abort("REST nodes specs failed") unless success
    end

    desc "Run REST specs for relationships"
    task :relationships do
      success = system('rspec spec/rest/relationship_spec.rb')
      abort("REST relationships specs failed") unless success
    end

    desc "Run REST specs for Transaction"
    task :transactions do
      success = system('rspec spec/rest/transaction_spec.rb')
      abort("REST transactions specs failed") unless success
    end
  end

  desc "Embedded implementation"
  task :embedded do
    assert_platform
    success = system('rspec spec/embedded')
    abort("RSpec neo4j-core for embedded implementation failed") unless success
  end

  desc "Run specific Embedded features"
  namespace :embedded do
    desc "Run Embedded specs for Session"
    task :session do
      assert_platform
      success = system('rspec spec/embedded/session_spec.rb')
      abort("Embedded Session specs failed") unless success
    end

    desc "Run Embedded specs for nodes"
    task :nodes do
      assert_platform
      success = system('rspec spec/embedded/node_spec.rb')
      abort("Embedded nodes specs failed") unless success
    end

    desc "Run Embedded specs for relationships"
    task :relationships do
      assert_platform
      success = system('rspec spec/embedded/relationship_spec.rb')
      abort("Embedded relationships specs failed") unless success
    end

    desc "Run Embedded specs for Transaction"
    task :transactions do
      assert_platform
      success = system('rspec spec/embedded/transaction_spec.rb')
      abort("Embedded transactions specs failed") unless success
    end
  end

  desc "Run all the Session specs"
  task session: ['test:validity:session', 'test:rest:session', 'test:embedded:session']

  desc "Run all the nodes specs"
  task nodes: ['test:validity:nodes', 'test:rest:nodes', 'test:embedded:nodes']

  desc "Run all the relationships specs"
  task relationships: ['test:rest:relationships', 'test:embedded:relationships']

  desc "Run all the Transaction specs"
  task transactions: ['test:validity:transactions', 'test:rest:transactions', 'test:embedded:transactions']
end

desc "Run all the neo4j-core specs"
task test: ['test:validity', 'test:rest', 'test:embedded']

desc "Default task - testing"
task :default => [:test]
