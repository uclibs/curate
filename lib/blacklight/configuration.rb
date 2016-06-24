require Blacklight::Engine.root.join('lib/blacklight/configuration.rb')
class Configuration < OpenStructWithHashAccess
include Blacklight::Configuration
      def default_values
        byebug
        @default_values ||= begin
          unique_key = ((SolrDocument.unique_key if defined?(SolrDocument)) || 'id')

          {
          :solr_path => 'select',
          :qt => 'search',
          :default_solr_params => {},
          :document_solr_request_handler => nil,
          :default_document_solr_params => {},
          :show => OpenStructWithHashAccess.new(:html_title => unique_key, :heading => unique_key),
          :index => OpenStructWithHashAccess.new(:show_link => unique_key, :record_display_type => 'format', :group => false),
          :spell_max => 5,
          :max_per_page => 100,
          :per_page => [10,20,50,100],
          :search_history_window => Blacklight::Catalog::SearchHistoryWindow,
          :document_index_view_types => ['list'],
          :add_facet_fields_to_solr_request => false,
          :add_field_configuration_to_solr_request => false,
          :http_method => :get
          }
        end
      end
    end
