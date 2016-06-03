module ChangeManager
	module ComparisonConcern
		extend ActiveSupport::Concern

	    def is_group_change?
	      self.change_type == 'added_to_group' || self.change_type == 'removed_from_group'
	    end

	    def is_delegate_change?
	      self.change_type == 'added_as_delegate' || self.change_type == 'removed_as_delegate'
	    end

	    def is_editor_change?
	      self.change_type == 'added_as_editor' || self.change_type == 'removed_as_editor'
	    end
	    
	end
end
