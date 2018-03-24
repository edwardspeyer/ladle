# LᴀDʟE

_ladle_ is an _asciidoc_ template for building long-form CVs / résumés.
It focuses on having carefully considered defaults with the goal of
producing easily readable typography.
The repository contains some [example PDFs built with _ladle_](example/output).

<img src="https://github.com/edwardspeyer/ladle/blob/master/example/output/screenshot.png" width="622">


## Example

_ladle_ builds PDF resumes at the command line (run with `--help` for more information):

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
Hannah Folder Resume - Big Lots.pdf
Hannah Folder Resume - Facebook.pdf
Hannah Folder Resume - Walmart.pdf
Hannah Folder Resume.pdf
```


[`example/cv.adoc`](example/cv.adoc) contains a CV formatted in AsciiDoc:

````asciidoc
== Hannah Folder ==

* hannah.folder@example.com
* +1 (555) 202 3003
ifdef::include_my_address[]
* 814 Vanderbilt Ave #22, Brooklyn, NY 11234
endif::[]


=== *Overview* ===

* Cardboard manufacturing specialist with over 20 years of experience with wood
  pulping, corrugation, fold-automation and _This Way Up_  arrow orientation.
  I care about the details and I ship projects on time.

* Most experiencd with *brown*, *white* and *grey* boxes.  Some experience with
  other box colors and also with *process automation* for box making all the
  way from tree-fell to box shipment.
````

[`example/config`](example/config) controls the PDF conversion
and sets per-recipient feature flags.
The file format is documented in the example, and the main commands
look like this:

````ruby
name 'Hannah Folder'
hyphenate 'im-portant', 'in-tra-net'
hyphenate 'Surfboard'
margin '1.41in'

recipient 'Big Lots'
  flag :promote_my_california_connections
  flag :mention_shuffleboard

recipient 'Facebook'
  flag :promote_my_california_connections

recipient 'Walmart'
  flag :include_my_address
````

