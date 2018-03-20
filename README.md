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
$ bin/ladle example/cv.adoc
ladle: building generic version
ladle: building Big Lots version
ladle: building Facebook version
ladle: building Walmart version
ladle: done

$ ls *.pdf
Hazel Folder Resume - Big Lots.pdf
Hazel Folder Resume - Facebook.pdf
Hazel Folder Resume - Walmart.pdf
Hazel Folder Resume.pdf
```

* Read the example's source code, then roll your own!
