class UsersReport < Report

  private

  def self.report_objects
    User.all
  end

  def self.fields(user = User.new)
    [
      { id:         user.id },
      { pid:        user.person.pid },
      { email:      user.email }, 
      { first_name: user.first_name },
      { last_name:  user.last_name },

      { uid:          user.uid },
      { affiliation:  user.affiliation },
      { ucdepartment: user.ucdepartment },
      { ucstatus:     user.ucstatus },
      { provider:     user.provider },

      { alternate_email:        user.alternate_email },
      { alternate_phone_number: user.alternate_phone_number },
      { blog:                   user.blog },
      { campus_phone_number:    user.campus_phone_number },
      { personal_webpage:       user.personal_webpage},
      { title:                  user.title },

      { delegates: user.can_receive_deposits_from.map(&:email).join("|") },

      { avatar_url: user.person.representative_image_url }
    ]
  end
end
