class ShortenedUrl < ActiveRecord::Base
  validates :short_url, presence: true, uniqueness: true
  validates :submitter_id, presence: true

  belongs_to(
    :submitter,
    foreign_key: :submitter_id,
    primary_key: :id,
    class_name: :User
  )

  has_many(
    :visits,
    foreign_key: :shortened_url_id,
    primary_key: :id,
    class_name: :Visit
  )

  has_many(
    :visitors,
    Proc.new { distinct },
    through: :visits,
    source: :visitor
  )

  def self.random_code
    code = SecureRandom::urlsafe_base64

    until !ShortenedUrl.exists?(short_url: code)
      code = SecureRandom::urlsafe_base64
    end

    code
  end

  def self.create_for_user_and_long_url(user, long_url)
    created_url = ShortenedUrl.new()

    created_url.long_url = long_url
    created_url.short_url = ShortenedUrl.random_code
    created_url.submitter = user

    created_url.save!

    created_url
  end

  def num_clicks
    visits.select(:user_id).count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    recents = visits.where("created_at >= ?", 10.minutes.ago)
    recents.select(:user_id).distinct.count
  end
end
