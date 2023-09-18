class User < ApplicationRecord
  has_many :orders

  def check_name
    name == "Mona"
  end
end
