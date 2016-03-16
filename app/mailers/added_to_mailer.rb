class AddedToMailer < ActionMailer::Base
	default from: 'scholar@uc.edu'
	def added_to_group(current_user_email, added_user_email, group_id)
		@current_user_email = current_user_email
		@added_user_email = added_user_email
		@group_id = group_id
		mail(
			to: added_user_email,
			subject: 'Added to group #{Group.find_by_id(group_id)} by #{@current_user_email}',
			body: prepare_body()
			)
	end

	def removed_from_group(current_user_email, removed_user_email, group_id)
		@current_user_email = current_user_email
		@removed_user_email = removed_user_email
		@group_id = group_id
		mail()
	end

	def added_as_delegate(current_user_email, delegate_email)
		@current_user_email = current_user_email
		@delegate_email = delegate_email
		mail()
	end

	def removed_from_delegate(current_user_email, removed_delegate_email)
		@current_user_email = current_user_email
		@removed_delegate_email = removed_delegate_email
		mail()
	end

	def added_as_editor(current_user_email, editor_email, work_id)
		@current_user_email = current_user_email
		@editor_email = editor_email
		@work_id = work_id
		mail()
	end

	def removed_from_editor(current_user_email, removed_editor_email, work_id)
		@current_user_email = current_user_email
		@removed_editor_email = removed_editor_email
		mail()
	end

	def prepare_body()
	end

end
