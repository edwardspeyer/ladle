module Ladle
  class Config
    ATTRIBUTES = [
      :name,
      :document,
      :recipient,
      :file_name,
      :page_size,
      :margin,
      :font_size,
      :line_height,
      :footer_left,
      :footer_right,
      :hyphenations,
      :flags
    ]

    for attribute in ATTRIBUTES
      attr_writer attribute
    end

    attr_reader :flags
    attr_reader :hyphenations

    DEFAULT_DOCUMENT_NAME = 'Resume'
    DEFAULT_RECIPIENT = 'generic'
    DEFAULT_PAGE_SIZE = 'A4'
    DEFAULT_MARGIN = '1.01in'
    DEFAULT_FONT_SIZE = 10.01
    DEFAULT_LINE_HEIGHT = 1.203

    def initialize
      @hyphenations = []
      @flags = []
    end

    def name
      @name || nil
    end

    def document
      @document || DEFAULT_DOCUMENT_NAME
    end

    def recipient
      @recipient || DEFAULT_RECIPIENT
    end

    def page_size
      @page_size || DEFAULT_PAGE_SIZE
    end

    def margin
      @margin || DEFAULT_MARGIN
    end

    def font_size
      @font_size || DEFAULT_FONT_SIZE
    end

    def line_height
      @line_height || DEFAULT_LINE_HEIGHT
    end

    def file_name
      @file_name || default_file_name
    end

    def default_file_name
      stem = [name, document].compact.join(' ')
      if recipient == DEFAULT_RECIPIENT
        '%s.pdf' % [stem]
      else
        '%s - %s.pdf' % [stem, recipient]
      end
    end

    def footer_left
      @footer_left || default_footer_left
    end

    def default_footer_left
      page_info = '{page-number} of {page-count}'
      if @name
        "#{@name} -- #{page_info}"
      else
        page_info
      end
    end

    def footer_right
      @footer_right || default_footer_right
    end

    require 'ladle/vcs'
    include Ladle::VCS

    def default_footer_right
      buf = []
      if n = vcs_version
        star = vcs_modified? ? '*' : ''
        buf << "Version #{n}#{star}"
      end
      buf << "(C) #{Time.now.year}"
      buf.join(' ')
    end

    def flags
      list = @flags.dup
      list << default_recipient_flag
      return list.sort.uniq
    end

    def hyphenations
      @hyphenations.sort.uniq
    end

    def default_recipient_flag
      recipient.downcase.gsub(/\s+/, '_')
    end

    def to_h
      result = {}
      for attribute in ATTRIBUTES
        result[attribute.to_s] = self.send(attribute)
      end
      return result
    end
  end
end
