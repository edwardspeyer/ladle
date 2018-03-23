module Ladle
  module Paths
    BASE = Pathname.new(__FILE__).realpath.dirname.dirname.dirname
    DATA = BASE + 'data'
    FONTS = DATA + 'fonts'
  end
end
