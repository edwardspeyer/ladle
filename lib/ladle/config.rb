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
      args = args.flatten
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

    def each
      generic_options = @recipients[GENERIC]
      for recipient, options in @recipients
        # This iterator is where we add in defaults, at the last minute, so
        # take a "deep" copy (we'll assume that no value is itself a compound
        # datastructure.)
        copy = generic_options.merge(options).map{ |k, v| [k, v.dup] }.to_h
        copy[:recipient] = recipient
        copy = set_defaults(copy)
        copy[:flag] << recipient.downcase.gsub(/\s+/, '_')
        yield recipient, copy
      end
    end

    include Enumerable

    # Normalize the options hash by copying its keys into a new hash.
    # A side-effect of doing this is that it enforces a normal order on the
    # result hash
    def set_defaults(options)
      result = {}

      result[:name] = options[:name] || nil

      result[:document] = options[:document] || DEFAULT_DOCUMENT_NAME

      result[:recipient] = options[:recipient]

      result[:margin] = options[:margin] || DEFAULT_MARGIN

      result[:file_name] = options[:file_name] ||
        begin
          stem = [:name, :document].map{ |k| options[k] }.compact.join(' ')
          if options[:recipient] == GENERIC
            '%s.pdf' % [stem]
          else
            '%s - %s.pdf' % [stem, options[:recipient]]
          end
        end

      result[:footer_left] = options[:footer_left] ||
        begin
          page_info = '{page-number} of {page-count}'
          if name = options[:name]
            "#{name} -- #{page_info}"
          else
            page_info
          end
        end

      result[:footer_right] = options[:footer_right] ||
        begin
          buf = []
          if n = vcs_version
            star = vcs_modified? ? '*' : ''
            buf << "Version #{n}#{star}"
          end
          buf << "(C) #{Time.now.year}"
          buf.join(' ')
        end

      result[:flag] = options[:flag] || []

      result[:hyphenate] = options[:hyphenate] || []

      return result
    end

    def vcs_version
      `git log --oneline | wc -l`.strip.to_i
    end

    def vcs_modified?
      not `git status --porcelain`.strip.empty?
    end
  end
end
