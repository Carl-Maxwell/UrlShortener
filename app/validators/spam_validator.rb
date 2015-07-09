class SpamValidator < ActiveModel::EachValidator
  def validate_each(record, attribute_name, value)
    unless User.find(value).recent_submissions_count < 5
      message = options[:message] || "has spammed too much"
      record.errors[attribute_name] << message
    end
  end
end
