module Ladle
  module Builder
    require 'pathname'
    require 'tmpdir'

    module_function

    def build_all(asciidoc_file, config)
      require 'asciidoctor-pdf'
      Ladle::Ligatures.install_patch!
      Ladle::Hyphenation.install_patch!
      Ladle::Fonts.prepare_fonts!
      sans_serif = Fonts.sans_serif
      Log.log("using #{sans_serif} for sans-serif")
      with_tmp do
        config.each_recipient do |recipient, options|
          Log.log "building #{recipient} version"
          build_one(asciidoc_file, recipient, options, sans_serif)
        end
        Log.log "done"
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
