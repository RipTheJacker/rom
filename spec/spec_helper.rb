# encoding: utf-8

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    command_name 'spec:unit'

    add_filter 'config'
    add_filter 'lib/rom/support'
    add_filter 'spec'
  end
end

class BasicObject
  def self.freeze
    # FIXME: remove this when axiom no longer freezes classes
  end
end

require 'devtools/spec_helper'

require 'rom-relation'
require 'rom-mapper'
require 'rom-session'
require 'rom/support/axiom/adapter/memory'

require 'bogus/rspec'

include ROM
include SpecHelper

TEST_ENV = Environment.setup(test: 'memory://test')

TEST_ENV.schema do
  base_relation :users do
    repository :test

    attribute :id,   Integer
    attribute :name, String

    key :id
  end
end

TEST_ENV.mapping do
  users do
    model mock_model(:id, :name)
    map :id, :name
  end
end
