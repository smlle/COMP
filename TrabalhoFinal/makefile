all:
	flex tokens.l
	bison grammar.y
	cc -o expr expr.c grammar.tab.c
	@echo "Digite o nome do arquivo que deseja ler: ";\
	read nome;\
	clear;\
	./expr $$nome;	
	@rm -f grammar.tab.c
	@rm -f lex.yy.c	
	@rm -f expr.o
	@rm -f expr
	@mv entradaJasmin.j .jasmin/
	@cd .jasmin;\
	java -jar jasmin.jar entradaJasmin.j;\
	java entradaJasmin;
