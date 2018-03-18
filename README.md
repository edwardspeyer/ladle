# LᴀDʟE

_ladle_ is an _asciidoc_ template for building long-form CVs / résumés.
It focuses is on having carefully considered defaults with the goal of
producing easily readable typography.
Use it when you already have the attention of a hiring manager, and you want
to give them
a five minute read that describes who you are and what you've done.

* _ladle_ runs on macOS (for now) -- you'll need to install the following
  dependencies:

```
$ gem install asciidoctor-pdf text-hyphen
$ brew install fontforge
```

* Try building the example:

```
$ bin/ladle example/example.rb
2018-03-16 17:30:28 +0000 building for Facebook
2018-03-16 17:30:29 +0000 flags: ["california"]
2018-03-16 17:30:29 +0000 building for WalMart
2018-03-16 17:30:29 +0000 flags: []
2018-03-16 17:30:29 +0000 done

$ ls *.pdf
Hazel Folder Résumé - Big Lots.pdf
Hazel Folder Résumé - Facebook.pdf
Hazel Folder Résumé - Walmart.pdf
Hazel Folder Résumé.pdf
```

* Read the example source code, then roll your own!
