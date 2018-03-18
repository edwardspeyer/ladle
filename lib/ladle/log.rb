module Ladle
  module Log
    def self.log(message)
      STDERR.puts('ladle: %s' % message)
    end
  end
end
