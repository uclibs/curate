class CurationConcern::WorkPermission
  def self.create(work, action, editors, readers, edit_groups, read_groups)
    update_editors_and_readers(work, editors, readers, action)
    update_groups(work, edit_groups, read_groups, action)
    true
  end

  private

    def self.decide_action(attributes_collection, action_type)
      sorted = { remove: [], create: [] }
      return sorted unless attributes_collection
      if attributes_collection.is_a? Hash
        keys = attributes_collection.keys
        attributes_collection = if keys.include?('id') || keys.include?(:id)
          Array(attributes_collection)
        else
          attributes_collection.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes }
        end
      end

      attributes_collection.each do |attributes|
        if attributes['id'].present?
          if has_destroy_flag?(attributes)
            sorted[:remove] << attributes['id']
          elsif action_type == :create || action_type == :update
            sorted[:create] << attributes['id']
          end
        end
      end

      sorted
    end

    def self.has_destroy_flag?(hash)
      ["1", "true"].include?(hash['_destroy'].to_s)
    end

    def self.has_destroy_key?(hash)
      hash.key?('_destroy')
    end

    def self.has_name_key?(hash)
      hash.key?('name')
    end

    def self.is_new_editor?(hash)
      !has_destroy_key?(hash) && !has_name_key?(hash)
    end

    def self.user(person_id)
      ::User.find_by_repository_id(person_id)
    end

    def self.group(group_id)
      Hydramata::Group.find(group_id)
    end

    def self.update_editors_and_readers(work, editors, readers, action)
      collection = decide_action(editors, action)
      queue_emails_for_editors(editors, work)
      if work.remove_editors(collection[:remove].map { |u| user(u) }) && work.add_editors(collection[:create].map { |u| user(u) })
        queue_emails_for_editors(editors, work)
      end
      collection = decide_action(readers, action)
      work.remove_readers(collection[:remove].map { |u| user(u) })
      work.add_readers(collection[:create].map { |u| user(u) })
      work.save!
    end

    # This is extremely expensive because add_editor_group causes a save each time.
    def self.update_groups(work, editor_groups, reader_groups, action)
      collection = decide_action(editor_groups, action)
      work.remove_editor_groups(collection[:remove].map { |grp| group(grp) })
      work.add_editor_groups(collection[:create].map { |grp| group(grp) })

      collection = decide_action(reader_groups, action)
      work.remove_reader_groups(collection[:remove].map { |grp| group(grp) })
      work.add_reader_groups(collection[:create].map { |grp| group(grp) })
    end

    def self.queue_emails_for_editors(editors, work)
      editors.each do |editor_hash|
        if is_new_editor?(editor_hash[1])
          ChangeManager::Manager.queue_change( work.owner, 'added_as_editor', work.pid, user(editor_hash[1]['id']).email )
        elsif has_destroy_flag?(editor_hash[1])
          ChangeManager::Manager.queue_change( work.owner, 'removed_as_editor', work.pid, user(editor_hash[1]['id']).email )
        end
      end
    end
end
