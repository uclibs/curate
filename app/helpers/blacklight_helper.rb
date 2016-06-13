require Blacklight::Engine.root.join('app/helpers/blacklight/hash_as_hidden_fields_helper_behavior')
require Blacklight::Engine.root.join('app/helpers/blacklight/render_constraints_helper_behavior')
require Blacklight::Engine.root.join('app/helpers/blacklight/html_head_helper_behavior')
require Blacklight::Engine.root.join('app/helpers/blacklight/facets_helper_behavior')

require Blacklight::Engine.root.join('app/helpers/hash_as_hidden_fields_helper')
require Blacklight::Engine.root.join('app/helpers/render_constraints_helper')
require Blacklight::Engine.root.join('app/helpers/html_head_helper')
require Blacklight::Engine.root.join('app/helpers/facets_helper')

require Blacklight::Engine.root.join('app/helpers/blacklight/blacklight_helper_behavior')

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def application_name
    t('sufia.product_name')
  end

  ## Override the default seperator used to display multivalue fields on the index view
  def field_value_separator
    tag(:br)
  end

  ## Override to return the Collection title when the search is filtered by collection pid
  include Blacklight::FacetsHelperBehavior
  def facet_display_value field, item
    facet_config = facet_configuration_for_field(field)

    value = if item.respond_to? :label
      value = item.label
    else
      facet_value_for_facet_item(item)
    end

    display_label = case
      when facet_config.helper_method
        display_label = send facet_config.helper_method, value
      when (facet_config.query and facet_config.query[value])
        display_label = facet_config.query[value][:label]
      when facet_config.date
        localization_options = {}
        localization_options = facet_config.date unless facet_config.date === true
        display_label = l(value.to_datetime, localization_options)
      when facet_config.field == "collection_sim"
        Collection.find(value).title
      else
        value
    end
  end

  ## Override to insert "Collection" label when serch is filtered by collection pid
  ## Because this isn't configured as a normal facet, we need to do this
  include Blacklight::RenderConstraintsHelperBehavior
  def render_filter_element(facet, values, localized_params)
    facet_config = facet_configuration_for_field(facet)

    if facet == "collection_sim"
      values.map do |val|
        render_constraint_element( "Collection",
          facet_display_value(facet, val),
          :remove => url_for(remove_facet_params(facet, val, localized_params)),
          :classes => ["filter", "filter-" + facet.parameterize]
        ) + "\n"
      end
    else
      values.map do |val|
        render_constraint_element( facet_field_labels[facet],
          facet_display_value(facet, val),
          :remove => url_for(remove_facet_params(facet, val, localized_params)),
          :classes => ["filter", "filter-" + facet.parameterize]
        ) + "\n"
      end
    end
  end
end
