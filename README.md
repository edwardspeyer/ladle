# Ladle

## What is Ladle?

* Helps you write your **CV** / **resume**
* Write in **AsciiDoc** and generate **PDF** output
* Focuses on **easily readable typograph**
* Carefully considered default typefaces and metrics; examples [**in the repository**](example/output)
* Works best with **long-format** writing where you already have someone's attention
* Minimal dependencies (~20MB); no 3.5GB of MacTeX required!
* For a quick-read resume, consider
[Deedy-Resume](https://github.com/deedy/Deedy-Resume),
[best-resume-ever](https://github.com/salomonelli/best-resume-ever)
or a LaTeX template
(e.g.
[①](https://www.overleaf.com/latex/templates/modern-cv-and-cover-letter-2015-version/sttkgjcysttn#.WrYsImacZE4)
[②](https://www.sharelatex.com/project/55db6ac384d1be370a7d4b9a)
[③](https://www.careercup.com/resume))


## Example

<img src="https://github.com/edwardspeyer/ladle/blob/master/example/output/screenshot.png" width="622">

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

