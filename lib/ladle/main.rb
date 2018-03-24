module Ladle
  class Main
    require 'optparse'
    require 'pathname'

    def initialize
      @globals = {
        prepare_fonts: true,
      }
      @opts = OptionParser.new do |opts|
        opts.on('--skip-fonts', 'skip font conversion step') do
          @globals[:prepare_fonts] = false
        end
      end
    end

    def exec(argv)
      require 'ladle/error'
      require 'ladle/log'
      require 'ladle/paths'
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

        require 'ladle/config'
        config = Config.new
        config_path = asciidoc_file.dirname + 'config'
        config.load(config_path)

        require 'ladle/builder'
        Builder.build_all(asciidoc_file, config, @globals)
      end
    end
  end
end
