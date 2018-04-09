module Ladle
  module Hyphenation

    #
    # Hyphenations that Text::Hyphen wouldn't use, but which I quite like.
    #
    @@extra_hyphenations = {}

    module_function

    def extra_hyphenations
      @@extra_hyphenations
    end

    def extra_hyphenations=(list)
      @@extra_hyphenations = list.map do |hyphenated_word|
        parts = hyphenated_word.split('-')
        word = hyphenated_word.tr('-', '')
        [word, parts]
      end.to_h
    end

    def install_patch!
      monkey_patch! unless @installed
      @installed = true
    end

    private
    module_function

    def monkey_patch!
      Asciidoctor::Block.prepend(Extension)
      Asciidoctor::ListItem.prepend(Extension)
      Asciidoctor::Table::Cell.prepend(Extension)
    end

    #
    # The actual hyphenation logic, adapted from:
    #
    #   https://github.com/asciidoctor/asciidoctor-pdf/issues/20
    #
    module Extension
      require 'text/hyphen'
      SOFT_HYPHEN = '&#173;'
      PCDATA = /(?:(&[a-z]+;|<[^>]+>)|([^&<]+))/

      # Wrapper to Text::Hyphen's :left and :right settings.
      MINIMUM_LETTERS = 2

      @@hyphenator =
        begin
          language =
            case ENV['LANG']
            when /^en_GB/ then 'en_uk'
            else 'en_us'
            end
          Ladle::Log.log(
            'hyphenating with Text::Hyphen %p based on locale of %p' %
            [language, ENV['LANG']]
          )
          # When :left/:right are set to 3 I still see some 2-letter
          # hyphenations ("en-crypted"), and when it's set to 2 I simply see
          # more.  2-letter-prefixes in a hyphenation are fine.  Subtracting
          # one works around this bug.
          min = MINIMUM_LETTERS - 1
          Text::Hyphen.new(language: language, left: min, right: min)
        end

      def content
        case @content_model
          when :simple
            super.gsub(PCDATA){ $2 ? (hyphenate $2) : $1 }
          else
            super
        end
      end

      def text
        super.gsub(PCDATA){ $2 ? (hyphenate $2) : $1 }
      end

      private

      def hyphenate(string)
        string.split(/[^[[:word:]]]+/).uniq.inject(string) do |string, word|
          hyphenation =
            if parts = Ladle::Hyphenation.extra_hyphenations[word]
              parts.join(SOFT_HYPHEN)
            else
              @@hyphenator.visualize(word, SOFT_HYPHEN)
            end
          string.gsub(word, hyphenation)
        end
      end
    end
  end
end
