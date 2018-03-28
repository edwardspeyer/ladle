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

      first_recipient_page_count = nil
      previous_options = {}

      with_tmp do
        for recipient, options in config
          # Log some information about what we're going to build
          Log.log "building #{recipient} version:"
          unless previous_options.empty? or options.empty?
            Log.log('  ...')
          end
          for key, value in options
            if previous_options[key] != value
              case value
              when Array
                words = value.map(&:to_s).join(' ')
                Log.log(format % [key, words])
              else
                Log.log(format % [key, value])
              end
            end
          end
          previous_options = options

          # Build the output file
          output_file = options.delete(:file_name)
          build_one(asciidoc_file, output_file, recipient, options, sans_serif)

          # Check we didn't produce a weird number of pages
          begin
            page_count = PDF::Reader.new(output_file).page_count
            reset = "\033[0m"
            highlight = ""
            if first_recipient_page_count
              if page_count != first_recipient_page_count
                highlight = "\033[031m"
              end
            else
              first_recipient_page_count = page_count
            end
            Log.log('generated %s%d pages%s' % [highlight, page_count, reset])
          end
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

    def build_one(asciidoc_file, output_file, recipient, options, sans_serif)
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
        to_file: output_file,
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
