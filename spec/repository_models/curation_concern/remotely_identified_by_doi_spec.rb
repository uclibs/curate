
require 'spec_helper'

describe CurationConcern::RemotelyIdentifiedByDoi do
  around(:each) do |example|
    class DatastreamClass < ActiveFedora::NtriplesRDFDatastream
      map_predicates do |map|
        map.identifier({in: RDF::DC})
      end
    end

    class PropertiesDatastreamClass < ActiveFedora::OmDatastream
      set_terminology do |t|
        t.root(:path=>"fields" )
        t.identifier_url
      end

      def self.xml_template
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.fields
        end
        builder.doc
      end
    end
    example.run
    Object.send(:remove_const, :DatastreamClass)
    Object.send(:remove_const, :PropertiesDatastreamClass)
  end

  let(:model) do
    Class.new(ActiveFedora::Base) do
      has_metadata "descMetadata", type: DatastreamClass
      has_metadata 'properties', type: PropertiesDatastreamClass
      has_attributes :identifier_url, datastream: :properties, multiple: false
      include CurationConcern::RemotelyIdentifiedByDoi::Attributes
    end
  end

  describe 'Attributes' do
    subject { model.new }

    it { should respond_to(:identifier) }
    it { should respond_to(:identifier=) }
    it { should respond_to(:existing_identifier) }
    it { should respond_to(:existing_identifier=) }
    it { should respond_to(:doi_assignment_strategy=) }
    it { should respond_to(:doi_assignment_strategy) }
    it { should respond_to(:identifier_url) }
    it { should respond_to(:identifier_url=) }

  end

  describe 'MintingBehavior' do
    shared_examples 'minting behavior returning value' do
      it 'should return the returning value' do
        expect(subject.apply_doi_assignment_strategy(&perform_persistence_block)).to eq(!!returning_value)
      end
    end
    subject { model.new.tap {|m| m.extend CurationConcern::RemotelyIdentifiedByDoi::MintingBehavior } }
    let(:returning_value) { true }
    let(:perform_persistence_block) { lambda {|*| returning_value } }

    context 'with indentifier_url attribute set' do
      let(:identifier_request) { double }
      before(:each) do
        subject.stub(:identifier_url) { 'http://example.org' }
      end

      it 'calls #identifier_request' do
        expect(subject).to receive(:identifier_request)
        subject.apply_doi_assignment_strategy(&perform_persistence_block)
      end
    end

    context 'with doi_assignment_strategy accessor' do
      let(:doi_assignment_strategy) { nil }

      context '#apply_doi_assignment_strategy' do
        let(:accessor_name) { 'mint_doi' }
        let(:existing_identifier) { 'abc' }
        let(:doi_remote_service) { double(accessor_name: accessor_name) }
        before(:each) do
          subject.existing_identifier = existing_identifier
          subject.doi_assignment_strategy = doi_assignment_strategy
          subject.doi_remote_service = doi_remote_service
        end

        context 'with explicit identifier specified' do
          it_behaves_like 'minting behavior returning value'

          let(:doi_assignment_strategy) { described_class::ALREADY_GOT_ONE }
          it 'should allow explicit assignment of identifer' do
            expect {
              subject.apply_doi_assignment_strategy(&perform_persistence_block)
            }.to change(subject, :identifier).from(nil).to(existing_identifier)
          end

          it 'should yield the subject' do
            expect { |b| subject.apply_doi_assignment_strategy(&b) }.to yield_with_args(subject)
          end

          it 'should not set identifier_url attribute' do
            expect { 
              subject.apply_doi_assignment_strategy(&perform_persistence_block)
            }.to_not change(subject, :identifier_url)
          end
        end

        context 'with not now specified' do
          it_behaves_like 'minting behavior returning value'

          let(:doi_assignment_strategy) { described_class::NOT_NOW }

          it 'should return the returning value' do
            expect(subject.apply_doi_assignment_strategy(&perform_persistence_block)).to eq(returning_value)
          end

          it 'should not update identifier' do
            expect {
              subject.apply_doi_assignment_strategy(&perform_persistence_block)
            }.to_not change(subject, :identifier).from(nil)
          end

          it 'should yield the subject' do
            expect { |b| subject.apply_doi_assignment_strategy(&b) }.to yield_with_args(subject)
          end

          it 'should not set identifier_url attribute' do
            expect { 
              subject.apply_doi_assignment_strategy(&perform_persistence_block)
            }.to_not change(subject, :identifier_url)
          end
        end

        context 'with request for minting' do

          let(:doi_assignment_strategy) { accessor_name }
          context 'with valid save' do
            before(:each) do
              doi_remote_service.should_receive(:mint).with(subject).and_return(true)
            end
            it_behaves_like 'minting behavior returning value'
            let(:returning_value) { true }
            it 'should request a minting' do
              expect {
                subject.apply_doi_assignment_strategy(&perform_persistence_block)
              }.to_not change(subject, :identifier).from(nil)
            end
            ## These specs are odd - the real spec is the before block above
            it 'should set identifier_url attribute' do
              expect { 
                subject.apply_doi_assignment_strategy(&perform_persistence_block)
              }.to_not change(subject, :identifier_url)
            end
          end

          context 'with invalid save' do
            it_behaves_like 'minting behavior returning value'
            let(:returning_value) { false }
            it 'should not request a minting if the perform_persistence_block failed' do
              expect {
                subject.apply_doi_assignment_strategy(&perform_persistence_block)
              }.to_not change(subject, :identifier).from(nil)
            end
            it 'should not set identifier_url attribute' do
              expect { 
                subject.apply_doi_assignment_strategy(&perform_persistence_block)
              }.to_not change(subject, :identifier_url)
            end
          end
        end
      end
    end

    context 'without doi_assignment_strategy accessor' do
      it_behaves_like 'minting behavior returning value'

      let(:model) do
        Class.new(ActiveFedora::Base) do
          has_metadata "descMetadata", type: DatastreamClass
        end
      end
      it 'should yield the subject' do
        expect { |b| subject.apply_doi_assignment_strategy(&b) }.to yield_with_args(subject)
      end
    end

  end
end
