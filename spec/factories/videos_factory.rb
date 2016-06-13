# Generated via
#  `rails generate curate:work Video`
#
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :video, class: Video do
    ignore do
      user { FactoryGirl.create(:user) }
    end

    sequence(:title) {|n| "Title #{n}"}
    rights { Sufia.config.cc_licenses.keys.first.dup }
    date_uploaded { Date.today }
    date_modified { Date.today }
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED

    before(:create) { |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
      work.contributor << "Some Body"
      work.creator << "Me"
    }

    after(:build) { |work| work.build_unit }

    factory :private_video do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end
    factory :public_video do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    factory :video_with_files do
      ignore do
        file_count 3
      end

      after(:create) do |work, evaluator|
        FactoryGirl.create_list(:generic_file, evaluator.file_count, batch: work, user: evaluator.user)
      end
    end
  end
end
