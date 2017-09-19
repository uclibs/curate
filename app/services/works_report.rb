class WorksReport < Report

  private

  def self.report_objects
    works = Array.new
    work_type_classes.each do |type_class|
      type_class.all.each { |work| works << work }
    end
    works
  end

  def self.fields(work = GenericWork.new)
    [
      { work_type: work.class.to_s.underscore },
      { pid: work.pid },
      { submitter_email: work.owner },
      { proxy_depositor: proxy_deposit_test(work) },
      { editor_emails: gather_all_editors(work) },
      { reader_emails: gather_all_readers(work) },
      { related_works: work.related_work_ids.join("|") },
      { collections: work.collections.map(&:pid).join("|") },
      { representative: work.representative },
      { files: work.generic_files.map(&:pid).join("|") }
    ] + attributes(work)
  end

  def self.proxy_deposit_test(work)
    work.depositor == work.owner ? nil : work.depositor
  end

  def self.gather_all_editors(work)
    (work.edit_groups.map do |group_id|
      Hydramata::Group.find(group_id).members.map { |m| m.email }
    end << work.edit_users).flatten.uniq
  end

  def self.gather_all_readers(work)
    ((work.read_groups - ["public", "registered"]).map do |group_id|
      Hydramata::Group.find(group_id).members.map { |m| m.email }
    end << work.read_users).flatten.uniq
  end

  def self.attributes(work)
    all_attributes_list.map do |attribute|
      if work.class.method_defined? attribute
        { attribute => work.send(attribute) }
      else
        { attribute => nil }
      end
    end
  end

  def self.all_attributes_list
    %i[
      abstract
      advisor
      alternate_title
      bibliographic_citation
      college
      contributor
      committee_member
      coverage_spatial
      coverage_temporal
      date_modified
      date_uploaded
      degree
      department
      date_created
      creator
      cultural_context
      description
      embargo_release_date
      existing_identifier
      genre
      identifier
      identifier_url
      inscription
      issn
      journal_title
      language
      location
      material
      measurement
      note
      publisher
      requires
      rights
      source
      subject
      title
      type
      visibility
    ]
  end

  def self.work_type_classes
    Curate.configuration.registered_curation_concern_types.collect { |type| type.constantize }
  end
end
