#!/usr/bin/env ruby


# System include
require 'savon'

# Custom include
require 'spec_helper'


module Clearbooks

  describe Clearbooks do

    before(:all) { savon.mock! }
    after(:all) { savon.unmock! }

    let(:message) { :any }

    describe '::create_entity' do
      let(:entity) do
        Entity.new(company_name: 'Example Inc.',
                   contact_name: 'John Doe',
                   address1: 'London',
                   country: 'UL',
                   postcode: '01100',
                   email: 'info@example.com',
                   website: 'http://example.com',
                   phone1: '01234 567890',
                   supplier: {
                       default_account_code: '1001001',
                       default_credit_terms: 30,
                       default_vat_rate: 0
                   })
      end

      let(:xml) { File.read('spec/fixtures/response/create_entity.xml') }

      let(:response) do
        savon.expects(:create_entity).with(message: message).returns(xml)
        Clearbooks.create_entity(entity)
      end

      it 'creates a new entity' do
        expect(response).to be_a Hash
        expect(response[:entity_id]).to be_a Fixnum
        expect(response[:entity_id]).to be > 0
      end
    end

    describe '::update_entity' do
      let(:entity) do
        Entity.new(id: 10,
                   company_name: 'Example Inc.',
                   contact_name: 'John Doe',
                   address1: 'London',
                   country: 'UK',
                   postcode: '01100',
                   email: 'info@example.com',
                   website: 'http://example.com',
                   phone1: '01234 567890',
                   supplier: {
                       default_account_code: '1001001',
                       default_credit_terms: 30,
                       default_vat_rate: 0
                   })
      end

      let(:xml) { File.read('spec/fixtures/response/update_entity.xml') }

      let(:response) do
        savon.expects(:update_entity).with(message: message).returns(xml)
        Clearbooks.update_entity(entity)
      end

      it 'updates existing entity' do
        expect(response).to be_a Hash
        expect(response[:entity_id]).to be_a Fixnum
        expect(response[:entity_id]).to be > 0
      end
    end

    describe '::list_entities' do
      let(:xml) { File.read('spec/fixtures/response/list_entities.xml') }

      let(:entities) do
        savon.expects(:list_entities).with(message: message).returns(xml)
        Clearbooks.list_entities
      end

      it 'returns list of entnties' do
        expect(entities).to be_an Array
        expect(entities.length).to eq 2
      end

      describe Entity do
        let(:entity) {entities.last}

        it 'is an Entity' do
          expect(entity).to be_an Entity
        end

        it 'has proper attribute values' do
          expect(entity.id).to eq 6
          expect(entity.company_name).to eq 'Example Inc.'
          expect(entity.contact_name).to eq 'John Foo'
          expect(entity.address1).to eq 'Street 1'
          expect(entity.town).to eq 'London'
          expect(entity.county).to eq 'United Kingdom'
          expect(entity.postcode).to eq '01100'
          expect(entity.email).to eq 'info@example.com'
          expect(entity.phone1).to eq '01234 567890'
          expect(entity.building).to eq 'Building2'
          expect(entity.address2).to eq 'Street2'
          expect(entity.phone2).to eq '1234 567890'
          expect(entity.fax).to eq '2345 67890'
          expect(entity.website).to eq 'http://example.com'
          expect(entity.external_id).to eq '3'
          expect(entity.statement_url).to eq 'https://secure.clearbooks.co.uk/'
          expect(entity.supplier[:default_account_code]).to eq '30'
          expect(entity.supplier[:default_vat_rate]).to eq '10'
          expect(entity.supplier[:default_credit_terms]).to eq 30
          expect(entity.customer).to be_nil
        end
      end
    end

    describe '::delete_entity' do
      let(:xml) { File.read('spec/fixtures/response/delete_entity.xml') }

      it 'deletes an entity with given id' do
        savon.expects(:delete_entity).with(message: message).returns(xml)
        expect(Clearbooks.delete_entity(1)).to eq true
      end
    end

  end

end
