module Ladle
  module Builder
    require 'ladle/term'
    require 'pathname'
    require 'tmpdir'

    module_function

    def build_all(asciidoc_file, configs, globals)
      prerequisites!(globals)

      all_keys = configs.map(&:to_h).map(&:keys).inject(&:+)
      max_key_width = all_keys.map(&:to_s).map(&:size).sort.last
      format = "  %-#{max_key_width}s : %s"

      first_recipient_page_count = nil
      previous_config_hash = {}

      with_tmp do
        for config in configs
          # Log some information about what we're going to build
          Log.log "building #{config.recipient} version:"
          unless previous_config_hash.empty?
            Log.log('  ...')
          end
          for key, value in config.to_h
            if previous_config_hash[key] != value
              case value
              when Array
                words = value.map(&:to_s).join(' ')
                Log.log(format % [key, words])
              else
                Log.log(format % [key, value])
              end
            end
          end
          previous_config_hash = config.to_h

          # Build the PDF
          build_one(asciidoc_file, config)

          # Check the PDF
          page_count = PDF::Reader.new(config.file_name).page_count
          first_recipient_page_count ||= page_count
          check_page_count(page_count, first_recipient_page_count)
          check_line_lengths(config.file_name)
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

    def build_one(asciidoc_file, config)
      Ladle::Hyphenation.extra_hyphenations = config.hyphenations
      attributes = {
        'name'          => config.name,
        'pdf-style'     => build_theme_file(config),
        'pdf-fontsdir'  => "#{Paths::DATA}/fonts/",
      }
      for flag in config.flags
        attributes[flag] = flag
      end
      Asciidoctor.convert_file(
        asciidoc_file.realpath.to_s,
        safe: :safe,
        backend: :pdf,
        to_file: config.file_name,
        attributes: attributes,
      )
    end

    def build_theme_file(config)
      original = (Paths::DATA + 'theme.yml').read
      addenda = {'ladle' => config.to_h}.to_yaml
      theme = addenda + "\n" + original + "\n"
      theme_file = @tmp + 'theme.yml'
      theme_file.open('w'){ |io| io.print(theme) }
      return theme_file.to_s
    end

    def check_page_count(actual_page_count, expected_page_count)
      highlight =
        if actual_page_count != expected_page_count
          Term::HIGHLIGHT
        end
      Log.log(
        '  generated %s%d pages%s' %
        [highlight, actual_page_count, Term::RESET]
      )
    end

    def check_line_lengths(file_name)
      output, status = Open3.capture2e('pdf_text', file_name.to_s)
      lengths = output.lines.map do |line|
        line = line.sub(/^\s+•\s+/, '').strip.sub(/\W/, '').size
      end.reject do |length|
        length == 0
      end

      median_length = lengths.sort[lengths.size / 2]
      highlight =
        if median_length > 90
          Term::HIGHLIGHT
        end

      Log.log(
        '  median line-length of %s%d chars%s' %
        [highlight, median_length, Term::RESET]
      )
    rescue Errno::ENOENT
      unless @reported_skipping_line_lengths
        Log.log('skipping line-length, pdf_text(1) not found')
        @reported_skipping_line_lengths = true
      end
    end
  end
end
