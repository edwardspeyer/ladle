module Ladle
  class Config
    require 'pathname'
    require 'set'

    def initialize(path)
      @path = Pathname.new(path.to_s).realpath
    end

    def asciidoc_source
      basename = @path.basename.to_s.sub(/.rb$/, '.adoc')
      @path.dirname + basename
    end

    def qualified_asciidoc_source
      @path.dirname + asciidoc_source.to_s
    end

    def footer_right
      "Version #{version} (C) #{display_name} #{Time.now.year}"
    end

    def version
      star = git_modified? ? '*' : ''
      number = git_version + version_start
      '%d%s' % [number, star]
    end
    
    def version_start
      1
    end

    def git_version
      `git log --oneline | wc -l`.strip.to_i
    end

    def git_modified?
      not `git status --porcelain`.strip.empty?
    end
    

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

    # :nodoc:
    @@set = Set.new

    # :nodoc:
    def self.inherited(subclass)
      @@set.add(subclass)
    end
  end
end
