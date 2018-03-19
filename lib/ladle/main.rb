module Ladle
  class Main
    require 'optparse'
    require 'pathname'

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
      if argv.empty?
        raise Error, 'no asciidoc-file(s) given'
      end

      for arg in argv
        asciidoc_file = Pathname.new(arg)
        unless asciidoc_file.exist?
          raise Error, 'asciidoc-file not found: %s' % asciidoc_file
        end

        config = Config.new
        config_path = asciidoc_file.dirname + 'config'
        config.load(config_path)

        Builder.build_all(asciidoc_file, config)
      end
    end
  end
end
