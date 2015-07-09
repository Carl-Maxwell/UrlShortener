class TagTopic < ActiveRecord::Base
  validates :topic, presence: true, uniqueness: true

  has_many(
    :taggings,
    foreign_key: :topic_id,
    primary_key: :id,
    class_name: :Tagging
  )

  has_many(
    :shortened_urls,
    through: :taggings,
    source: :shortened_url
  )

  def most_popular(n)
    shortened_urls
      .joins(:visits)
      .group("shortened_urls.id").order("COUNT(visits.id) DESC").limit(n)
  end
end
