class AddedToMailer < ActionMailer::Base 
	ACTIONS = []
	def added_to_group(adder, added_user, group_id)

		mail()
	end

	def removed_from_group(remover, removed_user, group_id)
		mail()
	end

	def added_as_delegate(adder, delegate)
		mail()
	end

	def removed_from_delegate(remover, removed_delegate)
		mail()
	end

	def added_as_editor(work_owner, editor, work_id)
		mail()
	end

	def removed_from_editor(work_owner, removed_editor, work_id)
		mail()
	end

	def prepare_body()
	end


end