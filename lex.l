%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "y.tab.h"
    int countn=0;
%}

%%

"ip"                        {strcpy(yylval.nd_obj.name, yytext); printf("ip"); return INPUT;}
"op"                        {strcpy(yylval.nd_obj.name, yytext); printf("op"); return OUTPUT;}

"int"                        {strcpy(yylval.nd_obj.name, yytext); printf("dt_integer");; return DT_INT;}
"float"                        {strcpy(yylval.nd_obj.name, yytext); printf("dt_float"); return DT_FLOAT;}
"char"                        {strcpy(yylval.nd_obj.name, yytext); printf("dt_character"); return DT_CHAR;}
"str"                        {strcpy(yylval.nd_obj.name, yytext); printf("dt_string"); return DT_STR;}
"bool"                        {strcpy(yylval.nd_obj.name, yytext); printf("dt_boolean"); return DT_BOOL;}

"if"                        {strcpy(yylval.nd_obj.name, yytext); printf("if"); return IF;}
"else"                        {strcpy(yylval.nd_obj.name, yytext); printf("else"); return ELSE;}

"as"                        {strcpy(yylval.nd_obj.name, yytext); printf("as"); return AS;}

"true"                        {strcpy(yylval.nd_obj.name, yytext); printf("true"); return TRUE;}
"false"                        {strcpy(yylval.nd_obj.name, yytext); printf("false"); return FALSE;}

"+"                        {strcpy(yylval.nd_obj.name, yytext); printf("add"); return ADD;}
"-"                        {strcpy(yylval.nd_obj.name, yytext); printf("sub"); return SUBTRACT;}
"*"                        {strcpy(yylval.nd_obj.name, yytext); printf("mult"); return MULTIPLY;}
"/"                        {strcpy(yylval.nd_obj.name, yytext); printf("divide"); return DIVIDE;}
"%"                        {strcpy(yylval.nd_obj.name, yytext); printf("mod"); return MODULO;}
"**"                        {strcpy(yylval.nd_obj.name, yytext); printf("pow"); return RAISE_TO;}
"++"                        {strcpy(yylval.nd_obj.name, yytext); printf("incr"); return INCREMENT;}
"--"                        {strcpy(yylval.nd_obj.name, yytext); printf("decr"); return DECREMENT;}
"<"                        {strcpy(yylval.nd_obj.name, yytext); printf("lt"); return LESS_THAN;}
">"                        {strcpy(yylval.nd_obj.name, yytext); printf("gt"); return GREATER_THAN;}
"<="                        {strcpy(yylval.nd_obj.name, yytext); printf("lte"); return LESS_OR_EQ;}
">="                        {strcpy(yylval.nd_obj.name, yytext); printf("gte"); return GREATER_OR_EQ;}
"="                        {strcpy(yylval.nd_obj.name, yytext); printf("assign");; return ASSIGN;}
"=="                        {strcpy(yylval.nd_obj.name, yytext); printf("eq"); return EQUAL;}
"!="                        {strcpy(yylval.nd_obj.name, yytext); printf("neq"); return NOT_EQ;}
"&&"                        {strcpy(yylval.nd_obj.name, yytext); printf("and"); return AND;}
"||"                        {strcpy(yylval.nd_obj.name, yytext); printf("or"); return OR;}

" "                        {printf(" ");}

"("                        {strcpy(yylval.nd_obj.name, yytext); printf("("); return RO;}
")"                        {strcpy(yylval.nd_obj.name, yytext); printf(")"); return RC;}
"{"                        {strcpy(yylval.nd_obj.name, yytext); printf("{"); return CO;}
"}"                        {strcpy(yylval.nd_obj.name, yytext); printf("}"); return CC;}

([0][A-Za-z]([A-Za-z]|[0-9])*|[1-9][0-9]*[A-Za-z]([A-Za-z]|[0-9])*) {printf("wrong_id"); return ERROR;}

([0]|[1-9][0-9]*)          {strcpy(yylval.nd_obj.name, yytext); yylval.nd_obj.value = atoi(yytext); printf("num"); return NUMBER;}
(([0-9]+)\.([0-9]+))       {strcpy(yylval.nd_obj.name, yytext); printf("float"); return FLOAT_NUM;}
(["].*["])                 {strcpy(yylval.nd_obj.name, yytext); printf("string"); return STRING;}
(['].['])                  {strcpy(yylval.nd_obj.name, yytext); printf("character"); return CHAR;}

([A-Za-z]([A-Za-z]|[0-9])*) {strcpy(yylval.nd_obj.name, yytext); printf("id (%s)", yytext); yylval.nd_obj.idVal = yytext[0] - 'a'; return ID;}

"\n" { printf("\n"); countn++;}
"\r" { printf("\r"); }

. {printf("error - %d", *yytext); return *yytext;}

%%

int yywrap() {
   return 1;
}