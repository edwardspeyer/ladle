# Ladle

## What is Ladle?

* Helps you write your **CV**, and maybe a **resume** too
* You write in **AsciiDoc** and _ladle_ generates **PDF** output
* It focuses on producing **easily readable typography**
* It has carefully considered defaults; see the examples [**in the repository**](example/output)
* Minimal dependencies!  20MB vs 3.5GB of MacTeX!

## Example

<img src="https://github.com/edwardspeyer/ladle/blob/master/example/output/screenshot.png" width="1084">

_ladle_ builds PDF resumes at the command line (run with `--help` for more information):

```
$ bin/ladle example/cv.adoc
🥄  hyphenating with Text::Hyphen "en_us" based on locale of "en_US.UTF-8"
🥄  using Gill Sans for sans-serif
🥄  building generic version:
🥄    name         : Hannah Folder
🥄    document     : Resume
🥄    page_size    : A4
🥄    recipient    : generic
🥄    margin       : 1.41in
🥄    font_size    : 10.01
🥄    line_height  : 1.203
🥄    file_name    : Hannah Folder Resume.pdf
🥄    footer_left  : Hannah Folder -- {page-number} of {page-count}
🥄    footer_right : Version 76 (C) 2018
🥄    flags        : generic
🥄    hyphenations : im-portant in-tra-net Surfboard
🥄  building Big Lots version:
🥄    ...
🥄    recipient    : Big Lots
🥄    file_name    : Hannah Folder Resume - Big Lots.pdf
🥄    flags        : big_lots mention_california mention_shuffleboard include_my_address
🥄  building Facebook version:
🥄    ...
🥄    recipient    : Facebook
🥄    file_name    : Hannah Folder Resume - Facebook.pdf
🥄    flags        : facebook mention_california
🥄  building Walmart version:
🥄    ...
🥄    recipient    : Walmart
🥄    file_name    : Hannah Folder Resume - Walmart.pdf
🥄    flags        : walmart
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

### What it isn't

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
