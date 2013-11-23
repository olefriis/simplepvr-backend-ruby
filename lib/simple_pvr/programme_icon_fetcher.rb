require 'open-uri'

module SimplePvr
  class ProgrammeIconFetcher
    def self.fetch(url, destination_file)
      Thread.new do
        File.open(destination_file, "wb") do |saved_file|
          open(url, 'rb') do |read_file|
            saved_file.write(read_file.read)
          end
        end
      end
    end
  end
end