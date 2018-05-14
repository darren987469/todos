FactoryBot.define do
  factory :user do
    password '666666'

    trait :chang do
      first_name 'Darren'
      last_name 'Chang'
      email 'darren.chang@gmail.com'
    end

    trait :handsome do
      first_name 'Darren'
      last_name 'Handsome'
      email 'darren.handsome@gmail.com'
    end

    factory :user1, traits: [:chang]
    factory :user2, traits: [:handsome]
  end
end
