Multiple Table Notation
-----------------------

Mutliple Table Notation is a format for communicating multiple tables at once
using unicode text in a single file or transmission. It is abbreviated MTN.
This abbreviation may be pronounced "mountain", or at least that's how I like
to pronounce it. That's because in the english language "mtn" is a way to
abbreviate the word "mountain", and also because I live in Utah where there are
lots of mountains.

Comments
========

In the first place, comments are supported. Comments are line-based. More
precisely, any string within a transmission that starts with a `#` character
and ends with a newline (`\n`) character is discarded upon serialization
as if it had never been in the transmission in the first place.

Primitive Data Types
====================

The types of atomic data supported by MTN are exactly the same as those
primitive types which are supported by JSON: strings, numbers, boolean values,
and null; however, the notation for these is slightly different than in JSON.

Null is specified in MTN using a single question mark character (`?`).

Boolean values are listed the same as in JSON (`true` and `false`).

Strings are represented as simply a string of characters. Backslash escaping is
supported, so that upon deserialization, the sequence `\n` translates to a
newline character and `\t` translates into a tab character. Any other character
that is preceded by a backslash is simply printed literally without the
backslash on deserialization. This means that if you want to have a string that
is simply the question mark but you do not want to have it interpreted by MTN
as null, you can escape it: `\?`. (Note, if the string consists of more than
one single question mark character, no question mark in that string need be
escaped. It only needs escaped if the string is literally `?`.) As usual, to
actually have a backslash character in a string, simply escape that, too: `\\`.
Strings need not start or end with quotation marks, since everything is tab
delimited anyway. If quotation marks are in the cell, they will be counted as
part of the string. Quotation marks need not be backslash escaped.

Numbers are represented exactly the same in MTN as in JSON. Therefore, they
must conform to this regular expression:
```
    ^-?(0|[1-9][0-9]+)(\.[0-9]+)?([Ee][+-]?[0-9]+)?$
```

Where any primitive value is expected, a null value (`?`) may be used instead
within a transmission.

Tables
======

MTN encodes multiple tables using plain text printable unicode characters.
Tables consist of a name, table header values, a table column type header
followed by a plain old [TSV
table](https://www.iana.org/assignments/media-types/text/tab-separated-values),
which itself consists of a table column name header followed by rows containing
primitive values as described above.

Each line in the table represents a table row. Within each row, table cells are
separated by one or more consecutive tab characters (`\t`). Each row is ended
by a single newline character (`\n`). Literal tab characters cannot be escaped
and are disallowed within the value of a cell in the row of a table.  Empty
cells -- that is, cells which do not have characters in them -- are disallowed.
You cannot have a tab character followed directly by another tab character or
newline character in an attempt to specify a "zero" or "null" cell. It also is
an error for rows within a table to have fewer or more cells than that of other
rows in the table; all rows must have the same number of columns. All tables
must have at least one column.

Each column in the table has an associated name and type. The data within all
cells in a single column must and do share the same type.

The format of a table is as follows:

1. The name of the table followed by the newline character.
2. 0 or more HTTP-like headers for the table, allowing for the provision of
   metadata. These headers are string-key, string-value. Spaces are disallowed
   in the header key names. Header key names and values are separated by the
   characters `: `. Each header ends with a newline character.
3. If two consecutive newline characters are encountered, it is a signal that
   the headers have all been specified and that the table is about to begin.
4. The first row of the table is called the *type header* and contains the type
   for each column instead of actual data. Instead of data for a particular
   column, that column's type is listed instead. For each column, the contents
   of the cells must therefore be one of `boolean`, `number`, or `string`. No
   other value for the cells in this row is allowed.
5. The second row of the table is called the *name header* and contains the
   name for each column instead of actual data. The name must be a string in
   the format described above.
6. Subsequent rows represent actual data, one line for each row in the table.
7. When two consecutive newline characters are encountered, this means that
   there is no more data in this table and a new table definition may follow.

Transmissions
=============

A *transmission* is a single unit of serialization. It is a collection of
tables which in some sense don't make sense in isolation. This is also referred
to as an MTN document. The expectation is that this will typically take the
form of a file or a literal transmission over HTTP or some other protocol
between different computers.

Each transmission consists of a series of zero or more tables in the format
as described above. As stated above, tables are separated by two consecutive
newlines.  When three consecutive newlines are encountered, it means that no
more tables follow and that the end of the transmission has been reached.

Example
=======

Here is a minimal valid MTN document:

```
# I can put comments wherever I want! It's just the comment
# has to be all on the same line. no half-comment-half-data lines allowed.
customers
My-Header: something
Meta-Data: for tables!
# WHERE EVER
# But I still have to separate the table portion below from the headers above
# with a single blank line, found below

# Because the parser is supposed to throw these comments away as if they
# never existed.
number			string		boolean
primary_key	name			is_disabled
1	          Woof Woof	false
2						Bark Bark	false
3						?					?

customer_locations
Parent-Table: customers

number	number	string
primary_key	foreign_key	address
1	1	100 Hollywood Way
2	1	102 Hollywood Way
3	2	89 Bark Ct


```

It lists two tables, the `customers` table
and the `customer_locations` table. The first table lists three columns
and some not-so-interesting metadata. It has three rows and three columns.
Note, MTN gives us everything we need to list primary and foreign keys if we
want, just like we can in SQL databases. The third row has null values listed
in all rows except the column named `primary_key`.

The second table is named `customer_locations`. It has metadata sugesting it is
somehow related to the `customers` table in its metadata. (This `Parent-Table`
header is not part of the MTN standard, it's just listed here as an example
piece of metadata). It uses foreign and primary keys (although again those
aren't strictly part of the MTN standard) to link address information
to customers.

Motivation
==========

I wanted to create a table format that could effectively carry all of the
information that might be contained in a [JSON](http://json.org/) or
[YAML](https://yaml.org/) document, but in tabular form. Tabular form, I feel,
is a more flexible format and translates into the typed languages more easily.

While we are on the subject of typed languages, I wanted to create a notation
that keeps typed languages and polymorphism in mind while also being easy to
consume from dynamically typed lanagues (e.g., Python). A line-based, tabular
format for data works really well for this. Since the format is line-based --
that is, any given atomic piece of data is given line-by-line -- you can parse
some data into e.g., an array of objects, and then -- importantly -- you can
pause the parsing of data, process the data that *has* been parsed, and use it
to determine how to (i.e., into what types of structs or objects) the rest of
the data should be parsed. This is a sort of polymorphism in serialization.

The idea that you can "stop parsing" data halfway between and parse that data
differently based on the data you have already parsed is a powerful idea. It's
why HTTP API's are so prevalent, while JSON RPC APIs are not. JSON makes you
parse the whole document all at once, while HTTP lets you parse the endpoint,
HTTP verb and headers before you parse the body of the request. This allows you
to pause or partition the deserialization of an HTTP request and parse the body
based on what was given as the endpoint, verb or even headers. While this
ability or the lack therefo is less of a bother in a language like
[Python](https://www.python.org/), being able to deserialize part of the data
and leaving the rest unparsed comes pretty handy in a typed language setting.

On the other side, I wanted to provide a small amount of type data in the
standard itself so that dynamically typed languages would still be able to
intelligently deserialize the data and consume it easily as well, just like how
they do with JSON.

When I studied the differences between the HTTP request and the JSON document,
I saw that the mechanism by which an HTTP request could be partially parsed was
that it was a line-based serialization format, revolving around newline
characters. For example, newlines separate each header from each other and from
the `VERB /endpoint` line, and two newline characters together separate those
lines from the body.  This makes pausing during deserialization super simple.

Also, I think it's a shame that in order to pass around table data using text,
I have to give someone a SQL dump. Surely there's a better way to write
a table down in a way that's easier for humans to understand, but still
easy for computers to unambiguously deserialize.

Future Possibilities
====================

*JSON to MTN MAPPING*

I think if the right metadata table headers were standardized, and used to
decorate all the tables within a document, a 1-1 mapping could be established
between a JSON/YAML document and an MTN document. All the advantages of having
line-based parsing could then be achieved, while still presenting nested
structured data to the user of the serialization library. This could be
exploited to, I don't know, maybe make an RPC format that that is as easy to
work with in typed languages as in untyped languages.

Is This Even Useful
===================

I don't know, we'll see. At the moment it's just an idea I had.

-- Daniel Haskin
