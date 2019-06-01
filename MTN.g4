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
    : mtn_table (LF mtn_table)*
    ;


mtn_table
    : mtn_tablename LF mtn_rowname (FIELDSEP mtn_rowname)* LF mtn_row+
    ;

mtn_tablename
    : IDENTIFIER
    ;

mtn_rowname
    : IDENTIFIER
    ;

mtn_row
    : mtn_field (FIELDSEP mtn_field)* LF
    ;

mtn_field
    : mtn_string
    | mtn_number
    | mtn_bool
    | mtn_null
    ;

mtn_string
    : STRING
    ;

mtn_number
    : NUMBER
    ;

mtn_bool
    : TRUE
    | FALSE
    ;

mtn_null
    : NULL
    ;

NULL
    : 'null'
    ;

TRUE
    : 'true'
    ;

FALSE
    : 'false'
    ;

IDENTIFIER
    : [\p{L}_] [\p{Alnum}_]*
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

FIELDSEP
    : '\t' '\t'*
    ;

LF
    : EOL
    ;

COMMENT
    : '#' ~[^\r\n]* EOL -> skip
    ;

fragment EOL
    : '\r'? '\n'
    ;

NUMBER
    : '-'? WHOLE ('.' FRAC )? EXP?
    ;

fragment FRAC
    : [0-9]+
    ;

fragment WHOLE
    : '0' | [1-9] [0-9]*
    ;

fragment EXP
    : [Ee] [+\-]? WHOLE
    ;

BAD
    : .
    ;
