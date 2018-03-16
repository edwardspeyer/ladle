module Ladle
  class Main
    require 'optparse'

    def initialize
      @opts = OptionParser.new do |opts|
      end
    end

    def exec(argv)
      begin
        _exec(argv)
      rescue Ladle::Error => ex
        @opts.abort(ex.message)
        exit(1)
      end
    end

    def _exec(argv)
      @opts.parse!(argv)
      file = argv.first
      unless file
        @opts.abort('no config file given!')
      end

      for config in Config.load(file)
        Builder.new(config).build_all
      end
    end
  end
end
