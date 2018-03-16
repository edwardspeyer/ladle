module Ladle
  module Ligatures
    # letters => codepoint
    Map = {
      ffi: 0xFB03,
      ffl: 0xFB04,
      ff:  0xFB00,
      fi:  0xFB01,
      fl:  0xFB02,
    }
    
    require 'asciidoctor'

    module_function

    def install_patch!
      unless @installed
        patch_replacements_array!
        patch_regex!
      end
      @installed = true
    end

    def patch_replacements_array!
      Ligatures::Map.each do |letters, codepoint|
        entity = '&#%d;' % codepoint
        regex = /#{letters}/
        # The third parameter concerns what to do with captures in the regex.
        # The :none option is because we don't use captures in our regex.
        Asciidoctor::REPLACEMENTS << [regex, entity, :none]
      end
    end

    def patch_regex!
      without_verbosity do
        const = :ReplaceableTextRx
        original = Asciidoctor.const_get(const)
        ours = '(?:%s)' % Map.keys.join('|')
        replacement = /#{original}|#{ours}/
        Asciidoctor.const_set(const, replacement)
      end
    end

    def without_verbosity
      old_verbosity = $VERBOSE
      begin
        $VERBOSE = nil
        yield
      ensure
        $VERBOSE = old_verbosity
      end
    end
  end
end
