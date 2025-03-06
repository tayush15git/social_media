class User < ApplicationRecord

  has_many :tweets, dependent: :destroy
  def self.from_omniauth(auth)
    where(provider: auth["provider"], uid: auth["uid"]).first || create_from_omniauth(auth)
  end

  def self.create_from_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["nickname"]
    end
  end
end
