module Ladle
  #
  # Create a subclass of Ladle::Config to customize ladle's behavior.
  #
  class Config

    # Your name as it should appear in:
    # * the output file name: <tt>Dale Winton CV - Central Television.pdf</tt>
    # * the document footer: <tt>(C) Dale Winton 2018</tt>
    def display_name
      nil
    end

    # The name for this type of document as it should appear in the output
    # filename.  Usually either "CV" or "Résumé"
    def display_doctype
      'Résumé'
    end

    # Replace this method for custom output, otherwise the default is pretty
    # sensible, using #display_name, #display_doctype and the current
    # recipient from #recipients:
    #
    # * <tt>Dale Winton CV.pdf</tt>
    # * <tt>Dale Winton CV - Central Television.pdf</tt>
    # * <tt>Dale Winton CV - Talkback Thames.pdf</tt>
    #
    def file_name
      prefix = [display_name, display_doctype].compact.join(' ')
      case recipient
      when :anyone
        "#{prefix}.pdf"
      else
        "#{prefix} - #{recipient}.pdf"
      end
    end

    # The list of recipients for your document.  The default is
    # <tt>[:anyone]</tt>, meaning you aren't going to make any tweaks based on
    # who is receiving your CV / Résumé.
    #
    # If you do want to make small changes based on recipient, the recipient
    # name used here will show up as an AsciiDoctor attribute, lower-cased,
    # with underscores.  Example:
    #
    #   # dale.rb
    #   class Config < Ladle::Config
    #     def recipients
    #       [:anyone, 'Central Television', 'Talkback Thames']
    #     end
    #   end
    #
    # ...which uses AsciiDoctor's +ifdef+ macros as follows:
    #
    #   # dale.adoc
    #   === About Me ===
    #   * I am available to work anywhere in the UK.
    #   ifdef::central_television[]
    #   * I especially love the rich culture and history of _The Midlands_.
    #   endif::[]
    #
    def recipients
      [:anyone]
    end

    #
    # If the config is in x.rb, the AsciiDoc source is assumed to be in
    # x.adoc.
    #
    # Implement asciidoc_source if that assumption is wrong.
    #
    def asciidoc_source
      basename = @path.basename.to_s.sub(/.rb$/, '.adoc')
      @path.dirname + basename
    end

    #
    # The left side of the footer.  The default is:
    # * If you've given a #display_name, that appears followed by an em-dash.
    # * Then a page count is given, using AsciiDoctor's own "{foo}" variable
    #   interpolation.
    #
    # For example: <em>"Dale Winton -- 1 of 7"</em>
    #
    def footer_left
      if display_name
        "#{display_name} -- {page-number} of {page-count}"
      else
        '{page-number} of {page-count}'
      end
    end

    # The right side of the footer.  The default is a version string and a
    # copyright string: <em>"Version 12* © 2018"</em>
    def footer_right
      [footer_version, footer_copyright].compact.join(' ')
    end

    # Customizable copyright notice, default is <em>"© <year>"</em>
    def footer_copyright
      "(C) #{Time.now.year}"
    end

    # Customizable document version, default is <em>"Version <n>"</em> where
    # +n+ is the output of #footer_version_number.
    def footer_version
      "Version #{footer_version_number}"
    end

    # Customizable version number, default is the #vcs_version with an extra
    # <tt>*</tt> appended if there were local modifications.
    def footer_version_number
      star = vcs_modified? ? '*' : ''
      number = vcs_version
      '%d%s' % [number, star]
    end

    # Used in the #footer_version_number code, default is to assume a git repo,
    # and to count the number of commits on this branch since the very first
    # commit.
    #
    # You can obscure how many commits you've made by doing something like
    # this:
    #
    #   def vcs_version
    #     super + 12345
    #   end
    #
    def vcs_version
      `git log --oneline | wc -l`.strip.to_i
    end

    # Useful if you want to write your own #footer_version_number, this method
    # assumes you are in a git repository.
    def vcs_modified?
      not `git status --porcelain`.strip.empty?
    end

    #
    # A float, ideally about an inch or maybe even more.  Too little margin and
    # your lines of text are hard to read.  The default is 1.08".
    #
    def margin_inches
      1.08
    end

    #
    # A list of words with hyphenation points, including words that should
    # never be hyphenated:
    #
    #   def extra_hyphenations
    #     %w{ in-tra-net su-per-mar-ket Supermarket Sweep }
    #   end
    #
    # LᴀDʟE uses Text::Hyphen to automatically add hyphens, but it isn't
    # perfect, and you'll want to use extra_hyphenations if you have strange
    # looking lines with long unbroken words that are too spaced out.
    #
    def extra_hyphenations
      []
    end


    #--
    # The rest of this file is implementation stuff to make Config work with
    # the rest of LᴀDʟE.
    #++

    require 'pathname'
    require 'set'

    # :nodoc:
    def self.load(file)
      before = @@set.dup
      Kernel.load(file)
      configs = @@set - before
      if configs.empty?
        raise Ladle::Error,
          "no configs found %p: did you subclass %p?" %
          [file, self]
      end
      return configs.map do |cls|
        cls.new(file)
      end
    end

    @@set = Set.new

    # :nodoc:
    def self.inherited(subclass)
      @@set.add(subclass)
    end

    # :nodoc:
    def initialize(path)
      @path = Pathname.new(path.to_s).realpath
      @recipient = nil
    end

    # :nodoc:
    attr_accessor :recipient

    # :nodoc:
    def qualified_asciidoc_source
      @path.dirname + asciidoc_source.to_s
    end
  end
end
