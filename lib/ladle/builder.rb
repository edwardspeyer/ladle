module Ladle
  class Builder
    require 'asciidoctor-pdf'
    require 'pathname'
    require 'tmpdir'

    def initialize(config)
      @config = config
    end

    def build_all
      with_tmp do
        unless @config.qualified_asciidoc_source.exist?
          raise Ladle::Error,
            "asciidoc source not found: %s" %
            @config.qualified_asciidoc_source
        end
        for recipient in [@config.recipients].flatten
          Log.log "building for #{recipient}"
          build_for(recipient)
        end
        Log.log "done"
      end
    end

    private

    def with_tmp
      Dir.mktmpdir do |tmp|
        @tmp = Pathname.new(tmp)
        yield
      end
    end

    def build_for(recipient)
      prerequisites!
      @config.recipient = recipient
      Asciidoctor.convert_file(
        @config.qualified_asciidoc_source.to_s,
        safe: :safe,
        backend: :pdf,
        to_file: @config.file_name,
        attributes: attributes(recipient),
      )
    ensure
      @config.recipient = nil
    end

    def prerequisites!
      Ladle::Ligatures.install_patch!
      Ladle::Hyphenation.install_patch!
      Ladle::Hyphenation.extra_hyphenations = @config.extra_hyphenations
      Ladle::Type.prepare_type_in!(data_directory + 'type')
    end

    def attributes(recipient)
      result = {
        'pdf-style'           => build_theme_file,
        'pdf-fontsdir'        => "#{data_directory}/type/",
      }
      flags = flags_for(recipient)
      Log.log 'flags: %s' % flags.map{ |f| "+#{f}" }.join(' ')
      flags.each{ |f| result[f] = true }
      return result
    end

    def build_theme_file
      mutate_theme_file do |data|
        # Some things have to be set directly in the YAML, because they
        # directly control asciidoctor-pdf (e.g. margins) as opposed to being
        # passed through to the Asciidoctor text engine (e.g. the footer.)

        # Set the margins:
        data['page']['ladle_margin'] =
          '%.2fin' % @config.margin_inches

        # Set the footer text:
        data['footer']['recto']['left']['content'] = @config.footer_left
        data['footer']['recto']['right']['content'] = @config.footer_right
      end
    end

    def mutate_theme_file
      original = "#{data_directory}/theme.yml"
      data = YAML.load_file(original)
      yield data
      tmp = @tmp + 'theme.yml'
      tmp.open('w'){ |io| io.print(data.to_yaml) }
      return tmp.to_s
    end

    def flags_for(recipient)
      flags = []
      # A special recipient flag:
      flags << recipient.to_s.downcase.gsub(/\s+/, '_')
      # Any flags from flag_* methods:
      methods = @config.class.instance_methods.select do |m|
        m.to_s.start_with?('flag_')
      end
      for flag_method in methods.sort
        begin
          if @config.send(flag_method, recipient)
            flags << flag_method.to_s
          end
        rescue ArgumentError => ex
          raise Ladle::Error,
            "config method %p: %s" % [flag, ex.message]
        end
      end
      return flags
    end

    def data_directory
      Pathname.new(__FILE__).realpath.dirname.dirname.dirname + 'data'
    end
  end
end
