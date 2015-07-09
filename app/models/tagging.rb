class Tagging < ActiveRecord::Base
  belongs_to(
    :topic,
    foreign_key: :topic_id,
    primary_key: :id,
    class_name: :TagTopic
  )

  belongs_to(
    :shortened_url,
    foreign_key: :shortened_url_id,
    primary_key: :id,
    class_name: :ShortenedUrl
  )
end
