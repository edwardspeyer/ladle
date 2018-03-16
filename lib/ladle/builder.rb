module Ladle
  class Builder
    require 'pathname'
    require 'asciidoctor-pdf'

    def initialize(config)
      @config = config
    end

    def build_all
      unless @config.qualified_asciidoc_source.exist?
        raise Ladle::Error,
          "asciidoc source not found: %s" %
          @config.qualified_asciidoc_source
      end
      for recipient in @config.recipients
        log "building for #{recipient}"
        build_for(recipient)
      end
      log "done"
    end

    private

    def build_for(recipient)
      prerequisites!
      name = @config.display_name
      type = @config.document_type
      Asciidoctor.convert_file(
        @config.qualified_asciidoc_source.to_s,
        safe: :safe,
        backend: :pdf,
        to_file: "#{name} #{type} - #{recipient}.pdf",
        attributes: attributes(recipient),
      )
    end

    def prerequisites!
      Ladle::Ligatures.install_patch!
      Ladle::Hyphenation.install_patch!
      Ladle::Hyphenation.extra_hyphenations = @config.extra_hyphenations
      Ladle::Type.prepare_type_in!(data_directory + 'type')
    end
      
    def attributes(recipient)
      result = {
        'ladle-footer-right'  => @config.footer_right,
        'pdf-style'           => "#{data_directory}/theme.yml",
        'pdf-fontsdir'        => "#{data_directory}/type/",
        'recipient'           => recipient, # TODO doc
      }
      flags = flags_for(recipient)
      log 'flags: %p' % [flags,]
      flags.each{ |f| result[f] = true }
      return result
    end

    def flags_for(recipient)
      @config.class.instance_methods.select do |m|
        m.to_s.start_with?('flag_')
      end.select do |flag|
        begin
          @config.send(flag, recipient)
        rescue ArgumentError => ex
          raise Ladle::Error,
            "config method %p: %s" % [flag, ex.message]
        end
      end.map do |m|
        m.to_s.sub(/^flag_/, '')
      end.sort.map(&:to_s)
    end

    def log(message)
      STDERR.puts '%s %s' % [Time.now, message]
    end

    def data_directory
      Pathname.new(__FILE__).realpath.dirname.dirname.dirname + 'data'
    end
  end
end
