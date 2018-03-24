module Ladle
  class Config
    GENERIC = 'generic'

    KEYS_SINGULAR = [
      :name,
      :document,
      :margin,
      :footer_left,
      :footer_right,
    ]

    KEYS_PLURAL = [
      :hyphenate,
      :flag,
    ]

    DEFAULT_MARGIN = '1.08in'

    DEFAULT_DOCUMENT_NAME = 'Resume'

    def initialize
      @recipients = {}
      recipient(GENERIC)
    end

    def recipient(recipient)
      @options = {}
      @recipients[recipient.to_s] = @options
    end

    def load(path)
      code = path.read
      begin
        instance_eval(code, path.to_s)
      rescue Ladle::Error => ex
        loc = ex.backtrace_locations[1]
        raise Ladle::Error,
          '%s: line %d: %s' % [loc.path, loc.lineno, ex.message]
      end
    end

    def method_missing(key, *args)
      if KEYS_SINGULAR.include?(key)
        if args.size == 1
          set(key, args.first.to_s)
        else
          raise Ladle::Error, "expected 1 argument, got %p" % args
        end
      elsif KEYS_PLURAL.include?(key)
        append(key, args.map(&:to_s))
      else
        raise Ladle::Error, "unrecognized key %s" % key
      end
    end

    def set(key, value)
      @options[key] = value
    end

    def append(key, values)
      @options[key] ||= []
      @options[key] += values
    end

    def each_recipient
      generic_options = @recipients[GENERIC]
      for recipient, options in @recipients
        options[:recipient] = recipient
        options = add_defaults(generic_options.merge(options))
        options[:flag] << recipient.downcase.gsub(/\s+/, '_')
        yield recipient, options
      end
    end

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

      options[:flag] ||= []

      options[:hyphenate] ||= []

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
