[![N|Solid](https://eventos.ifg.edu.br/semanai2c/wp-content/uploads/sites/7/2016/08/marca-ifg-2015-todas-as-verses.png)](https://www.ifg.edu.br/goiania)

# Programa: Blink (8051)

Esse código é um exemplo de Led Blink (piscar led) desenvolvido por discentes do IFG para o microcontrolador 8051, este codigo em especifico pisca o led a cada 0.5 segundos se utilizado um cristal de 12 Mhz.

## Execuçao:

### Simulador:
Clone o repositorio
baixe e instale o java
abra o edsim51.jar
carregue o arquivo blink.asm atravez da guia load
execute a simulaçao

### Microcontrolador:
Grave o arquivo Blink.hex em um 8051 

## Codigo:
```
setup:
	cpl 	p1.0        ;A instruçao cpl inverte o nivel logico do pino e consequentemente tambem altera o estado do led (resposável por mudar o nivel logico do led
	mov 	r0,#10      ;Quantidade de vezes (10 vezes) em que o await50ms sera chamado (10 x 50 ms = 0.5 segundos)
	
main:
	call 	await50ms        ;Chamando rotina await50ms responsavel pelo delay.
	djnz 	r0,main          ;Decrementa o valor de r0 até zero, caso não seja zero invoca a rotina main.
	jmp 	setup            ;Retorna  ao setup principal.

await50ms:

	CLR		TF1             ;Limpa o Flag de overflow do timer 1. O Flag de overflow não reseta automaticamente.
	MOV 	TMOD,#10H       ;Configura o timer 1 em modo de 16-bits.
	MOV 	TH1, #3CH       ;Atribui 15536 (3CB0H) nos registradores.
	MOV 	TL1, #0B0H      ;TH1 recebe o Byte mais siginificativo(3C) e TL1 recebe o byte menos significativo(B0).
	SETB 	TR1             ;Inicia a contagem do timer 1 .O timer inicia a contagem do valor que está nele até 65.536, como setamos 15.536 no timer serão contados 50.000 us (50 ms).
	JNB 	TF1, $          ;Espera que o flag de overflow seja enviado.
	Ret	                    ;Retorna onde a rotina foi chamada.
```

## Operação do codigo:
### Delay
Ao execultar o blink com um delay de 0.5 segundos no 8051 é necessario ralizar um delay de 50ms 10 vezes consecultivas (10*50ms=50ms). Isso se dá em razão que o 8051 é um microcontrolador de 8 bits, e o maior binario o qual podemos representar é 256(2^8) enquanto em um registrador de 16 bits podemos representar 65.536 (2^16). Como em cada numero é calculado em 1us em um registrador de 8 bits é possiver um delay de 256 us, equanto em um registrador de 16 bits é possivel um delay de 65.536us usando.

Para finalizar o delay usa-se a instrução JNB para analizar quando o timer atinge seu valor máximo (65.536) pois neste instante o flag do timer recebe True (nivel lógico alto "1").

A cada 10 execuçoes do delay de 50ms invertemos o nivel logico do p1.0 em que está o led atravez do comando cpl

### Modo de operação 16 bits

Tambem é necessario colocar o timer no modo de 16-bits. Pois quando o timer está no modo de 16-bits unimos os registradores TH e TL (Timer hight e Timer low), os ultimos 8 bits mais significativos ficam em TH enquanto o os 8 bits menos significativos ficam em TL.

Exemplo: Ao colocar 15.536 (3CB0 em hexadecimal) no registrador do timer no modo 16-bits, é necessario dividir o número entre o TH e o TL, ficando:
|  Reg | Hex |
| ------ | ------ |
| TH | 3C |
| TL | B0 |


Para configurar o timer no modo 16 bits é necessario configurar de acordo com as tabela abaixo:

#### Registrador TMOD:
##### 8-BIT-MODE:
 #
| Timer | Binario | Hexadecimal | Decimal |
| ------ | ------ | ------ | ------ |
|    Timer 1    | MOV TMOD,#10000000B | MOV TMOD,#01H |  MOV TMOD,#1  |
|    Timer 0    | MOV TMDO,#01000000B | MOV TMOD,#02H |  MOV TMOD,#2  |
##### 16-BIT-MODE:
 #
| Timer | Binario | Hexadecimal | Decimal |
| ------ | ------ | ------ | ------ |
|    Timer 1    | MOV TMOD,#00001000B | MOV TMOD,#10H |  MOV TMOD,#16  |
|    Timer 0    | MOV TMDO,#00000100B | MOV TMOD,#40H |  MOV TMOD,#32  |


###### Mode 2- 8-bit auto-reload mode:
- Nesse modo, o byte menos siginificativo do timer (TLx) opera como um timer de 8 bits, enquanto o byte superior guarda o valor de reload. Quando o timer passar de 2^8 (256), ao invés de começar em 0 novamente o TLx vai receber o valor de THx e começar a contagem novamente, ou seja, se THx = 0 o timer vai começar a contar do zero até chegar em 256, porém se THx = 50 o timer vai começar a contar de 50 até chegar em 256.

###### Mode 1 - 16-bit mode:
- Nesse modo, o byte mais significativo (THx) está em cascata com o menos significativo (TLx), ou seja, o THx e o TLx estão juntos nesse modo, formando um timer de 16 bits, logo nesse modo, podemos contar até 2^16 (65536). O overflow (sinal que mostra que a memória estorou o limite) ocorre durante a transição de FFFFH (65536 em decimal) para 0H (0 decimal).

####  Registrador TCON

| BIT | ENDEREÇO |DESCRIÇÃO|
| ------ | ------ | ------ |
| TF1 |8FH   | Flag de over flow. Quando a memória do timer 1 estourar este bit é igual a 1 (TF1=1) |
| TR1 |    8EH   |    Bit de controle do timer 1. TR1 = 1 inicia a contagem e TR1 = 0 para a contagem   |
| TF0 |    8DH   | Flag de over flow. Quando a memória do timer 0 estourar este bit é igual a 1 (TF1=1) |
| TR0 |    8CH   |    Bit de controle do timer 0. TR1 = 1 inicia a contagem e TR1 = 0 para a contagem   |
### Contagem

O timer começa contar do valor que inicial até o seu valor máximo, como estamos no modo de 16 bits o timer ira contar de 0 até 65.536us ( de 0 até 65,536 ms). Como desejamos que o timer conte 50ms movemos 15.536 para o timer iniciando assim a contagem em 15,5ms removendo o tempo excedente.

## Tempo de execução:
De acordo com o simulador edsim51, um loop do programa se utilizado um cristal de 12Mhz temos os seguintes resultados de execuçao:
| Loop | S|Ms|Us |Instruções executadas|
| ------ | ------ | ------ | ------ | ------ |
| 1 | 000  |000 | 142 | 250 082 instruções|
| 2 |  001  |000 | 288 | 500 165 instruções|
| 3 |  001  |500 | 430 | 750 248 instruções|
| 4 |  002  |000 | 574 | 1 000 331  instruções|
| 5 |  002  |500 | 718 | 1 250 410 instruções|
| 6|  003  |000 | 862 | 1 500 497 instruções|
| 7 |  003  |501 | 006 | 1 750 580 instruções|
| 8 |  004  |001 | 150 | 2 000 663 instruções|
|9 |  004  |501 | 294 | 2 250 740 instruções|
| 10 |  005  |001 | 438 | 2 500 829 instruções|


Os dados da tabela acima podem ser conferidos na simulação apresentada no gif abaixo

![](https://github.com/LucasRangelSSouza/blink8051/blob/main/gifs/8051test.gif)

 
 
 No geral sao executadas 2 500 829 instruções em 5 segundos 1 milissegundo e 438 microssegundos em 10 loops do programa, o que nos da uma media de 500 milisegundos e 143 microssegundos por loop e 1.99 microssegundos por instrução.
 Observe que estes resultados sao obtidos utilizando um cristal oscilador de 12Mhz.




----
### Licença
MIT
**Free Software, Hell Yeah!**

