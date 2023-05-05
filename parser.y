%{
   #include<stdio.h>
   #include<string.h>
   #include<stdlib.h>
   #include<ctype.h>
   void yyerror(const char *s);
   int yylex();
   int yywrap();
   int sym[26];

   // intermediate code generation related
   char buffer[100];
   char icg[50][100];
   int label = 0;
   int ic_idx = 0;

   struct Node {
      char label[32];
      struct Node* children[10];
      int num_children;
      int value;
   };

   struct Node * createEntity(char name[32], int val);
   void add_child(struct Node *parent, struct Node *child);

   struct Node *root = NULL;

   int x = 15;
%}

%union { 
	struct var_name { 
		char name[32];
      int value;
      int idVal;
		struct Node* entity;
      char lexname[32];
	} nd_obj;

   struct ifelse {
      char name[32];
      char if_body[5];
      char else_body[5];
		struct Node* entity;
      char lexname[32];
	} nd_obj_2;
} 

%token <nd_obj> INPUT OUTPUT DT_INT DT_FLOAT DT_CHAR DT_STR DT_BOOL IF ELSE AS TRUE FALSE ADD SUBTRACT MULTIPLY DIVIDE MODULO RAISE_TO INCREMENT DECREMENT LESS_THAN GREATER_THAN LESS_OR_EQ GREATER_OR_EQ ASSIGN EQUAL NOT_EQ AND OR RO RC CO CC NUMBER FLOAT_NUM STRING CHAR ID ERROR
%type <nd_obj> start body block else statement value datatype relop expression term factor
%type <nd_obj_2> condition

%%

start: body {
   $$.entity = createEntity("start", 0);
   add_child($$.entity, $1.entity);
   root = $$.entity;
}
;

body: block {
   $$.entity = createEntity("body", 0); 
   add_child($$.entity, $1.entity); 
}
| block body {
   $$.entity = createEntity("body", 0); 
   add_child($$.entity, $1.entity);
   add_child($$.entity, $2.entity);
}
;

block: AS RO condition RC CO body CC { printf("\n parser : while loop"); }
| IF RO condition RC { sprintf(icg[ic_idx++], "\nLABEL %s:\n", $3.if_body); } CO body CC { sprintf(icg[ic_idx++], "\nLABEL %s:\n", $3.else_body); } else { 
   sprintf(icg[ic_idx++],"GOTO next\n");

   $$.entity = createEntity("block", 0);
   $1.entity = createEntity("IF", 0);
   $2.entity = createEntity("RO", 0);
   $4.entity = createEntity("RC", 0);
   $6.entity = createEntity("CO", 0);
   $8.entity = createEntity("CC", 0);

   add_child($$.entity, $1.entity);
   add_child($$.entity, $2.entity);
   add_child($$.entity, $3.entity);
   add_child($$.entity, $4.entity);
   add_child($$.entity, $6.entity);
   add_child($$.entity, $7.entity);
   add_child($$.entity, $8.entity);
   add_child($$.entity, $10.entity);
}
| statement {
   $$.entity = createEntity("block", 0);
   add_child($$.entity, $1.entity);
}
| OUTPUT RO value RC { 
   $$.entity = createEntity("block", 0);
   $1.entity = createEntity("OUTPUT", 0);
   $2.entity = createEntity("RO", 0);
   $4.entity = createEntity("RC", 0);

   add_child($$.entity, $1.entity);
   add_child($$.entity, $2.entity);
   add_child($$.entity, $3.entity);
   add_child($$.entity, $4.entity);
}
| datatype ID ASSIGN INPUT RO STRING RC
;

else: ELSE CO body CC {
   $$.entity = createEntity("else", 0);
   $1.entity = createEntity("ELSE", 0);
   $2.entity = createEntity("CO", 0);
   $4.entity = createEntity("CC", 0);

   add_child($$.entity, $1.entity);
   add_child($$.entity, $2.entity);
   add_child($$.entity, $3.entity);
   add_child($$.entity, $4.entity);
}
|
;

statement: datatype ID ASSIGN expression {
   sprintf(icg[ic_idx++], "%s = %s\n", $2.name, $4.name);

   $$.entity = createEntity("statement", 0);
   $2.entity = createEntity("ID", 0);
   $3.entity = createEntity("ASSIGN", 0);
   add_child($$.entity, $1.entity);
   add_child($$.entity, $2.entity);
   add_child($$.entity, $3.entity);
   add_child($$.entity, $4.entity);

   sym[$2.idVal] = ($4.entity)->value;
}
| ID ASSIGN expression {

   sprintf(icg[ic_idx++], "%s = %s\n", $1.name, $3.name); sym[$1.idVal] = $3.value;

   $$.entity = createEntity("statement", 0);
   $1.entity = createEntity("ID", ($3.entity)->value);
   $2.entity = createEntity("ASSIGN", 0);
   add_child($$.entity, $1.entity);
   add_child($$.entity, $2.entity);
   add_child($$.entity, $3.entity);

   sym[$1.idVal] = ($3.entity)->value;
}
;

value: NUMBER {
   strcpy($$.name, $1.name);

   $$.entity = createEntity("value", 0);
   $1.entity = createEntity("NUMBER", $1.value);

   add_child($$.entity, $1.entity);

   ($$.entity)->value = $1.value;
   ($1.entity)->value = $1.value;
}
| FLOAT_NUM {
   $$.entity = createEntity("value", 0);
   $1.entity = createEntity("FLOAT_NUM", $1.value);

   add_child($$.entity, $1.entity);

   ($$.entity)->value = $1.value;
   ($1.entity)->value = $1.value;
}
| STRING
| CHAR
| ID {
   strcpy($$.name, $1.name);

   $$.entity = createEntity("value", 0);
   $1.entity = createEntity("ID", sym[$1.idVal]);

   add_child($$.entity, $1.entity);

   ($$.entity)->value = sym[$1.idVal];
   ($1.entity)->value = sym[$1.idVal];
}
;

datatype: DT_INT {
   $$.entity = createEntity("datatype", 0);
   $1.entity = createEntity("DT_INT", 0);

   add_child($$.entity, $1.entity);
}
| DT_FLOAT {
   $$.entity = createEntity("datatype", 0);
   $1.entity = createEntity("DT_FLOAT", 0);

   add_child($$.entity, $1.entity);
}
| DT_CHAR
| DT_STR
| DT_BOOL {
   $$.entity = createEntity("datatype", 0);
   $1.entity = createEntity("DT_BOOL", 0);

   add_child($$.entity, $1.entity);
}
;

condition: value relop value {
   sprintf(icg[ic_idx++], "\nif (%s %s %s) GOTO L%d else GOTO L%d\n", $1.name, $2.name, $3.name, label, label+1);

   sprintf($$.if_body, "L%d",label++);
   sprintf($$.else_body,"L%d",label++);

   $$.entity = createEntity("condition", 0);

   add_child($$.entity, $1.entity);
   add_child($$.entity, $2.entity);
   add_child($$.entity, $3.entity);
}
| TRUE {
   $$.entity = createEntity("condition", 1);
   $1.entity = createEntity("TRUE", 1);

   add_child($$.entity, $1.entity);
}
| FALSE {
   $$.entity = createEntity("condition", 0);
   $1.entity = createEntity("FALSE", 0);

   add_child($$.entity, $1.entity);
}
;

relop: LESS_THAN {
   strcpy($$.name, $1.name);

   $$.entity = createEntity("relop", 0);
   $1.entity = createEntity("LESS_THAN", 0);

   add_child($$.entity, $1.entity);
}
| GREATER_THAN {
   strcpy($$.name, $1.name);

   $$.entity = createEntity("relop", 0);
   $1.entity = createEntity("GREATER_THAN", 0);

   add_child($$.entity, $1.entity);
}
| LESS_OR_EQ {
   strcpy($$.name, $1.name);

   $$.entity = createEntity("relop", 0);
   $1.entity = createEntity("LESS_OR_EQ", 0);

   add_child($$.entity, $1.entity);
}
| GREATER_OR_EQ {
   strcpy($$.name, $1.name);

   $$.entity = createEntity("relop", 0);
   $1.entity = createEntity("GREATER_OR_EQ", 0);

   add_child($$.entity, $1.entity);
}
| EQUAL {
   strcpy($$.name, $1.name);

   $$.entity = createEntity("relop", 0);
   $1.entity = createEntity("EQUAL", 0);

   add_child($$.entity, $1.entity);
}
| NOT_EQ {
   strcpy($$.name, $1.name);

   $$.entity = createEntity("relop", 0);
   $1.entity = createEntity("NOT_EQ", 0);

   add_child($$.entity, $1.entity);
}
| AND {
   strcpy($$.name, $1.name);

   $$.entity = createEntity("relop", 0);
   $1.entity = createEntity("AND", 0);

   add_child($$.entity, $1.entity);
}
| OR {
   strcpy($$.name, $1.name);

   $$.entity = createEntity("relop", 0);
   $1.entity = createEntity("OR", 0);

   add_child($$.entity, $1.entity);
}
;

expression: expression ADD term {
   {sprintf(icg[ic_idx++], "%s = %s %s %s\n",  $$.name, $1.name, $2.name, $3.name); $$.value = $1.value + $3.value;}

   $$.entity = createEntity("\nexpression", 0);
   $2.entity = createEntity("\nADD", 0);

   add_child($$.entity, $1.entity);
   add_child($$.entity, $2.entity);
   add_child($$.entity, $3.entity);

   ($$.entity)->value = ($1.entity)->value + ($3.entity)->value;
}
| expression SUBTRACT term {

   $$.entity = createEntity("\nexpression", 0);
   $2.entity = createEntity("\nSUBTRACT", 0);

   add_child($$.entity, $1.entity);
   add_child($$.entity, $2.entity);
   add_child($$.entity, $3.entity);

   ($$.entity)->value = ($1.entity)->value - ($3.entity)->value;
}
| term {

   $$.entity = createEntity("\nterm", 0);

   add_child($$.entity, $1.entity);

   ($$.entity)->value = ($1.entity)->value;
}
;

term: term MULTIPLY factor {

   $$.entity = createEntity("\nterm", 0);
   $2.entity = createEntity("\nMULTIPLY", 0);
   add_child($$.entity, $1.entity);
   add_child($$.entity, $2.entity);
   add_child($$.entity, $3.entity);
   ($$.entity)->value = ($1.entity)->value * ($3.entity)->value;
}
| term DIVIDE factor {

   $$.entity = createEntity("\nterm", 0);
   $2.entity = createEntity("\nDIVIDE", 0);

   add_child($$.entity, $1.entity);
   add_child($$.entity, $2.entity);
   add_child($$.entity, $3.entity);

   ($$.entity)->value = ($1.entity)->value / ($3.entity)->value;
}
| factor {

   $$.entity = createEntity("\nterm", 0);

   add_child($$.entity, $1.entity);

   ($$.entity)->value = ($1.entity)->value;
}
;

factor: value {

   $$.entity = createEntity("\nfactor", 0);

   add_child($$.entity, $1.entity);

   ($$.entity)->value = ($1.entity)->value;
}
;

%%

struct Node * createEntity(char name[32], int val){
   struct Node *parent = (struct Node*)malloc(sizeof(struct Node));
   for(int i=0; i<32; i++){
      parent->label[i] = name[i];
   }
   parent->value = val;
   parent->num_children = 0;
   return parent;
}

void add_child(struct Node *parent, struct Node *child) {
   parent->children[parent->num_children] = child;
   parent->num_children++;
}

void st_traverse(struct Node *root){
   if(root == NULL)
      return;

   printf("\n");
   printf(root->label);
   printf(" %d", root->value);
   for(int i=0; i<root->num_children; i++){
      st_traverse(root->children[i]);
   }

   return;
}

int main() {
   printf("LEXICAL ANALYSIS\n");
   yyparse();
   printf("\n\nSYNTAX TREE PREORDER\n");
   printf("node value\n");
   st_traverse(root);
   printf("\n\nINTERMEDIATE CODE GENERATION\n\n");
	for(int i=0; i<ic_idx; i++){
		printf("%s", icg[i]);
	}
}

void yyerror(const char* msg) {
   fprintf(stderr, "%s\n", msg);
}