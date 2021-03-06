# encoding: utf-8

require 'spec_helper'

describe 'Defining a ROM schema' do
  let(:people) {
    Axiom::Relation::Base.new(:people, people_header)
  }

  let(:people_with_address) {
    Axiom::Relation::Base.new(:people, people_header).wrap(
      address: addresses.header
    )
  }

  let(:people_with_profiles) {
    Axiom::Relation::Base.new(:people, people_header).group(
      profiles: profiles.header
    )
  }

  let(:addresses) {
    Axiom::Relation::Base.new(
      :addresses,
      [[:id, Integer], [:street, String], [:city, String], [:zipcode, String]]
    )
  }

  let(:people_header) {
    Axiom::Relation::Header.coerce(people_attributes, keys: people_keys)
  }

  let(:people_attributes) {
    [[:id, Integer], [:name, String]]
  }

  let(:people_keys) {
    [:id]
  }

  let(:profiles) {
    Axiom::Relation::Base.new(:profiles, profiles_header)
  }

  let(:profiles_header) {
    Axiom::Relation::Header.coerce(profiles_attributes, keys: profiles_keys)
  }

  let(:profiles_attributes) {
    [[:id, Integer], [:person_id, Integer], [:text, String]]
  }

  let(:profiles_keys) {
    [:id, :person_id]
  }

  let(:people_with_joined_profiles) {
    people.join(profiles.rename(id: :profile_id, person_id: :id))
  }

  let(:env)        { Environment.setup(test: 'memory://test') }
  let(:repository) { env.repository(:test) }

  let(:schema) do
    env.schema do
      base_relation :addresses do
        repository :test

        attribute :id, Integer
        attribute :street, String
        attribute :city, String
        attribute :zipcode, String
      end

      base_relation :people do
        repository :test

        attribute :id,   Integer
        attribute :name, String

        key :id
      end

      base_relation :profiles do
        repository :test

        attribute :id,        Integer
        attribute :person_id, Integer
        attribute :text,      String

        key :id
        key :person_id
      end

      base_relation :people_with_address do
        repository :test

        attribute :id,   Integer
        attribute :name, String

        wrap address: addresses.header

        key :id
      end

      base_relation :people_with_profiles do
        repository :test

        attribute :id,   Integer
        attribute :name, String

        group profiles: profiles.header

        key :id
      end
    end

    env.schema do
      relation :people_with_joined_profiles do
        people.join(profiles.rename(id: :profile_id, person_id: :id))
      end
    end
  end

  it 'registers the people relation' do
    expect(schema[:people]).to eq(people)
  end

  it 'registers the people with wrapped addresses relation' do
    expect(schema[:people_with_address]).to eq(people_with_address)
  end

  it 'registers the people with grouped profiles relation' do
    expect(schema[:people_with_profiles]).to eq(people_with_profiles)
  end

  it 'establishes key attributes for people relation' do
    expect(schema[:people].header.keys).to include(*people_keys)
  end

  it 'establishes key attributes for profiles relation' do
    expect(schema[:profiles].header.keys).to include(*profiles_keys)
  end

  it 'registers the profiles relation' do
    expect(schema[:profiles]).to eq(profiles)
  end

  it 'registers the people_with_joined_profile relation' do
    expect(schema[:people_with_joined_profiles]).to eq(people_with_joined_profiles)
  end
end
