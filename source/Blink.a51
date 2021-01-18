setup:
	cpl 	p1.0        ;A instru�ao cpl inverte o nivel logico do pino e consequentemente tambem altera o estado do led (respos�vel por mudar o nivel logico do led
	mov 	r0,#10      ;Quantidade de vezes (10 vezes) em que o await50ms sera chamado (10 x 50 ms = 0.5 segundos)
	
main:
	call 	await50ms        ;Chamando rotina await50ms responsavel pelo delay.
	djnz 	r0,main          ;Decrementa o valor de r0 at� zero, caso n�o seja zero invoca a rotina main.
	jmp 	setup            ;Retorna  ao setup principal.

await50ms:

	CLR		TF1             ;Limpa o Flag de overflow do timer 1. O Flag de overflow n�o reseta automaticamente.
	MOV 	TMOD,#10H       ;Configura o timer 1 em modo de 16-bits.
	MOV 	TH1, #3CH       ;Atribui 15536 (3CB0H) nos registradores.
	MOV 	TL1, #0B0H      ;TH1 recebe o Byte mais siginificativo(3C) e TL1 recebe o byte menos significativo(B0).
	SETB 	TR1             ;Inicia a contagem do timer 1 .O timer inicia a contagem do valor que est� nele at� 65.536, como setamos 15.536 no timer ser�o contados 50.000 us (50 ms).
	JNB 	TF1, $          ;Espera que o flag de overflow seja enviado.
	Ret	                    ;Retorna onde a rotina foi chamada.
