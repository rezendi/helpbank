FactoryGirl.define do
    factory :user do |u|
        u.password "password"
        u.password_confirmation "password"
    end
    
    factory :community do |c|
        c.community_type_id 0
    end

    factory :project
    factory :labor
    factory :rating
    factory :membership
end