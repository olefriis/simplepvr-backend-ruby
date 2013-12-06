module SimplePvr
  module Model
    class ProgrammeActor
      include DataMapper::Resource
      storage_names[:default] = 'programme_actors'

      property :id, Serial
      property :role_name, String, :length => 255
      property :actor_name, String, :length => 255
      
      belongs_to :programme
    end
  end
end