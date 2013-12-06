module SimplePvr
  module Model
    class ProgrammeDirector
      include DataMapper::Resource
      storage_names[:default] = 'programme_directors'

      property :id, Serial
      property :name, String, :length => 255
      
      belongs_to :programme
    end
  end
end