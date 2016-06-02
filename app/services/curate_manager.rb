class CurateManager
	extend ChangeManager::Manager
	
	def self.notify(changes)
		grouped_changes = group_changes(changes)
		if grouped_changes['delegates']
			ChangeManager::NotificationMailer.send_email(construct_email(group_changes['delegates']))
		end
		if group_changes['editors']
			ChangeManager::NotificationMailer.send_email(construct_email(group_changes['editors']))
		end

		if group_changes['groups']
			ChangeManager::NotificationMailer.send_email(construct_email(group_changes['groups']))
		end

	end

	def self.group_changes(changes)
		puts 'group_changes method called'
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
		byebug
	end
end