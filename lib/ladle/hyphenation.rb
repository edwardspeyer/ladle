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

    def extra_hyphenations=(map)
      for word, parts in map
        unless parts.join == word
          raise Ladle::Error,
            "hyphenation: %p != %p" % [parts, word]
        end
      end
      @@extra_hyphenations = map
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
      Shy_Hyphen = '&#173;'
      PCDATA = /(?:(&[a-z]+;|<[^>]+>)|([^&<]+))/

      # TODO look at $LANG?
      @@hyphenator = Text::Hyphen.new(language: 'en_uk', left: 2, right: 2)

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
              parts.join(Shy_Hyphen)
            else
              @@hyphenator.visualize(word, Shy_Hyphen)
            end
          string.gsub(word, hyphenation)
        end
      end
    end
  end
end
