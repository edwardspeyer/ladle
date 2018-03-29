# Ladle

* Templating system for writing **CVs** and **resumes**
* You write in **AsciiDoc** and _ladle_ drives _asciidoctor-pdf_ to generate **PDF** output
* It focuses on producing **easily readable typography**
* It has carefully considered defaults; see the examples [**in the repository**](example/output)
* Minimal dependencies!  20MB vs 3.5GB of MacTeX!

## Example

<img src="https://github.com/edwardspeyer/ladle/blob/master/example/output/screenshot.png" width="1084">

```
$ bin/ladle example/cv.adoc
🥄  hyphenating with Text::Hyphen "en_us" based on locale of "en_US.UTF-8"
🥄  executing fontforge to build Gill Sans
🥄  fonts prepared for Gill Sans
🥄  building generic version:
🥄    name         : Hannah Folder
🥄    document     : Resume
🥄    recipient    : generic
🥄    file_name    : Hannah Folder Resume.pdf
🥄    page_size    : A4
🥄    margin       : 1.41in
🥄    sans_serif   : Gill Sans
🥄    font_size    : 10.01
🥄    line_height  : 1.203
🥄    footer_left  : Hannah Folder -- {page-number} of {page-count}
🥄    footer_right : Version 88 (C) 2018
🥄    hyphenations : Surfboard im-portant in-tra-net
🥄    flags        : generic
🥄  generated 2 pages
🥄  median line-length of 89 chars
🥄  building Big Lots version:
🥄    ...
🥄    recipient    : Big Lots
🥄    file_name    : Hannah Folder Resume - Big Lots.pdf
🥄    flags        : big_lots include_my_address mention_california mention_shuffleboard
🥄  generated 2 pages
🥄  median line-length of 89 chars
🥄  building Facebook version:
🥄    ...
🥄    recipient    : Facebook
🥄    file_name    : Hannah Folder Resume - Facebook.pdf
🥄    flags        : facebook mention_california
🥄  generated 2 pages
🥄  median line-length of 89 chars
🥄  building Walmart version:
🥄    ...
🥄    recipient    : Walmart
🥄    file_name    : Hannah Folder Resume - Walmart.pdf
🥄    flags        : walmart
🥄  generated 2 pages
🥄  median line-length of 89 chars
🥄  done

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

ifdef::mention_california[]
* I've spent a total of 10 years of my career in California and have a detailed
  knowledge of the state-wide lumber and pulp industry.
endif::[]
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
  flag :mention_california
  flag :mention_shuffleboard

recipient 'Facebook'
  flag :mention_california

recipient 'Walmart'
  flag :include_my_address
````


## Hints and Tips

### Typefaces

_EB Garamond_ is the serif face used for the body text.  Garamond has a low
_x-height_ which makes for a readable body text even at low line-heights.
This allows for more text than usual to be placed on your CV without sacrificing
readability.  Georg Duffner's rendition -- shipped with _ladle_ -- looks really good, and
you can read more about his work on the
[project's website](http://www.georgduffner.at/ebgaramond/).

For headings, there are a few choices,
which can be selected with the `sans_serif "Font Name"` config option:

<img src="example/typefaces/montage.png" width="460">

* _Gill Sans_ is used by default if (i) you're on macOS,
  (ii) it's available on your system; and
  (iii) you have _fontforge_ installed.
  It's a stylish and classic British design long associated with marketing
  and it is especially impactful in bold, as used in the examples.
  
* _Lato Black_ ships with _ladle_ so it can always be used, and is the default
  fallback if Gill Sans isn't found.
  It is approximately the same weight as Monotype Gill Sans,
  but not as stylised.

* _Cabin_ also ships with _ladle_, and is more in the style of Gill Sans,
  but doesn't have the inky boldness.

### Font, Line and Margin Sizes

In order to create type that is optimised for readability,
you will want to have:
* a font-size of around 10pt;
* a line-height of 120%; and
* a margin that gives you around 75 to 90 characters per line.

_ladle_'s defaults should get you close, but you'll want to edit
your config file to enlarge your margins to the largest size possible, and
increase line-height as much as possible to fill up the page.

Use explicit AsciiDoc page-breaks (`<<<<`) where you expect there to be a page-break
and don't rely on implicit page-breaks.  _ladle_ will help you detect page
overflows at the command line as you adjust the _font-size_, _line-height_
and _margin_ parameters.  Consider the following example AsciiDoc:

````asciidoc
==== Job 1 ====
* A
* B
* C

==== Job 2 ====
* D
* E
````

Your goal is to render it onto exactly two pages, one section per page,
avoiding page overflow:

````
  Good:                      Bad:
  +-----+  +-----+           +-----+  +-----+
  |Job 1|  |Job 2|           |Job 1|  |C....|  < overflow
  |A....|  |D....|           |A....|  |Job 2|
  |B....|  |E....|           |B....|  |D....|
  |C....|  |     |           |..   |  |E....|
  1-----+  2-----+           1-----+  2-----+
````

It's much easier to debug this from the command line if you use an explicit
page break:
  
````asciidoc  
==== Job 1 ====
* A
* B
* C

<<<<

==== Job 2 ====
* D
* E
````

When the overflow error case occurs, 3 pages will be rendered, and 
_ladle_ will give you a warning (highlighted in red on the command line):

````
  +-----+  +-----+  +-----+
  |Job 1|  |C....|  |Job 2|
  |A....|  |     |  |D....|
  |B....|  |     |  |E....|
  |..   |  |     |  |     |
  1-----+  2-----+  3-----+

$ bin/ladle example/cv.adoc
🥄  building generic version:
🥄  generated 2 pages
🥄  building Big Lots version:
🥄  generated _3_ pages
````




## Alternatives to _ladle_

_ladle_ is for long-form CVs written in prose.
It's not so good for short _résumés_.
Ideally you would use _ladle_
to make a readable document for someone whose attention
you already have, where you know they'll have a full
five minutes devoted to reading all about your wonderful life.

The following look like good options
for creating an eye-catching one-page resume
that will get someone's attention:
* [Deedy-Resume](https://github.com/deedy/Deedy-Resume):
  pretty, but divisive in style!
* [best-resume-ever](https://github.com/salomonelli/best-resume-ever),
  though it looks like you'll need to fix a rendering bug.
* Xavier Danaux's
  [LaTeX template](https://www.overleaf.com/latex/templates/modern-cv-and-cover-letter-2015-version/sttkgjcysttn)
* The Breakout List's
  [LaTeX template](https://www.sharelatex.com/project/55db6ac384d1be370a7d4b9a)
* [careercup.com's tools](https://www.careercup.com/resume)
