module ParamsHelper

  # This method is called before the search_as_hidden_fields method to wipe
  # out any parameters that are "unknown" to the application.  This should
  # resolve the cross-site scripting warning generated by UC's Hailstorm scan.

  def scrub_params(params)
    safe_params = Hash.new;

    unless params["f"].nil?
      safe_params["f"] = Hash.new;
      safe_params["f"]["desc_metadata__creator_sim"] = params["f"]["desc_metadata__creator_sim"]
      safe_params["f"]["desc_metadata__language_sim"] = params["f"]["desc_metadata__language_sim"]
      safe_params["f"]["desc_metadata__publisher_sim"] = params["f"]["desc_metadata__publisher_sim"]
      safe_params["f"]["desc_metadata__subject_sim"] = params["f"]["desc_metadata__subject_sim"]
      safe_params["f"]["generic_type_sim"] = params["f"]["generic_type_sim"]
      safe_params["f"]["human_readable_type_sim"] = params["f"]["human_readable_type_sim"]
    end

    safe_params["controller"] = params["controller"]
    safe_params["action"] = params["action"]
    safe_params["works"] = params["works"]

    params.clear

    unless safe_params["f"].nil?
      params["f"] = Hash.new
      params["f"]["desc_metadata__creator_sim"] = safe_params["f"]["desc_metadata__creator_sim"] unless safe_params["f"]["desc_metadata__creator_sim"].nil?
      params["f"]["desc_metadata__language_sim"] = safe_params["f"]["desc_metadata__language_sim"] unless safe_params["f"]["desc_metadata__language_sim"].nil?
      params["f"]["desc_metadata__publisher_sim"] = safe_params["f"]["desc_metadata__publisher_sim"] unless safe_params["f"]["desc_metadata__publisher_sim"].nil?
      params["f"]["desc_metadata__subject_sim"] = safe_params["f"]["desc_metadata__subject_sim"] unless safe_params["f"]["desc_metadata__subject_sim"].nil?
      params["f"]["generic_type_sim"] = safe_params["f"]["generic_type_sim"] unless safe_params["f"]["generic_type_sim"].nil?
      params["f"]["human_readable_type_sim"] = safe_params["f"]["human_readable_type_sim"] unless safe_params["f"]["human_readable_type_sim"].nil?
    end

    params["controller"] = safe_params["controller"] unless safe_params["controller"].nil?
    params["action"] = safe_params["action"] unless safe_params["action"].nil?
    params["works"] = safe_params["works"] unless safe_params["works"].nil?
  end

  def check_parameters?(params_to_check=[:page, :per_page])

    render(:file => File.join(Rails.root, 'public/404.html'), :status => 404) unless params[:page].to_i.to_s == params[:page] or params[:page].nil?
    render(:file => File.join(Rails.root, 'public/404.html'), :status => 404) unless params[:page].to_i < 1000
    render(:file => File.join(Rails.root, 'public/404.html'), :status => 404) if params[:page] && params[:page].to_i < 1

    render(:file => File.join(Rails.root, 'public/404.html'), :status => 404) unless params[:per_page].to_i.to_s == params[:per_page] or params[:per_page].nil?
    render(:file => File.join(Rails.root, 'public/404.html'), :status => 404) unless params[:per_page].to_i < 1000
    render(:file => File.join(Rails.root, 'public/404.html'), :status => 404) if params[:per_page] && params[:per_page].to_i < 1

    limit_param_length(params[:q], 1000) unless defined?(params[:q]) == nil
    limit_param_length(params["f"]["desc_metadata__creator_sim"], 1000) unless defined?(params["f"]["desc_metadata__creator_sim"]) == nil
    limit_param_length(params["f"]["desc_metadata__language_sim"], 1000) unless defined?(params["f"]["desc_metadata__language_sim"]) == nil
    limit_param_length(params["f"]["desc_metadata__publisher_sim"], 1000) unless defined?(params["f"]["desc_metadata__publisher_sim"]) == nil
    limit_param_length(params["f"]["desc_metadata__subject_sim"], 1000) unless defined?(params["f"]["desc_metadata__subject_sim"]) == nil
    limit_param_length(params["f"]["generic_type_sim"], 1000) unless defined?(params["f"]["generic_type_sim"]) == nil
    limit_param_length(params["f"]["human_readable_type_sim"], 1000) unless defined?(params["f"]["human_readable_type_sim"]) == nil
    limit_param_length(params["utf8"], 1000) unless defined?(params["utf8"]) == nil
    limit_param_length(params["works"], 1000) unless defined?(params["works"]) == nil
    limit_param_length(params["collectible_id"], 1000) unless defined?(params["collectible_id"]) == nil
    limit_param_length(params["profile_collection_id"], 1000) unless defined?(params["profile_collection_id"]) == nil

    limit_param_length(params["hydramata_group"]["members_attributes"]["0"]["id"], 100) unless defined?(params["hydramata_group"]["members_attributes"]["0"]["id"]) == nil
    limit_param_length(params["hydramata_group"]["members_attributes"]["1"]["id"], 100) unless defined?(params["hydramata_group"]["members_attributes"]["1"]["id"]) == nil
    limit_param_length(params["hydramata_group"]["members_attributes"]["0"]["_destroy"], 100) unless defined?(params["hydramata_group"]["members_attributes"]["0"]["_destroy"]) == nil
    limit_param_length(params["hydramata_group"]["members_attributes"]["1"]["_destroy"], 100) unless defined?(params["hydramata_group"]["members_attributes"]["1"]["_destroy"]) == nil

    limit_param_length(params["article"]["editors_attributes"]["0"]["id"], 100) unless defined?(params["article"]["editors_attributes"]["0"]["id"]) == nil
    limit_param_length(params["article"]["editors_attributes"]["1"]["id"], 100) unless defined?(params["article"]["editors_attributes"]["1"]["id"]) == nil
     limit_param_length(params["article"]["editor_groups_attributes"]["0"]["id"], 100) unless defined?(params["article"]["editor_groups_attributes"]["0"]["id"]) == nil
    limit_param_length(params["article"]["editor_groups_attributes"]["1"]["id"], 100) unless defined?(params["article"]["editor_groups_attributes"]["1"]["id"]) == nil

    limit_param_length(params["image"]["related_work_tokens"], 100) unless defined?(params["image"]["related_work_tokens"]) == nil
    limit_param_length(params["image"]["editor_groups_attributes"]["0"]["id"], 100) unless defined?(params["image"]["editor_groups_attributes"]["0"]["id"]) == nil
    limit_param_length(params["image"]["editor_groups_attributes"]["1"]["id"], 100) unless defined?(params["image"]["editor_groups_attributes"]["1"]["id"]) == nil

  end

  def check_blind_sql_parameters_loop?()
    params.clone.each do |key, value|
        if value.is_a?(Hash)
          value.clone.each do |k,v|
            unless defined?(v) == nil
              if v.to_s.include?('waitfor delay') || v.to_s.include?('DBMS_LOCK.SLEEP') || v.to_s.include?('SLEEP(5)') || v.to_s.include?('SLEEP(10)')
                render(:file => File.join(Rails.root, 'public/404.html'), :status => 404)
                return false
                break
              end
            end
          end
        else
          unless defined?(value) == nil
            if value.to_s.include?('waitfor delay') || value.to_s.include?('DBMS_LOCK.SLEEP') || value.to_s.include?('SLEEP(5)') || value.to_s.include?('SLEEP(10)')
              render(:file => File.join(Rails.root, 'public/404.html'), :status => 404)
              return false
              break
            end
          end
        end
    end
  end

  protected

    def limit_param_length(parameter, length_limit)
      render(:file => File.join(Rails.root, 'public/404.html'), :status => 404) unless parameter.to_s.length < length_limit
    end

end
