module Ladle
  class Config
    GENERIC = 'generic'

    def initialize
      @recipients = {}
      recipient(GENERIC)
    end

    def recipient(recipient)
      check_type(:recipient, recipient, String)
      @options = {}
      @recipients[recipient] = @options
    end

    def load(path)
      code = path.read
      instance_eval(code, path.to_s)
    # TODO use method_missing with a whitelist, instead of #name, #document
    rescue NoMethodError => ex
      loc = ex.backtrace_locations.first
      pre = ex.message.split(' for ').first
      raise Error, '%s:%d:%s' % [loc.path, loc.lineno, pre]
    end

    def name(name)
      set(:name, name, String)
    end

    def document(document)
      set(:document, document, String)
    end

    def margin(margin)
      set(:margin, margin, String)
    end

    def footer_left(content)
      set(:footer_left, content, String)
    end

    def footer_right(content)
      set(:footer_right, content, String)
    end

    def hyphenate(*words)
      append(:hyphenations, words, String)
    end

    def flag(name)
      append(:flags, [name.to_s], String)
    end

    def set(key, value, type)
      check_type(key, value, type)
      @options[key] = value
    end

    def append(key, values, type)
      for value in values
        check_type(key, value, type)
      end
      @options[key] ||= []
      @options[key] += values
    end

    def check_type(key, value, type)
      unless value.kind_of?(type)
        raise Error, '%p: expected type %p, not %p' % [key, type, value]
      end
    end

    def each_recipient
      generic_options = @recipients[GENERIC]
      for recipient, options in @recipients
        options[:recipient] = recipient
        options = add_defaults(generic_options.merge(options))
        options[:flags] << recipient.downcase.gsub(/\s+/, '_')
        yield recipient, options
      end
    end

    DEFAULT_MARGIN = '1.08in'

    DEFAULT_DOCUMENT_NAME = 'Resume'

    def add_defaults(options)
      options[:name] ||= nil

      options[:document] ||= DEFAULT_DOCUMENT_NAME

      options[:margin] ||= DEFAULT_MARGIN

      options[:file_name] ||=
        begin
          stem = [:name, :document].map{ |k| options[k] }.compact.join(' ')
          if options[:recipient] == GENERIC
            '%s.pdf' % [stem]
          else
            '%s - %s.pdf' % [stem, options[:recipient]]
          end
        end

      options[:footer_left] ||=
        begin
          page_info = '{page-number} of {page-count}'
          if name = options[:name]
            "#{name} -- #{page_info}"
          else
            page_info
          end
        end

      options[:footer_right] ||=
        begin
          buf = []
          if n = vcs_version
            star = vcs_modified? ? '*' : ''
            buf << "Version #{n}#{star}"
          end
          buf << "(C) #{Time.now.year}"
          buf.join(' ')
        end

      options[:flags] ||= []

      options[:hyphenations] ||= []

      return options
    end

    def vcs_version
      `git log --oneline | wc -l`.strip.to_i
    end

    def vcs_modified?
      not `git status --porcelain`.strip.empty?
    end
  end
end
