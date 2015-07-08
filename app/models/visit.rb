class Visit < ActiveRecord::Base
    validates :user_id, presence: true
    validates :shortened_url_id, presence: true

    belongs_to(
      :visitor,
      foreign_key: :user_id,
      primary_key: :id,
      class_name: :User
    )

    belongs_to(
      :shortened_url,
      foreign_key: :shortened_url_id,
      primary_key: :id,
      class_name: :ShortenedUrl
    )

  def self.record_visit!(user, shortened_url)
    visit = Visit.new()
    visit.visitor = user
    visit.shortened_url = shortened_url
    visit.save!
  end
end
