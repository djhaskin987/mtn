/* MTN by Daniel Haskin
 * copyright 2018 Daniel Haskin.
 */

grammar MTN;

mtn_parse : ( mtn_tables | mtn_error ) EOF;

mtn_error
    : BAD
      {
        panic("BAD: " + $BAD.text);
      }
    ;

mtn_tables
    : table (TABLESEP table)*
    ;

TABLESEP
   : LF LF
   ;

table
    : tablename LF rowname (FIELDSEP rowname)* LF row+
    ;

tablename
    : IDENTIFIER
    ;

rowname
    : IDENTIFIER
    ;

IDENTIFIER
    : [\p{L}_] [\p{Alnum}_]*
    ;

row
    : field (FIELDSEP field)* LF
    ;

FIELDSEP
    : '\t' '\t'*
    ;

field
    : STRING
    | NUMBER
    | BOOL
    | NULL
    ;

STRING
    : '\'' STRINGCHAR *
    ;

fragment STRINGCHAR
    : ESC
    | GRAPHIC
    ;

// TODO put in the spec that you can escape form feed to for bwcompat reasons,
// and also the bell, because? NAH. just nrt I think.

fragment ESC
    : '\\' ([\\nrt] | CODEPOINT)
    ;

fragment CODEPOINT
    : 'u' HEX HEX HEX HEX
    ;

fragment HEX
    : [0-9a-fA-F]
    ;

fragment GRAPHIC
    : [\p{Print}]
    ;

NUMBER
    : '-'? INT ('.' DIGITS )? EXP?
    ;

fragment DIGITS
    : [0-9]+
    ;

fragment INT
    : '0' | [1-9] [0-9]*
    ;

fragment EXP
    : [Ee] [+\-]? INT
    ;

COMMENT
  : '#' ~ [^#\r\n] LF -> skip;


BOOL
    : TRUE
    | FALSE
    ;

NULL
    : 'n' 'u' 'l' 'l'
    ;

TRUE
    : 't' 'r' 'u' 'e'
    ;

FALSE
    : 'f' 'a' 'l' 's' 'e'
    ;

LF
    : '\r'? '\n'
    ;

BAD
    : .
    ;
