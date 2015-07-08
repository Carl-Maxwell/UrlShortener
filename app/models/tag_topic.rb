class TagTopic < ActiveRecord::Base
  validates :topic, presence: true, uniqueness: true
end
