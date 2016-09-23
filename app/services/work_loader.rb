# Class for accepting a hash of parameters and creating a new work
#
# Parameters should be identified as in the ATTRIBUTES constant, unless they are special.
# Special parameters are:
#   :work_type - the work type
#   :pid - (optional) include full pid if updating an existing work
#   :files - a nested hash - more on files below
#   :owner - the pid for a user - will be the owner of the file in the system
#   :editors - pids for users
#   :readers - pids for users
#   :editor_groups - pids for groups
#   :reader_groups - pids for groups
#   :collections - the pids for any collection these should belong to
#   :doi - will only mint if set to "TRUE" - identifier must be blank - publisher must be present
#
# :files should be an array of hashes, with the following:
#   :path - the local location of the file
#   :title
#   :visibility
#   :embargo_date
#   :uri - handle in the old system
#
# Repeated fields should be '|' delimited
#
# To use:
=begin

work_attrbutes = {
owner: "sufia:t435hw65w",
files: [{ path: "/Users/vanmiljf/Downloads/chewie.png",
          visibility: "open"
       }],
work_type: "image", title: "'Bacca", description: "This is a wookie",
visibility: "open", rights: "All rights reserved", creator: "Solo, Han"
}

WorkLoader.new(workattributes).create

=end

class WorkLoader
  include ActionDispatch::TestProcess

  ATTRIBUTES = %i{
    abstract advisor alternate_title
    bibliographic_citation college
    contributor committee_member
    coverage_spatial coverage_temporal
    date_created department
    creator cultural_context
    description genre identifier
    inscription issn journal_title
    language location material
    measurement note publisher
    requires rights source subject
    title type visibility
  }

  TEXT_ATTRIBUTES = %i{ 
    bibliographic_citation
    description
    note
  }

  attr_accessor :files, :attributes_for_curation_concern, :owner, :curation_concern, :collection_pids, :file_log, :pid

  def initialize(attribute_hash)
    @files = attribute_hash.delete(:files)
    @pid = attribute_hash.delete(:pid)
    @curation_concern = new_curation_concern(attribute_hash.delete(:work_type))
    @owner = lookup_owner(attribute_hash.delete(:owner))
    @collection_pids = attribute_hash.delete(:collections)
    @attributes_for_curation_concern = attribute_mapper(attribute_hash)
    @file_log = Array.new
  end

  def create
    CurationConcern.actor(self.curation_concern, self.owner, self.attributes_for_curation_concern).create
  end

  def update
    CurationConcern.actor(self.curation_concern, self.owner, self.attributes_for_curation_concern).update
  end

  def add_files
    self.files.each do |f|
      # copied from app/services/curation_concern/generic_work_actor.rb
      generic_file = GenericFile.new
      # mime-type isn't right, but it doesn't matter
      file = fixture_file_upload f[:path], 'image/png'
      generic_file.file = file
      generic_file.batch = self.curation_concern
      Sufia::GenericFile::Actions.create_metadata(
        generic_file, self.owner, self.curation_concern.pid
      )
      # setting some attributes again if they're different for the file
      generic_file.embargo_release_date = curation_concern.embargo_release_date
      generic_file.embargo_release_date = f[:embargo_release_date] unless f[:embargo_release_date].nil?
      generic_file.visibility = curation_concern.visibility
      generic_file.visibility = f[:visibility] unless f[:visibility].nil?

      generic_file.owner = curation_concern.owner
      CurationConcern.attach_file(generic_file, self.owner, file)
      unless f[:title].nil?
        generic_file.title = f[:title] 
        generic_file.save
      end

      self.file_log += [{old_uri: f[:uri], new_uri: Curate.permanent_url_for(generic_file)}]
    end
  end

  def set_collections
    self.collection_pids = [self.collection_pids] unless self.collection_pids.class == Array
    self.collection_pids.each do |collection_pid|
      Collection.find(collection_pid).add_member(curation_concern)
    end
  end

  def work_log
    {
      pid: self.curation_concern.pid,
      identifier: self.curation_concern.identifier,
      owner: self.curation_concern.owner
    }
  end

  def pid_present?
    ! self.pid.nil? 
  end

  private

  def lookup_owner(pid)
    if self.curation_concern.owner.nil?
      Person.find(pid).user
    else
      User.where(email: self.curation_concern.owner).first.person
    end
  end

  def new_curation_concern(type)
    if self.pid_present?
      type.camelize.constantize.send(:find, self.pid)
    else
      case type
      when "article" then Article.new
      when "dataset" then Dataset.new
      when "document" then Document.new
      when "etd" then Etd.new
      when "generic_work" then GenericWork.new
      when "image" then Image.new
      when "student_work" then StudentWork.new
      when "video" then Video.new
      else raise "No valid work type found"
      end
    end
  end

  def attribute_mapper(attribute_hash)
    attributes_for_work = Hash.new
    ATTRIBUTES.each do |attribute_label|
      if self.curation_concern.respond_to? attribute_label
        if TEXT_ATTRIBUTES.include? attribute_label
          if attribute_hash[attribute_label].class == Array 
            attribute_hash[attribute_label] = attribute_hash[attribute_label].join("\n") 
          end
        end
        attributes_for_work[attribute_label.to_s] = attribute_hash[attribute_label] 
      end
    end

    if attribute_hash[:doi] == "TRUE" && attribute_hash[:identifier].nil? && attribute_hash[:publisher].present?
      attributes_for_work["doi_assignment_strategy"] = "mint_doi"
    else
      attributes_for_work["doi_assignment_strategy"] = "not_now"
    end

    {
       "editors_attributes" => editors(attribute_hash[:editors]),
       "editor_groups_attributes" => groups(attribute_hash[:editor_groups]),
       "readers_attributes" => readers(attribute_hash[:readers]),
       "reader_groups_attributes" => groups(attribute_hash[:editor_groups]),
    }.merge(attributes_for_work)
  end

  def editors(pid_array)
    pid_array = Array.new if pid_array.nil?
    pid_array = [pid_array] unless pid_array.class == Array
    pid_array += [self.owner.person.pid]
    hash = Hash.new
    pid_array.each_with_index do |pid, index|
      hash[index.to_s] = {"id"=>pid, "_destroy"=>"", "name"=>""}
    end
    hash
  end

  def readers(pid_array)
    if pid_array.nil?
      {"0"=>{"id"=>"", "_destroy"=>"", "name"=>""}}
    else
      pid_array = [pid_array] unless pid_array.class == Array
      hash = Hash.new
      pid_array.each_with_index do |pid, index|
        hash[index.to_s] = {"id"=>pid, "_destroy"=>"", "name"=>""}
      end
    end
  end

  def groups(pid_array)
    if pid_array.nil?
      {"0"=>{"id"=>"", "_destroy"=>"", "title"=>""}}
    else
      pid_array = [pid_array] unless pid_array.class == Array
      hash = Hash.new
      pid_array.each_with_index do |pid, index|
        hash[index.to_s] = {"id"=>pid, "_destroy"=>"", "title"=>""}
      end
    end
  end
end
