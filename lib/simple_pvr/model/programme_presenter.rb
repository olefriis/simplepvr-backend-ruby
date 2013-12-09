module SimplePvr
  module Model
    class ProgrammePresenter
      include DataMapper::Resource
      storage_names[:default] = 'programme_presenters'

      property :id, Serial
      property :name, String, :length => 255
      
      belongs_to :programme
    end
  end
end