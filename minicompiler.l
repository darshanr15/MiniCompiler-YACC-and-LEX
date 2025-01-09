%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "final.tab.h"
%}

%%
"if"                         { printf("if - keyword\n"); return IF; }
"else"                       { printf("else - keyword\n"); return ELSE; }
[a-zA-Z_][a-zA-Z0-9_]*      { printf("%s - identifier\n", yytext); yylval.str = strdup(yytext); return ID; }
[0-9]+                       { printf("%s - integer constant\n", yytext); yylval.intval = atoi(yytext); return INT; }
[0-9]+\.[0-9]+              { printf("%s - float constant\n", yytext); yylval.fltval = atof(yytext); return FLOAT; }
">"                          { printf("> - relational operator\n"); return GT; }
"<"                          { printf("< - relational operator\n"); return LT; }
">="                         { printf(">= - relational operator\n"); return GE; }
"<="                         { printf("<= - relational operator\n"); return LE; }
"=="                         { printf("== - relational operator\n"); return EQ; }
"!="                         { printf("!= - relational operator\n"); return NE; }
"="                          { printf("= - assignment operator\n"); return EQUAL; }
"{"                          { printf("{ - special character\n"); return LBRACE; }
"}"                          { printf("} - special character\n"); return RBRACE; }
"("                          { printf("( - special character\n"); return LPAREN; }
")"                          { printf(") - special character\n"); return RPAREN; }
","                          { printf(", - special character\n"); return yytext[0]; }
"//".*                         { printf("%s - multiline comment\n",yytext);}
"+"                          { printf("+ - Arithmetic Operator\n"); return PLUS; }
"-"                          { printf("- - Arithmetic Operator\n"); return MINUS; }
"*"                          { printf("* - Arithmetic Operator\n"); return STAR; }
"/"                          { printf("/ - Arithmetic Operator\n"); return DIV; }
[ \t\n]                     { ; }
.                           { printf("%s - special character\n", yytext); return yytext[0]; }
%%