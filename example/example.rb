class Config < Ladle::Config
  Facebook  = 'Facebook'
  WalMart   = 'WalMart'

  # Path is relative to the Ruby config
  # Default to the same name but with .adoc?
  #def asciidoc_source
  #  'example.adoc'
  #end

  def display_name
    'Hazel Folder'
  end

  def document_type
    'Resume'
  end

  def recipients
    [Facebook, WalMart]
  end
    
  def flag_california(recipient)
    recipient == Facebook
  end

  def version_start
    100
  end

  def extra_hyphenations
    {
      # TODO Some examples?
    }
  end
end
