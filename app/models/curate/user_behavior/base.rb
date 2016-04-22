module Curate
  module UserBehavior
    module Base
      extend ActiveSupport::Concern

      def repository_noid
        Sufia::Noid.noidify(repository_id)
      end

      def repository_noid?
        repository_id?
      end

      def waive_welcome_page!
        update_column(:waived_welcome_page, true)
      end

      def collections
        Collection.where(Hydra.config[:permissions][:edit][:individual] => user_key)
      end

      def get_value_from_ldap(attribute)
        # override
      end

      def manager?
        manager_usernames.include?(user_key)
      end

      def student?
        User.find_by_email(user_key).ucstatus == "Student"
      end

      def manager_usernames
        @manager_usernames ||= load_managers
      end

      def name
        name = "#{read_attribute(:first_name)} #{read_attribute(:last_name)}" 
        return name unless name.blank?
        user_key
      end

      def inverted_name
        name = "#{read_attribute(:last_name)}, #{read_attribute(:first_name)}"
        return name unless read_attribute(:last_name).blank? or read_attribute(:first_name).blank?
        ""
      end

      def groups
        person.group_pids
      end

      private

        def load_managers
          manager_config = "#{::Rails.root}/config/manager_usernames.yml"
          if File.exist?(manager_config)
            content = IO.read(manager_config)
            YAML.load(ERB.new(content).result).fetch(Rails.env).
              fetch('manager_usernames')
          else
            logger.warn "Unable to find managers file: #{manager_config}"
            []
          end
        end
    end
  end
end
