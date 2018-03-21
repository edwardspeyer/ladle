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

    def prepare_fonts_in!(directory)
      Dir.chdir(directory) do
        prepare_font 'Gill Sans',
          '/Library/Fonts/GillSans.ttc',
          'Gill Sans Bold Italic.ttf',
          'Gill Sans Bold.ttf',
          'Gill Sans Italic.ttf',
          'Gill Sans.ttf'
      end
    end

    def prepare_font(name, system_font, *local_fonts)
      unless exist? system_font
        raise Ladle::Error,
          "unable to convert system font, file not found: %p" %
          system_font
      end
      Dir.mkdir(name) unless Dir.exist?(name)
      Dir.chdir(name) do
        return if exist? local_fonts
        command = ['fontforge', '-c', FontForge_Script, system_font]
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
