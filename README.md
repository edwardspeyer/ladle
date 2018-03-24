# LᴀDʟE

_ladle_ is an _asciidoc_ template for building long-form CVs / résumés.
It focuses is on having carefully considered defaults with the goal of
producing easily readable typography.

<img src="https://github.com/edwardspeyer/ladle/blob/master/example/output/screenshot.png" width="622">

More examples are [in the repository.](https://github.com/edwardspeyer/ladle/tree/master/example/output)

Use it when you already have the attention of a hiring manager and you want
to give them
a five minute read that describes who you are and what you've done.

* You'll need to install some dependencies, e.g. in macOS:

```
$ gem install asciidoctor-pdf text-hyphen
$ brew install fontforge
```

* Try building the example:

```
$ bin/ladle example/cv.adoc
ladle: hyphenating with Text::Hyphen "en_us" based on locale of "en_US.UTF-8"
ladle: executing fontforge to build Gill Sans
ladle: using Gill Sans for sans-serif
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
