module Ladle
  class Main
    require 'optparse'
    require 'pathname'

    def initialize
      @globals = {
        prepare_fonts: true,
      }
      @config_path = nil
      @opts = OptionParser.new do |opts|
        opts.banner = 'Usage: ladle [options] <asciidoc-file>'

        opts.on('--skip-fonts', 'skip font conversion step') do
          @globals[:prepare_fonts] = false
        end

        opts.on(
          '--config PATH',
          "path to config (default is '<asciidoc-dir>/config')"
        ) do |p|
          @config_path = p
        end

        opts.separator <<~TEXT

          Example:
            * Have a look at the example code in <src>/example/
            * Build it with:

              $ bin/ladle example/cv.adoc --skip-fonts

            * ladle will tell you if you are missing any pre-requisites

        TEXT
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
        config_path =
          if @config_path
            Pathname.new(@config_path)
          else
            asciidoc_file.dirname + 'config'
          end

        unless config_path.exist?
          raise Ladle::Error, "config not found: %s" % config_path
        end

        config.load(config_path)

        require 'ladle/builder'
        Builder.build_all(asciidoc_file, config, @globals)
      end
    end
  end
end
