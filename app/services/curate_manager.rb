#######
# This manager extends the default Manager within ChangeManager in order to meet content requirements. 
# It makes big assumptions as to the content of the hashes it deals with. Take care!
#######
class CurateManager
	extend ChangeManager::Manager
	
	def self.notify_target_of(changes)
		grouped_changes = group_changes(changes)
		if grouped_changes['delegates']
			if ChangeManager::CurateNotificationMailer.notify_changes(grouped_changes['delegates'])
				grouped_changes['delegates'].each { |change| change.notify }
			end
		end

		if grouped_changes['editors']
			if ChangeManager::CurateNotificationMailer.notify_changes(grouped_changes['editors'])
				grouped_changes['editors'].each { |change| change.notify }
			end
		end

		if grouped_changes['groups']
			if ChangeManager::CurateNotificationMailer.notify_changes(grouped_changes['groups'])
				grouped_changes['groups'].each { |change| change.notify }
			end
		end

	end

	def self.group_changes(changes)
		delegate_changes = Array.new
		editor_changes = Array.new
		group_changes = Array.new
		changes.each do |change|
			
			if change.is_delegate_change?
				delegate_changes << change
			elsif change.is_editor_change?
				editor_changes << change
			elsif change.is_group_change?
				group_changes << change
			end 
		end
		grouped_changes = Hash.new
		grouped_changes['delegates'] = delegate_changes if !delegate_changes.empty?
		grouped_changes['editors'] = editor_changes if !editor_changes.empty?
		grouped_changes['groups'] = group_changes if !group_changes.empty?
		grouped_changes
	end
end
