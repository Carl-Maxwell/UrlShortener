class ShortenedUrl < ActiveRecord::Base
  validates :short_url, presence: true, uniqueness: true
  validates :submitter_id, presence: true
  validates :long_url, presence: true, length: { maximum: 255 }
  validate :submitter_cannot_be_a_spammer
  validate :regular_user_limit

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

  has_many(
    :taggings,
    foreign_key: :shortened_url_id,
    primary_key: :id,
    class_name: :Tagging
  )

  has_many(
    :topics,
    through: :taggings,
    source: :topic
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

  def submitter_cannot_be_a_spammer
    if User.find(submitter_id).recent_submissions_count >= 5
      errors.add(:submitter_id, "cannot submit more than 5 URLs in a minute")
    end
  end

  def regular_user_limit
    submitter = User.find(submitter_id)
    unless submitter.is_premium || submitter.shortened_urls.count < 5
      errors.add(:submitter_id, "cannot submit more than 5 URLS unless premium")
    end
  end

  def self.prune(n)
    ids = self.all
      .joins("JOIN users ON users.id = shortened_urls.submitter_id")
      .where("users.is_premium = FALSE")
      .joins(:visits)
      .group(:shortened_url_id)
      .having("MAX(visits.created_at) < ?", n.minutes.ago)
      .select('shortened_urls.id')
      .map(&:id)

    #self.destroy_all(id: ids)
  end
end
