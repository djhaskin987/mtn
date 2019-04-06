Multiple Table Notation, version 2.0.0
--------------------------------------

Multiple Table Notation is a format for communicating multiple tables at once
using unicode text in a single file or transmission. It is abbreviated MTN.
This abbreviation may be pronounced "mountain", or at least that's how I like
to pronounce it. That's because in the english language "mtn" is a way to
abbreviate the word "mountain", and also because I live in Utah where there are
lots of mountains.

Transmissions
=============

A *transmission* is a single unit of serialization. It is a collection of
tables of data which in some sense don't make sense in isolation. This is also
referred to as an MTN document. The expectation is that this will typically
take the form of a file or a literal transmission over HTTP or some other
protocol between different computers.

MTN encodes multiple tables using plain text printable unicode characters.
Each transmission consists of a series of zero or more tables in the format
as described below. As stated above, tables are separated by two consecutive
newlines.  When three consecutive newlines are encountered, it means that no
more tables follow and that the end of the transmission has been reached.

Comments
========

In the first place, comments are supported. Comments are line-based. More
precisely, any line within a transmission that starts with a `#` character
and ends with a newline (`\n`) character is discarded upon serialization
as if it had never been in the transmission in the first place.

Tables
======

Tables consist of a name, a table header containing column names, and
rows containing primitive values as described above.

The first line contains a table name, which starts with an alphabetic character
and may contain alphanumeric characters and the underscore character (`_`). At
the end of the table name, a newline character is expected, ending the table
name line.

The next line contains a table header. Each column in the table has an
associated name and these names are found within the table header. They are
separated from each other by a tab character and the line is ended with a
newline. The column names follow the same format as the table name.

The next lines, if non-empty, constitute the rows within the table, one row per
line. Each row contains several cells, with each cell containing data. Cells
are separated by a single tab character (`\t`). Each row is ended by a single
newline character (`\n`). Literal tab characters cannot be escaped and are
disallowed within the value of a cell in the row of a table.  Empty cells --
that is, cells which do not have characters in them -- are disallowed.  You
cannot have a tab character followed directly by another tab character or
newline character in an attempt to specify a "zero" or "null" cell. It also is
an error for rows within a table to have fewer or more cells than that of other
rows in the table; all rows must have the same number of columns. All tables
must have at least one column, but may contain zero rows.

When two consecutive newline characters are encountered, this means that
there is no more data in this table and a new table definition may follow.

If three consecutive newline characters are encountered, this signifies
the end of the transmission.

Primitive Data Types within Cells
=================================

Any cell within a table row may contain data.

The types of atomic data supported by MTN are exactly the same as those
primitive types which are supported by JSON: strings, numbers, boolean values,
and null; however, the notation for these is slightly different than in JSON.

Null is specified in MTN the same as in JSON by the string `null`.

Boolean values are listed the same as in JSON (`true` and `false`).

Strings are represented as simply a string of characters prefixed with a single
quotation mark character (`'`). Backslash escaping is supported, so that upon
deserialization, the sequence `\n` translates to a newline character and `\t`
translates into a tab character. Any other character that is preceded by a
backslash is simply printed literally without the backslash on deserialization.
As usual, to actually have a backslash character in a string, simply escape
that, too: `\\`. Nothing else need be escaped. In particular, single quote
characters need not be escaped. For example, to specify a string consisting
solely of a single quote character, prefix it with a single quote character as
with any other string: `''`. This also means that the empty string is not empty
but consists of a single single-quote character: `'`.

Numbers are represented exactly the same in MTN as in JSON. Therefore, they
must conform to this regular expression:
```
    ^-?(0|[1-9][0-9]+)(\.[0-9]+)?([Ee][+-]?[0-9]+)?$
```

Example
=======

Here is a minimal valid MTN document:

```
# I can put comments wherever I want! It's just the comment
# has to be all on the same line. no half-comment-half-data lines allowed.
customers
# WHERE EVER,
# because the parser is supposed to throw these comments away as if they
# never existed.
primary_key	name	is_disabled
1	'Woof Woof	false
2	'Bark Bark	false
3	null	null	null
# But I still have to separate the table above below from the headers above
# with a single blank line, found below

customer_locations
primary_key	foreign_key	address
1	1	'100 Hollywood Way
# Mid-data comment
2	1	'102 Hollywood Way
3	2	'89 Bark Ct
# End with two blank lines!


```
It lists two tables, the `customers` table
and the `customer_locations` table. The first table lists three columns.
The third row has null values listed in all rows except the column named
`primary_key`. The second table is named `customer_locations`.

Motivation
==========

I wanted to create a table format that could effectively carry all of the
information that might be contained in a [JSON](http://json.org/) or
[YAML](https://yaml.org/) document, but in tabular form. Tabular form, I feel,
is a more flexible format and translates into the typed languages more easily.

On the other side, I wanted to provide a small amount of type data in the
standard itself so that dynamically typed languages would still be able to
intelligently deserialize the data and consume it easily as well, just like how
they do with JSON.

Also, I think it's a shame that in order to pass around table data using text,
I have to give someone a SQL dump. Surely there's a better way to write
a table down in a way that's easier for humans to understand, but still
easy for computers to unambiguously deserialize.

Future Possibilities
====================

* References might be introduced, as there is lots of room in the current
  standard allowing for them

* Cell formulas might be introduced, as there is lots of room in the current
  standard allowing for them. This format is evolving to look more like a
  text-based spread sheet, so there may be cause (and room in the standard) for
  cell formulas.

Is This Even Useful
===================

I don't know, we'll see. At the moment it's just an idea I had.

-- Daniel Haskin

Changelog
=========

* Version 1.0.0:
  * Initial version with the idea and focus of a line-based format
    which could be used as some sort of RPC format.
    (I now think that line-based RPC is best served by the HTTP standard.)

* Version 2.0.0:
  * Strings prefixed with `'`
  * Null changed from `?` to `null` to match closer with JSON and to ease
    mechanical parsing
  * Column type prefixes removed, as they are useless to typed languages and
    superfluous to untyped languages
  * Columns may contain cells of differing types
  * Multiple consecutive tab characters are disallowed to conform with the
    [IANA TSV standard](https://www.iana.org/assignments/media-types/text/tab-separated-values)
  * Metadata (headers) removed
