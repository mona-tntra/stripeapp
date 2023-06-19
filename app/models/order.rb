class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product
  enum status: { created: 0, completed: 1, cancelled: 2 }
end
