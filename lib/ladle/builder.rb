module Ladle
  module Builder
    require 'pathname'
    require 'tmpdir'

    module_function

    def build_all(asciidoc_file, config, globals)
      prerequisites!(globals)
      sans_serif = Fonts.sans_serif
      Log.log("using #{sans_serif} for sans-serif")

      max_key_width = config.
        map{ |_,o| o }.
        inject(&:merge).
        keys.map(&:length).sort.last
      format = "  %-#{max_key_width}s : %s"
      previous_options = {}

      with_tmp do
        for recipient, options in config
          Log.log "building #{recipient} version:"
          unless previous_options.empty? or options.empty?
            Log.log('  ...')
          end
          for key, value in options
            if previous_options[key] != value
              Log.log(format % [key, value])
            end
          end
          build_one(asciidoc_file, recipient, options, sans_serif)
          previous_options = options
        end
        Log.log "done"
      end
    end

    def prerequisites!(globals)
      begin
        require 'asciidoctor-pdf'
        require 'text-hyphen'
      rescue LoadError
        raise Ladle::Error, <<~TEXT
          missing required gems:

            * asciidoctor-pdf
            * text-hyphen

          Install them with your package manager, or with:

            gem install --user-install --pre --no-ri --no-rdoc \\
              asciidoctor-pdf text-hyphen

        TEXT
      end
      require 'ladle/ligatures'
      Ladle::Ligatures.install_patch!
      require 'ladle/hyphenation'
      Ladle::Hyphenation.install_patch!

      require 'ladle/fonts'
      if globals[:prepare_fonts]
        Ladle::Fonts.prepare_fonts!
      end
    end

    def with_tmp
      Dir.mktmpdir do |tmp|
        @tmp = Pathname.new(tmp)
        yield
      end
    end

    def build_one(asciidoc_file, recipient, options, sans_serif)
      Ladle::Hyphenation.extra_hyphenations = options[:hyphenations]
      attributes = {
        'name'          => options[:name],
        'pdf-style'     => build_theme_file(options, sans_serif),
        'pdf-fontsdir'  => "#{Paths::DATA}/fonts/",
      }
      for flag in options[:flags]
        attributes[flag] = flag
      end
      Asciidoctor.convert_file(
        asciidoc_file.realpath.to_s,
        safe: :safe,
        backend: :pdf,
        to_file: options[:file_name],
        attributes: attributes,
      )
    end

    def build_theme_file(options, sans_serif)
      original = (Paths::DATA + 'theme.yml').read
      options = options.map{ |k,v| [k.to_s, v] }.to_h
      # Figure out the sans-serif font
      options['sans_serif'] = sans_serif
      addenda = {'ladle' => options}.to_yaml
      theme = addenda + "\n" + original + "\n"
      theme_file = @tmp + 'theme.yml'
      theme_file.open('w'){ |io| io.print(theme) }
      return theme_file.to_s
    end
  end
end
