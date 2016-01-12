class ScriptTagValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, input)
    if input =~ /<[^>]*script/i
      record.errors[attribute] << (options[:message] || "HTML script tags not permitted")
    end
  end

end 
