Definitions.

Rules.

% Pushing back a newline charachter messes up counting

FORMAT\:\s1A\n                      : {token, {start, TokenLine}}.
#\sGroup[^\n]*\n                    : skip_token.
#\s[a-zA-Z\s]*\s\[\/[a-z{}\/]*\]\n  : {token, {resource, TokenLine, TokenChars}}.
##\s[a-zA-Z\s]*\s\[[A-Z]+\]\n       : {token, {action, TokenLine, TokenChars}}.
% unknown headings include data and intro section
#\s[a-zA-Z\s]*\n                    : skip_token.
[^#][^#\n]*\n                       : skip_token.
\n                                  : skip_token.

Erlang code.
