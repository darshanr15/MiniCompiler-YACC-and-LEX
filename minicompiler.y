%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>

    void yyerror(char *s);
    int yylex(void);
    int yywrap();
    int flag=0;

    extern FILE *yyin;

    int labelCounter()
    {
        static int label=0;
        return label++;
    }

    int variableCounter()
    {
        static int variable=0;
        return variable++;
    }

    typedef struct Node {
        int intval;
        float fltval;
        char *code;
        char *tac;
        char *opttac;
        char *gen;
    } Node;

    int is_constant(char *name); 

    Node *makenode(){
        Node *n=(Node *)malloc(sizeof(Node));
        n->intval=0;
        n->fltval=0.0;
        n->code = (char *)malloc(sizeof(char)*1024);
        n->tac = (char *)malloc(sizeof(char)*1024);
        n->opttac = (char *)malloc(sizeof(char)*1024);
        n->gen = (char *)malloc(sizeof(char)*1024);
        return n;
    }

%}

%union{
    int intval;
    float fltval;
    char *str;
    struct Node *node;
}

%token <str> ID IF ELSE
%token <intval> INT
%token <fltval> FLOAT

%left '+''-'
%left '*' '/'

%token GT LT GE LE EQ NE
%token PLUS MINUS STAR DIV LPAREN RPAREN LBRACE RBRACE EQUAL
%nonassoc UMINUS

%type <node> Program Stmts Stmt Block Ifstmt Assign Condition Expr Term Factor

%%

Program : Stmts {
    printf("\n-----INPUT CODE-----\n");
    system("cat q.c");
    printf("\n-----SYNTAX CHECK-----\n");
    printf("Syntactically Correct");
    printf("\n-----TAC CODE-----\n");
    printf("\n%s\n",$1->tac);
    printf("\n-----OPT TAC CODE-----\n");
    printf("\n%s\n",$1->opttac);
    printf("\n-----MACHINE CODE-----\n");
    printf("\n%s\n",$1->gen);
};

Stmts : Stmt Stmts {
    $$ = makenode();
    sprintf($$->tac,"%s%s",$1->tac,$2->tac);
    sprintf($$->opttac,"%s%s",$1->opttac,$2->opttac);
    sprintf($$->gen,"%s%s",$1->gen,$2->gen);
}
| Stmt { $$ = $1; };

Stmt : Assign { $$ = $1; }
        | Ifstmt { $$ = $1; };

Block : LBRACE Stmts RBRACE { $$ = $2; };

Assign : ID EQUAL Expr {
    $$ = makenode();
    sprintf($$->code,"%s",$1);
    char temp[1024];
    sprintf(temp,"%s = %s\n",$$->code,$3->code);
    sprintf($$->tac,"%s%s",$3->tac,temp);
    sprintf($$->opttac,"%s%s",$3->opttac,temp);
    sprintf($$->gen,"\n%sMOV %s,R0\nMOV R0,%s\n",$3->gen,$3->code,$$->code);
};

Ifstmt : IF LPAREN Condition RPAREN Block ELSE Block {
    $$ = makenode();
    int l1 = labelCounter();
    int l2 = labelCounter();
    char temp[1024];
    sprintf(temp,"\n%sif not %s goto L%d\n%sgoto L%d\nL%d:\n%sL%d:\n",$3->tac,$3->code,l1,$5->tac,l2,l1,$7->tac,l2);
    sprintf($$->tac,"%s",temp);
    sprintf(temp,"\n%sif not %s goto L%d\n%sgoto L%d\nL%d:\n%sL%d:\n",$3->opttac,$3->code,l1,$5->opttac,l2,l1,$7->opttac,l2);
    sprintf($$->opttac,"%s",temp);
    sprintf($$->gen,"\n%sCMP %s,#0\nJZ L%d\n%sJMP L%d\nL%d:\n%sL%d:\n",$3->gen,$3->code,l1,$5->gen,l2,l1,$7->gen,l2);
}
| IF LPAREN Condition RPAREN Block {
    $$ = makenode();
    int l1 = labelCounter();
    char temp[1024];
    sprintf(temp,"\n%sif not %s goto L%d\n%sL%d:\n",$3->tac,$3->code,l1,$5->tac,l1);
    sprintf($$->tac,"%s",temp);
    sprintf(temp,"\n%sif not %s goto L%d\n%sL%d:\n",$3->opttac,$3->code,l1,$5->opttac,l1);
    sprintf($$->opttac,"%s",temp);
    sprintf($$->gen,"\n%sCMP %s,#0\nJZ L%d\n%sL%d:\n",$3->gen,$3->code,l1,$5->gen,l1);
};

Condition : Expr GT Expr {
    $$ = makenode ();
    int vc = variableCounter();
    sprintf($$->code,"T%d",vc);
    sprintf($$->tac,"\n %s%s%s = %s > %s \n",$1->tac,$3->tac,$$->code,$1->code,$3->code);
    sprintf($$->opttac,"\n %s%s%s = %s > %s \n",$1->opttac,$3->opttac,$$->code,$1->code,$3->code);
    sprintf($$->gen,"\n %s%sMov %s,R0\n CMP %s,R0 \n SGT %s\n",$1->gen,$3->gen,$1->code,$3->code,$$->code);
}
| Expr LT Expr {
    $$ = makenode ();
    int vc = variableCounter();
    sprintf($$->code,"T%d",vc);
    sprintf($$->tac,"\n %s%s%s = %s < %s \n",$1->tac,$3->tac,$$->code,$1->code,$3->code);
    sprintf($$->opttac,"\n %s%s%s = %s < %s \n",$1->opttac,$3->opttac,$$->code,$1->code,$3->code);
    sprintf($$->gen,"\n %s%sMov %s,R0\n CMP %s,R0 \n SLT %s\n",$1->gen,$3->gen,$1->code,$3->code,$$->code);
}
| Expr {
    $$ = makenode();
    sprintf($$->code,"%s",$1->code);
    sprintf($$->tac,"%s",$1->tac);
    sprintf($$->opttac,"%s",$1->opttac);
    sprintf($$->gen,"%s",$1->gen);
};

Expr : Expr PLUS Term {
    $$ = makenode();
    int vc = variableCounter();
    sprintf($$->code,"T%d",vc);
    char temp[1024];
    sprintf(temp,"\n%s = %s + %s\n",$$->code,$1->code,$3->code);
    sprintf($$->tac,"%s%s%s",$1->tac,$3->tac,temp);
    if(is_constant($1->code) && is_constant($3->code))
    {
        int cost = atoi($1->code) + atoi($3->code);
        char buffer[1024];
        sprintf(buffer,"\n%s = %d\n",$$->code,cost);
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,buffer);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nMov R0,%s\n",$1->gen,$3->gen,cost,$$->code);
    }
    else if(is_constant($1->code) &&  (atoi($1->code) == 0))
    {
        //int cost = atoi($1->code) + atoi($3->code);
        char buffer[1024];
        sprintf(buffer,"\n%s = %d\n",$$->code,$3->code);
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,buffer);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nMov R0,%s\n",$1->gen,$3->gen,$3->code,$$->code);
    }
    else if(is_constant($3->code) &&  (atoi($3->code) == 0))
    {
        //int cost = atoi($1->code) + atoi($3->code);
        char buffer[1024];
        sprintf(buffer,"\n%s = %d\n",$$->code,$1->code);
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,buffer);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nMov R0,%s\n",$1->gen,$3->gen,$1->code,$$->code);
    }
    else 
    {
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,temp);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nADD %s,R0\nMov R0,%s\n",$1->gen,$3->gen,$1->code,$3->code,$$->code);
    }
}
| Expr MINUS Term {
    $$ = makenode();
    int vc = variableCounter();
    sprintf($$->code,"T%d",vc);
    char temp[1024];
    sprintf(temp,"\n%s = %s - %s\n",$$->code,$1->code,$3->code);
    sprintf($$->tac,"%s%s%s",$1->tac,$3->tac,temp);
    if(is_constant($1->code) && is_constant($3->code))
    {
        int cost = atoi($1->code) - atoi($3->code);
        char buffer[1024];
        sprintf(buffer,"\n%s = %d\n",$$->code,cost);
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,buffer);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nMov R0,%s\n",$1->gen,$3->gen,cost,$$->code);
    }
    else if(is_constant($1->code) &&  (atoi($1->code) == 0))
    {
        //int cost = atoi($1->code) + atoi($3->code);
        char buffer[1024];
        sprintf(buffer,"\n%s = %d\n",$$->code,$3->code);
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,buffer);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nMov R0,%s\n",$1->gen,$3->gen,$3->code,$$->code);
    }
    else if(is_constant($3->code) &&  (atoi($3->code) == 0))
    {
        //int cost = atoi($1->code) + atoi($3->code);
        char buffer[1024];
        sprintf(buffer,"\n%s = %d\n",$$->code,$1->code);
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,buffer);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nMov R0,%s\n",$1->gen,$3->gen,$1->code,$$->code);
    }
    else 
    {
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,temp);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nSUB %s,R0\nMov R0,%s\n",$1->gen,$3->gen,$1->code,$3->code,$$->code);
    }
}
| Term { $$ = $1; };

Term : Term STAR Factor {
    $$ = makenode();
    int vc = variableCounter();
    sprintf($$->code,"T%d",vc);
    char temp[1024];
    sprintf(temp,"\n%s = %s * %s\n",$$->code,$1->code,$3->code);
    sprintf($$->tac,"%s%s%s",$1->tac,$3->tac,temp);
    if(is_constant($1->code) && is_constant($3->code))
    {
        int cost = atoi($1->code) * atoi($3->code);
        char buffer[1024];
        sprintf(buffer,"\n%s = %d\n",$$->code,cost);
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,buffer);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nMov R0,%s\n",$1->gen,$3->gen,cost,$$->code);
    }
    else if(is_constant($1->code) &&  (atoi($1->code) == 1))
    {
        //int cost = atoi($1->code) + atoi($3->code);
        char buffer[1024];
        sprintf(buffer,"\n%s = %d\n",$$->code,$3->code);
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,buffer);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nMov R0,%s\n",$1->gen,$3->gen,$3->code,$$->code);
    }
    else if(is_constant($3->code) &&  (atoi($3->code) == 1))
    {
        //int cost = atoi($1->code) + atoi($3->code);
        char buffer[1024];
        sprintf(buffer,"\n%s = %d\n",$$->code,$1->code);
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,buffer);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nMov R0,%s\n",$1->gen,$3->gen,$1->code,$$->code);
    }
	else if (is_constant($3->code)==1 && is_constant($1->code)==0)
    {
        char buffer[1024];
        sprintf(buffer, "%s = %s + %s\n", $$->code,$1->code,$1->code);
        sprintf($$->opttac, "%s%s%s", $1->opttac, $3->opttac, buffer);
        sprintf($$->gen, "%s%sMOV %s, R0\nMOV R0, %s\n", $1->gen, $3->gen, $1->code, $$->code);
    }
    else 
    {
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,temp);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nMUL %s,R0\nMov R0,%s\n",$1->gen,$3->gen,$1->code,$3->code,$$->code);
    }
}
| Term DIV Factor {
    $$ = makenode();
    int vc = variableCounter();
    sprintf($$->code,"T%d",vc);
    char temp[1024];
    sprintf(temp,"\n%s = %s / %s\n",$$->code,$1->code,$3->code);
    sprintf($$->tac,"%s%s%s",$1->tac,$3->tac,temp);
    if(is_constant($1->code) && is_constant($3->code))
    {
        int cost = atoi($1->code) / atoi($3->code);
        char buffer[1024];
        sprintf(buffer,"\n%s = %d\n",$$->code,cost);
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,buffer);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nMov R0,%s\n",$1->gen,$3->gen,cost,$$->code);
    }
    else if(is_constant($3->code) &&  (atoi($3->code) == 1))
    {
        //int cost = atoi($1->code) + atoi($3->code);
        char buffer[1024];
        sprintf(buffer,"\n%s = %d\n",$$->code,$1->code);
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,buffer);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nMov R0,%s\n",$1->gen,$3->gen,$1->code,$$->code);
    }
    else if(is_constant($3->code) &&  (atoi($3->code) == 0))
    {
        yyerror("Division By Zero\n");
    }
    else 
    {
        sprintf($$->opttac,"%s%s%s",$1->opttac,$3->opttac,temp);
        sprintf($$->gen,"\n%s%s Mov %s,R0\nDIV %s,R0\nMov R0,%s\n",$1->gen,$3->gen,$1->code,$3->code,$$->code);
    }
}
| Factor { $$ = $1; };

Factor : ID {
    $$ = makenode();
    sprintf($$->code,"%s",$1);
    $$->tac = "\0";
    $$->opttac = "";
    $$->gen = "";
}
| INT {
    $$ = makenode();
    sprintf($$->code,"%d",$1);
    $$->tac = "\0";
    $$->opttac = "";
    $$->gen = "";
}
| FLOAT {
    $$ = makenode();
    sprintf($$->code,"%.2f",$1);
    $$->tac = "\0";
    $$->opttac = "";
    $$->gen = "";
}
| LPAREN Expr RPAREN { $$ = $2; };

%%

int is_constant(char *name){
    int i=0;
    for(i=0; name[i] != '\0'; i++){
        if(name[i] < '0' || name[i] > '9')
        return 0;
    }
    return 1;
}

void yyerror(char *s){
    printf("Error : %s\n",s);
    flag = 1;
}

int yywrap(){
    return 1;
}

int main(void){
    FILE *file = fopen("q.c","r");
    if(!file){
        printf("Error opening file\n");
        return -1;
    }
    yyin = file;
    
    printf("\n-----LEXICAL ANALYSER-----\n");
    yyparse();

    if(flag == 1){
        printf("Syntactically Wrong\n");
    }

    fclose(file);
    return 0;
}