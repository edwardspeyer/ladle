module Ladle
  module Log
    def self.log(message)
      io = STDERR
      sigil =
        if io.tty?
          '🥄  '
        else
          'ladle: '
        end
      io.puts(sigil << message)
    end
  end
end
