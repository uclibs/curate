module CurationConcern
  module WithEditorsAndReaders
    extend ActiveSupport::Concern

    included do
      before_destroy :clear_associations
    end

    def add_reader_group(group)
      add_group(group, :read)
    end

    def add_editor_group(group)
      add_group(group, :edit)
    end

    # @param groups [Array<Hydramata::Group>] a list of groups to add 
    def add_reader_groups(groups)
      add_groups(groups, :read)
    end

    def add_editor_groups(groups)
      add_groups(groups, :edit)
    end

    def remove_reader_group(group)
      remove_group(group, :read)
    end

    def remove_editor_group(group)
      remove_group(group, :edit)
    end

    # @param groups [Array<Hydramata::Group>] a list of users to remove
    def remove_reader_groups(groups)
      remove_groups(groups, :read)
    end

    def remove_editor_groups(groups)
      remove_groups(groups, :edit)
    end

    # @param user [User] the user account you want to grant edit access to.
    def add_reader(user)
      add_user(user, :read)
    end

    def add_editor(user)
      add_user(user, :edit)
    end

    # @param users [Array<User>] a list of users to add
    def add_readers(users)
      add_users(users, :read)
    end

    def add_editors(users)
      add_users(users, :edit)
    end

    # @param user [User] the user account you want to revoke edit access for.
    def remove_reader(user)
      remove_user(user, :read)
    end

    def remove_editor(user)
      remove_user(user, :edit)
    end

    # @param users [Array<User>] a list of users to remove
    def remove_readers(users)
      remove_users(users, :read)
    end

    def remove_editors(users)
      remove_users(users, :edit)
    end

    private

    # Decide if the user can be removed as an editor.  They cannot be removed
    # if they are the depositor or if they are not presently an editor
    # @param user [User] the user to remove
    def can_remove_editor?(user)
      owner != user.user_key && editors.include?(user.person)
    end

    def add_group(group, access_type)
      raise ArgumentError, "parameter is #{group.inspect}, expected a kind of Hydramata::Group" unless group.is_a?(Hydramata::Group)

      if access_type == :edit
        editor_groups << group
        self.permissions_attributes = [{ name: group.pid, access: 'edit', type: 'group' }]
        group.editable_works << self
        group.save!
      elsif access_type == :read
        reader_groups << group
        set_read_groups([group.pid], [])
        group.readable_works << self
        group.save!
      else
        access_type_error(access_type)
      end
    end

    def add_groups(groups, access_type)
      if access_type == :edit
        groups.each do |g|
          add_editor_group(g)
        end
      elsif access_type == :read
        groups.each do |g|
          add_reader_group(g)
        end
      else
        access_type_error(access_type)
      end
    end

    def remove_group(group, access_type)
      if access_type == :edit
        return unless edit_groups.include?(group.pid)
        editor_groups.delete(group)
        self.edit_groups = edit_groups - [group.pid]
        self.save!
        group.editable_works.delete(self)
        group.save!
      elsif access_type == :read
        return unless read_groups.include?(group.pid)
        set_read_groups([], [group.pid])
        self.save!
        group.readable_works.delete(self)
        group.save!
      else
        access_type_error(access_type)
      end
    end

    def remove_groups(groups, access_type)
      if access_type == :edit
        groups.each do |g|
          remove_editor_group(g)
        end
      elsif access_type == :read
        groups.each do |g|
          remove_reader_group(g)
        end
      else
        access_type_error(access_type)
      end
    end

    def add_user(user, access_type)
      raise ArgumentError, "parameter is #{user.inspect}, expected a kind of User" unless user.is_a?(User)
      if access_type == :edit
        editors << user.person
        self.permissions_attributes = [{ name: user.user_key, access: 'edit', type: 'person' }] unless depositor == user.user_key
      elsif access_type == :read
        readers << user.person
        self.set_read_users([user.user_key], [])
      else
        access_type_error(access_type)
      end
    end

    def add_users(users, access_type)
      if access_type == :edit
        users.each do |u|
          add_editor(u)
        end
      elsif access_type == :read
        users.each do |u|
          add_reader(u)
        end
      else
        access_type_error(access_type)
      end
    end

    def remove_user(user, access_type)
      if access_type == :edit
        remove_candidate_editor(user) if can_remove_editor?(user)
      elsif access_type == :read
        readers.delete(user.person)
        self.set_read_users([], [user.user_key])
        user.person.readable_works.delete(self)
      else
        access_type_error(access_type)
      end
    end

    def remove_users(users, access_type)
      if access_type == :edit
        users.each do |u|
          remove_editor(u)
        end
      elsif access_type == :read
        users.each do |u|
          remove_reader(u)
        end
      else
        access_type_error(access_type)
      end
    end
    
    def access_type_error(access_type)
      raise ArgumentError, "parameter #{access_type} is not a valid access type"
    end

    # Decide if the user can be removed as an editor.  They cannot be removed
    # if they are the depositor or if they are not presently an editor
    # @param user [User] the user to remove
    def can_remove_editor?(user)
      depositor != user.user_key && editors.include?(user.person)
    end

    def clear_associations
      clear_editor_groups
      clear_editors
      clear_reader_groups
      clear_readers
    end

    def clear_editor_groups
      editor_groups.each do |editor_group|
        remove_editor_group(editor_group)
      end
    end

    def clear_editors
      editors.each do |editor|
        remove_candidate_editor(User.find_by_repository_id(editor.pid))
      end
    end

    def clear_reader_groups
      reader_groups.each do |reader_group|
        remove_reader_group(reader_group)
      end
    end

    def clear_readers
      readers.each do |reader|
        remove_reader(User.find_by_repository_id(reader.pid))
      end
    end

    def remove_candidate_editor(user)
      editors.delete(user.person)
      self.edit_users = edit_users - [user.user_key]
      user.person.editable_works.delete(self)
    end
  end
end
