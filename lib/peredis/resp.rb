module Peredis
  module Resp

    autoload :Parser, File.expand_path('../resp/parser', __FILE__)
    autoload :Serializer, File.expand_path('../resp/serializer', __FILE__)

  end
end
