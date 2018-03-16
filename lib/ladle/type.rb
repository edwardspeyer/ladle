module Ladle
  module Type
    Map = {
      '/Library/Fonts/GillSans.ttc' => [
        'Gill Sans Bold Italic.ttf',
        'Gill Sans Bold.ttf',
        'Gill Sans Italic.ttf',
        'Gill Sans.ttf',
      ]
    }

    FontForge_Script = <<~PYTHON
      file = argv[1]
      for font in fontforge.fontsInFile(file):
        f = fontforge.open(u'%s(%s)' % (file, font))
        f.generate('%s.ttf' % font)
    PYTHON

    module_function

    def prepare_type_in!(directory)
      Dir.chdir(directory) do
        Map.each do |system_font, local_fonts|
          next if exist?(local_fonts)
          unless File.exist?(system_font)
            raise Ladle::Error,
              "unable to convert system font, file not found: %p" %
              system_font
          end
          command = ['fontforge', '-c', FontForge_Script, system_font]
          system *command
          unless exist?(local_fonts)
            raise Ladle::Error,
              "we ran %p but didn't get expected files: %p" %
              [command, local_fonts]
          end
        end
      end
    end

    def exist?(files)
      files.inject(true) do |bool, path|
        bool && File.exist?(path)
      end
    end
  end
end
