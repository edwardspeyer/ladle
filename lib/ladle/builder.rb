module Ladle
  module Builder
    require 'pathname'
    require 'tmpdir'

    module_function

    def build_all(asciidoc_file, config)
      with_tmp do
        config.each_recipient do |recipient, options|
          Log.log "building #{recipient} version"
          build_one(asciidoc_file, recipient, options)
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

    def build_one(asciidoc_file, recipient, options)
      prerequisites!(options)
      attributes = {
        'name'          => options[:name],
        'pdf-style'     => build_theme_file(options),
        'pdf-fontsdir'  => "#{data_directory}/fonts/",
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

    def prerequisites!(options)
      require 'asciidoctor-pdf'
      Ladle::Ligatures.install_patch!
      Ladle::Hyphenation.install_patch!
      Ladle::Hyphenation.extra_hyphenations = options[:hyphenations]
      Ladle::Fonts.prepare_fonts_in!(data_directory + 'fonts')
    end

    def build_theme_file(options)
      original = (data_directory + 'theme.yml').read
      options_with_string_keys = options.map{ |k,v| [k.to_s, v] }.to_h
      addenda = {'ladle' => options_with_string_keys}.to_yaml
      theme = addenda + "\n" + original + "\n"
      theme_file = @tmp + 'theme.yml'
      theme_file.open('w'){ |io| io.print(theme) }
      return theme_file.to_s
    end

    def data_directory
      Pathname.new(__FILE__).realpath.dirname.dirname.dirname + 'data'
    end
  end
end
