%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "EDA.h"
#define YYSTYPE struct dados // AQUI TEM QUE SER STRUCT 

#define ICONST_0    10
#define ICONST_1    11
#define ICONST_2    12
#define ICONST_3    13
#define ICONST_4    14
#define ICONST_5    15

#define ILOAD       16
#define ISTORE      17
#define IADD        18
#define IMULL       19
#define BIPUSH	    20
#define LDC         21

#define IDIV        22
#define ISUB        23

#define INVOKE_INT  30
#define INVOKE_STG  31

#define PRINT       40

#define IF	    50

#define DIFERENTE   80
#define IGUAL       81
#define MAIOR_IGUAL 82
#define MENOR_IGUAL 83
#define MAIOR       84
#define MENOR       85

#define LABEL       90
#define GOTO	    98

%}

%token TVOID TINT TSTRING TRETURN TIF TELSE TWHILE TPRINT TREAD TID TADD TSUB TMUL TDIV TAPAR TFPAR TPONTOEVIRGULA TVIRGULA TACHA TFCHA TCOMPARACAOIGUAL TMENORIGUAL TMAIORIGUAL TMENOR TMAIOR TDIFERENTE TAND TOR TNOT TIGUAL TLITERAL TNUM

%%

Principal: 	Programa {mostra_tabela();cria_jasmin();}
		;

Programa:	ListaFuncoes BlocoPrincipal
		| BlocoPrincipal
		;
ListaFuncoes:	ListaFuncoes Funcao
		| Funcao
		;
Funcao:		TipoRetorno TID TAPAR DeclParametros TFPAR BlocoPrincipal
		| TipoRetorno TID TAPAR TFPAR BlocoPrincipal
		;
TipoRetorno: 	Tipo
		| TVOID
		;
DeclParametros:	DeclParametros TVIRGULA Parametro
		| Parametro
		;
Parametro:	Tipo TID {insere_lista(yylval.id);}
		;
BlocoPrincipal:	TACHA Declaracoes ListaCmd TFCHA
		| TACHA ListaCmd TFCHA
		;
Declaracoes:	Declaracoes Declaracao
		| Declaracao
		;
Declaracao:	Tipo ListaId TPONTOEVIRGULA {tabela_dados(list_principal,dados_principal);}
		;
Tipo:		TINT{insere_dados(strcpy(yylval.tipo,"int"));}
		| TSTRING{insere_dados(strcpy(yylval.tipo,"String"));}
		;
ListaId:	ListaId TVIRGULA TID{insere_lista(yylval.id);}
		| TID {insere_lista(yylval.id);}
		;
Bloco:		TACHA ListaCmd TFCHA {gerar(LABEL,-1,-1,"\0");}
		;
ListaCmd:	ListaCmd Comando
		| Comando
		;
Comando:	CmdSe
		| CmdEnquanto
		| CmdAtrib
		| CmdEscrita
		| CmdLeitura
		| ChamadaFuncao
		| Retorno
		;
Retorno:	TRETURN ExpressaoAritimetica TPONTOEVIRGULA {gerar(ISTORE,procura_tabela(yylval.id),-1,"\0");}  //coloca na variavel que está na lista de constantes
		;
CmdSe:		TIF TAPAR ExpressaoLogica TFPAR Bloco 
		| TIF TAPAR ExpressaoLogica TFPAR Bloco TELSE Bloco 
		;
CmdEnquanto:	TWHILE TAPAR ExpressaoLogica TFPAR Bloco
		;
CmdAtrib:	TID TIGUAL ExpressaoAritimetica TPONTOEVIRGULA {gerar(ISTORE,procura_tabela($$.id),-1,"\0");}  //coloca na variavel que esta na lista de constantes o resultado aritmetico
		| TID TIGUAL TLITERAL TPONTOEVIRGULA{gerar(BIPUSH,-1,-2,$3.str);gerar(ISTORE,procura_tabela($$.id),-1,$3.str);} 
		;
CmdEscrita:	TPRINT TAPAR ExpressaoAritimetica TFPAR TPONTOEVIRGULA {gerar(INVOKE_INT,procura_tabela(yylval.id),-1,$3.str);} //retira da pilha normal e coloca na variavel que está na posição id.posLexval
		| TPRINT TAPAR TLITERAL TFPAR TPONTOEVIRGULA {gerar(INVOKE_STG,procura_tabela(yylval.id),-1,$3.str);}
		;
CmdLeitura:	TREAD TAPAR TID TFPAR TPONTOEVIRGULA
		;
ChamadaFuncao:	TID TAPAR ListaParametros TFPAR //TPONTOEVIRGULA
		| TID TAPAR TFPAR //TPONTOEVIRGULA
		;
ListaParametros: ListaParametros TVIRGULA ExpressaoAritimetica
		| ExpressaoAritimetica
		;

ExpressaoAritimetica: ExpressaoAritimetica TADD Termo {gerar(IADD,-1,-1,"\0");}  //desempilha os 2 do topo da pilha e armazena a soma
		 	| ExpressaoAritimetica TSUB Termo {gerar(ISUB,-1,-1,"\0");}    //mesma coisa só que para substração
			| Termo
			;
Termo:		Termo TMUL Fator  {gerar(IMULL,-1,-1,"\0");}
		| Termo TDIV Fator {gerar(IDIV,-1,-1,"\0");}
		| Fator
		;
Fator:		TAPAR ExpressaoAritimetica TFPAR
		| TSUB Fator 
		| TID    {gerar(ILOAD,procura_tabela(yylval.id),-1,"\0");}  // id.posLexval -> posição do ID dentro da tabela de simbolos
		| TNUM   {gerar(BIPUSH,yylval.constante,-1,"\0");}  //pode ser tanto bipush como ldc e iconst // const.posLexval é a constante que vai ser armazenada no topo pilha
		| ChamadaFuncao
		;


ExpressaoRelacional:	ExpressaoAritimetica Op ExpRelacionalB {strcpy($$.str,$2.str);}
			;

ExpRelacionalB: 	ExpressaoAritimetica
			;
Op:		TDIFERENTE {strcpy($$.str,"ne");}
		| TCOMPARACAOIGUAL {strcpy($$.str,"eq");}
		| TMAIORIGUAL {strcpy($$.str,"ge");}
		| TMENORIGUAL {strcpy($$.str,"le");}
		| TMAIOR {strcpy($$.str,"gt");}
		| TMENOR {strcpy($$.str,"lt");}
		;
ExpressaoLogica:	ExpressaoLogica TAND TermoLogico
			| ExpressaoLogica TOR TermoLogico
			| TermoLogico {gerar(IF,-1,-1,$1.str);gerar(GOTO,-1,-1,"\0");gerar(LABEL,-1,-1,"\0");}
			;
TermoLogico:	TAPAR ExpressaoLogica TFPAR
		| TNOT TermoLogico
		| ExpressaoRelacional {strcpy($$.str,$1.str);}
		;

%%
#include "lex.yy.c"

int yyerror (char *str)
{
	printf("%s - antes %s\n", str, yytext);
	
} 		 

int yywrap()
{
	return 1;
}
