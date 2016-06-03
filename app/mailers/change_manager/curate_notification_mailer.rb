####
# This mailer makes many assumptions as to the content contained in changes. Take care to ensure these assumptions are met
# or create your own mailer that extends ChangeManager::NotificationMailer
####
require 'yaml'

module ChangeManager
	class CurateNotificationMailer < ChangeManager::NotificationMailer
		def notify_changes(changes)
			@changes = changes
			@change_types ||= YAML.load_file(File.join(Rails.root, 'config/change_types.yml'))
			if changes.first.is_group_change?
				mail(
					to: changes.first.target,
					from: 'scholar@uc.edu',
					subject: 'Changes to your Group Membership in Scholar@UC',
				).deliver
			else
				subject = 'Changes to your ' + @change_types[changes.first.change_type]['print'] + ' Status in Scholar@UC.'
				mail(
					to: changes.first.target,
					from: 'scholar@uc.edu',
					subject: subject,
					).deliver
			end
		end
	end
end
