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
      Shy_Hyphen = '&#173;'
      PCDATA = /(?:(&[a-z]+;|<[^>]+>)|([^&<]+))/

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
          Text::Hyphen.new(language: language, left: 2, right: 2)
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
