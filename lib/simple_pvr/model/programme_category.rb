module SimplePvr
  module Model
    class ProgrammeCategory
      include DataMapper::Resource
      storage_names[:default] = 'programme_categories'

      property :id, Serial
      property :language, String, :length => 4
      property :name, String, :length => 255
      
      belongs_to :programme
    end
  end
end