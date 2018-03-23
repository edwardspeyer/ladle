module Ladle
  module Fonts
    require 'open3'

    FontForge_Script = <<~PYTHON
      file = argv[1]
      for font in fontforge.fontsInFile(file):
        f = fontforge.open(u'%s(%s)' % (file, font))
        f.generate('%s.ttf' % font)
    PYTHON

    module_function

    GILL_SANS = 'Gill Sans'
    LATO_BLACK = 'Lato Black'

    def prepare_fonts!
      prepare_font GILL_SANS,
        '/Library/Fonts/GillSans.ttc',
        'Gill Sans Bold Italic.ttf',
        'Gill Sans Bold.ttf',
        'Gill Sans Italic.ttf',
        'Gill Sans.ttf'
    end

    def sans_serif
      glob = '%s/%s/*.ttf' % [Paths::FONTS, GILL_SANS]
      if Dir.glob(glob).empty?
        LATO_BLACK
      else
        GILL_SANS
      end
    end

    def prepare_font(name, system_font, *local_fonts)
      return unless exist? system_font
      font_directory = Paths::FONTS + name
      Dir.mkdir(font_directory) unless Dir.exist?(font_directory)
      Dir.chdir(font_directory) do
        return if exist? local_fonts
        command = ['fontforge', '-c', FontForge_Script, system_font]
        Log.log('executing fontforge to build %s' % name)
        output, status = Open3.capture2e(*command)
        unless status.success?
          raise Ladle::Error,
            "fontforge error while running %p:\n----\n%s\n----" %
            [command, output]
        end
        unless exist? local_fonts
          raise Ladle::Error,
            "we ran %p but didn't get expected files: %p" %
            [command, local_fonts]
        end
      end
    end

    def exist?(*files)
      files.flatten.inject(true) do |bool, path|
        bool && File.exist?(path)
      end
    end
  end
end
