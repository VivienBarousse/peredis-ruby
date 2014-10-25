module Peredis
  module Storage

    autoload :Base, File.expand_path('../storage/base', __FILE__)

    autoload :Memory, File.expand_path('../storage/memory', __FILE__)

    def self.load(config)
      Storage::Memory.new(config)
    end

  end
end
