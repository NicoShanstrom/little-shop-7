FactoryBot.define do
  factory :coupon do
    name { "MyString" }
    code { "MyString" }
    discount_amount { 1 }
    percent_off { false }
    merchant { nil }
  end
end
