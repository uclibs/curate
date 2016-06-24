require Blacklight::Engine.root.join('lib/blacklight/solr_helper.rb')

module Blacklight::SolrHelper
include Blacklight::SolrHelper
  def query_solr(user_params = params || {}, extra_controller_params = {})
    # In later versions of Rails, the #benchmark method can do timing
    # better for us. 
    bench_start = Time.now
    solr_params = self.solr_search_params(user_params).merge(extra_controller_params)
    solr_params[:qt] ||= blacklight_config.qt
    path = blacklight_config.solr_path

    # delete these parameters, otherwise rsolr will pass them through.
    key = blacklight_config.http_method == :post ? :data : :params
    res = blacklight_solr.send_and_receive(path, {key=>solr_params.to_hash, method:blacklight_config.http_method})
    
    solr_response = Blacklight::SolrResponse.new(force_to_utf8(res), solr_params)

    Rails.logger.debug("Solr query: #{solr_params.inspect}")
    Rails.logger.debug("Solr response: #{solr_response.inspect}") if defined?(::BLACKLIGHT_VERBOSE_LOGGING) and ::BLACKLIGHT_VERBOSE_LOGGING
    Rails.logger.debug("Solr fetch: #{self.class}#query_solr (#{'%.1f' % ((Time.now.to_f - bench_start.to_f)*1000)}ms)")
    

    solr_response
  end
end
