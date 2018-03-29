module Ladle
  class Parser
    require 'ladle/config'
    require 'ladle/fonts'

    def initialize
      @configs = [Config.new]
    end

    def load(path)
      instance_eval(File.read(path.to_s), path.to_s)
      self
    end

    def build
      return @configs.map(&:freeze)
    end

    private

    def name(name)
      @configs.last.name = type(name, String)
    end

    def document(document)
      @configs.last.document = type(document, String)
    end

    def recipient(recipient)
      c = @configs.first.dup
      c.recipient = recipient
      @configs << c
    end

    def file_name(file_name)
      @configs.last.file_name = type(file_name, String)
    end

    def page_size(page_size)
      @configs.last.page_size = enum(page_size, %w{ A4 Legal })
    end

    def page_limit(page_limit)
      @configs.last.page_limit = type(page_limit, Integer)
    end

    def margin(margin)
      @configs.last.margin = type(margin, String)
    end

    def sans_serif(sans_serif)
      @configs.last.sans_serif = enum(sans_serif, Fonts::ALL)
    end

    def font_size(font_size)
      @configs.last.font_size = type(font_size, Numeric)
    end

    def line_height(line_height)
      @configs.last.line_height = type(line_height, Numeric)
    end

    def footer_left(footer_left)
      @configs.last.footer_left = type(footer_left, String)
    end

    def footer_right(footer_right)
      @configs.last.footer_right = type(footer_right, String)
    end

    def hyphenate(*words)
      @configs.last.hyphenations += array(words, String)
    end

    def flag(*flags)
      @configs.last.flags += flags.map(&:to_s)
    end

    private

    def type(value, expected)
      if value.kind_of?(expected)
        return value
      else
        raise ArgumentError,
          "expected %s, got %p" % [expected, value]
      end
    end

    def enum(value, acceptable_values)
      unless acceptable_values.include?(value)
        raise ArgumentError,
          "%p is not one of %p" % [value, acceptable_values]
      end
      return value
    end

    def array(array, type)
      array.flatten.map do |thing|
        type(thing, type)
      end
    end

    require 'ladle/vcs'
    include Ladle::VCS
  end
end
