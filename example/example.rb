# An example LᴀDʟE config file:
class Config < Ladle::Config

  # Used in (1) PDF file names; (2) the footer copyright notice.
  def display_name
    'Hazel Folder'
  end

  # Constants mean you only have to get the spelling right once.
  Facebook  = 'Facebook'
  Big_Lots  = 'Big Lots'
  Walmart   = 'Walmart'

  # A PDF will be generated for each recipient.
  #
  # A flag will also be set to allow conditional content: ifdef::Facebook[]
  def recipients
    [:anyone, Big_Lots, Facebook, Walmart]
  end

  # If flag_foo(recipient) returns true then an AsciiDoc attribute of the same
  # name will be set.  This means you can write your logic in Ruby instead of
  # using AsciiDoc[tor]'s expressions, which may be helpful.
  def flag_include_california_specific_sections(recipient)
    case recipient
    when Facebook, Big_Lots then true
    end
  end

  def extra_hyphenations
    # NB: never hyphenate "Surfboard"!
    %w{
      im-portant
      in-tra-net
      Surfboard
    }
  end
end
