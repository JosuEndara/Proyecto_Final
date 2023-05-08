#ASIGNACION DE MEMORIA

.data
Bufferbitmap: .space 0x80000            # RESERVA BYTES PARA LA DISPLAY DEL BITMAP
speedx:       .word	0		# VELOCIDAD DE INICIO PARA X
speedy:       .word	0		# VELOCIDAD DE INICIO PARA Y
posx:         .word	50		# POSICION X SERPIENTE
posy:         .word	27		# POSICION Y SERPIENTE
tail:         .word	7624		# POSICION INICIAL DE LA COLA DE LA SERPIENTE
applex:	      .word	32		# POSICION X MANZANA
appley:       .word	16		# POSICION Y MANZANA
snakeUp:      .word	0x00007F00	# PIXEL DIBUJA CUANDO LA SERPIETE VA PARA ARRIBA
snakeDown:    .word	0x01007F00	# PIXEL DIBUJA CUANDO LA SERPIETE VA PARA ABAJO
snakeLeft:    .word	0x02007F00	# PIXEL DIBUJA CUANDO LA SERPIETE VA PARA IZQUIERDA
snakeRight:   .word	0x03007F00	# PIXEL DIBUJA CUANDO LA SERPIETE VA PARA DERECHA
convertFactX: .word	64		# CONVERSOR PARA DISPLAY EN BITMAP
convertFactY: .word	4		# CONVERSOR PARA DISPLAY EN BITMAP
SkyColor:     .word     0xBBBBFFFF	
RedColor:     .word     0x00ff0000
BlueColor:    .word     0x000000FF
appleMsg:     .asciiz   "\nManzanas comidas: "
appleCount:   .word     0
newline:      .asciiz   "\n"
finDelJuego:  .asciiz   "\n¡Fin del juego! Gracias por jugar.\n"

.macro DisplayScenario
la 	$t0, Bufferbitmap	# SE CARGA LA DIRECCION INICIAL DEL BITMAP
	li 	$t1, 0x20000	# DECLARA UN ESPACIO SUFICIENTE PARA 512*256 pixels
	lw 	$t2, SkyColor	# CARGA PIXEL COLOR VERDE
loop1:				#INGRESO LOOP
	sw   	$t2, 0($t0)	#ALMACENA VALOR DE MEMORIA DE $t0 EN $t2, direccion inicial bitmap,pinta
	addi 	$t0, $t0, 4 	# AVANZA SIGUIENTE POSICION DEL PIXEL EN DISPLAY
	addi 	$t1, $t1, -1	# SE DECREMENTA UNA POSICION DEL VALOR RESERVADO PARA EL BITMAP
	bnez 	$t1, loop1	# SE REPITE EL LOOP HASTA CUANDO EL NUMERO DE PIXELES SEA 0
.end_macro 

.macro DrawBorder(%x)
loop2:
	sw   	$t2, 0($t0)	#ALMACENA VALOR DE MEMORIA DE $t0 EN $t2, direccion inicial bitmap,pinta
	addi 	$t0, $t0, %x 	# AVANZA SIGUIENTE POSICION DEL PIXEL EN DISPLAY
	addi 	$t1, $t1, -1	# SE DECREMENTA UNA POSICION DEL VALOR RESERVADO PARA EL BITMAP
	bnez 	$t1, loop2	# SE REPITE EL LOOP HASTA CUANDO EL NUMERO DE PIXELES SEA 0

.end_macro


.macro TheAppleCount   
    li      $v0,    4                  
    la      $a0,    appleMsg
    syscall 
.end_macro 


.macro moveSnake
	add	$a0, $s3, $zero	
	jal	updateSnake	# SALTO HASTA LA SIGUIENTE SUBSECCION DE updateSnake
	jal 	updateHead 	# SALTO HASTA LA SIGUIENTE SUBSECCION para mover a la serpiente
	j	justExit 	# SALTO HACIA justExit que ejecuta denuevo gameUpdateLoop
.end_macro

.macro speed (%x,%y)
	addi	$t5, $zero, %x		# SETEO VELOCIDAD X
	addi	$t6, $zero, %y		# SETEO VELOCIDAD Y
	sw	$t5, speedx		# SE GUARDA EN LA SPEEDX EL VALOR CORRESPONDIENTE A ESA VELOCIDAD
	sw	$t6, speedy		# SE GUARDA EN LA SPEEDY EL VALOR CORRESPONDIENTE A ESA VELOCIDAD
	j exitSpeed
.end_macro 
	
	
.macro newTail(%x)
	addi	$t0, $t0, %x		# ACTUALIZACION DE COLA SEGUN EL EJE
	sw	$t0, tail		# GUARDA O CARGA NUEVO VALOR DE COLA
	j exitUpdateSnake
.end_macro
.text
	#DIBUJO DE BITMAP DISPLAY
	DisplayScenario
	
	#DIBUJO DE BORDES DEL BITMAP
	# SECCION BORDE SUPERIOR
	la	$t0, Bufferbitmap	# SE CARGA LA DIRECCION INICIAL DEL BITMAP DENUEVO
	addi	$t1,$zero, 64		# REG DE t1 = 64 
	lw 	$t2, BlueColor		# CARGA PIXEL COLOR AZUL
	DrawBorder(4)
	
	# SECCION BORDE INFERIOR
	la	$t0, Bufferbitmap	# SE CARGA LA DIRECCION INICIAL DEL BITMAP DENUEVO
	addi	$t0, $t0, 7936		# SETEA PIXEL ABAJO IZQUIERDA
	addi	$t1, $zero, 64		# REG DE t1 = 64 	
	DrawBorder(4)
	
	# SECCION BORDE IZQUIERDO
	la	$t0, Bufferbitmap	# SE CARGA LA DIRECCION INICIAL DEL BITMAP DENUEVO
	addi	$t1, $zero, 256		# REG DE t1 = 256 COLUMNA 
	DrawBorder(256)
	
	# SECCION BORDE DERECHO
	la	$t0, Bufferbitmap	# SE CARGA LA DIRECCION INICIAL DEL BITMAP DENUEVO
	addi	$t0, $t0, 508		# PIXEL INICIADOR ARRIBA DERECHA
	addi	$t1, $zero, 255		#REG DE t1 = 255 COLUMNA 
	DrawBorder(256)

	#SERPIENTE SECCION
	la	$t0, Bufferbitmap	# SE CARGA LA DIRECCION INICIAL DEL BITMAP DENUEVO
	lw	$s2, tail		# s2 = COLA SERPIENTE
	lw	$s3, snakeUp		# s3 = DIRECCION(INICIAL HACIA ARRIBA)
	
	#DIBUJO SERPIENTE
	add	$t1, $s2, $t0		# t1 = COLA EMPIEZA EN EL BITMAP
	sw	$s3, 0($t1)		# DIBUJA EL PIXEL DONDE SE ENCUENTRA LA SERPIENTE
	addi	$t1, $t1, -256		# SETEAMOS A $t1 UN PIXEL POR ENCIMA POR SNAKEUP
	sw	$s3, 0($t1)		# DIBUJO PIXEL DE DONDE SE ENCUENTRA ACTUALMENTE LA SERPIENTE
	
	#DIBUJO PRIMERA MANZANA
	jal 	drawApple		#SALTO HASTA LA SIGUIENTE SUBSECCION DE DRAWAPPLE

gameUpdateLoop:
	lw	$t3, 0xffff0004		# EN MIPS 0xffff0004 SE UTILIZA PARA OBTENER LA TECLA PRESIONADA, EN ESTE CASO GUARDAMOS ESTE VALOR EN REG $t3
	
	### Sleep for 66 ms so frame rate is about 15
	addi	$v0, $zero, 32	# syscall sleep
	addi	$a0, $zero, 66	# 66 ms
	syscall
	
	beq	$t3, 100, moveRight	# SI $t3 es igual "d" SE BIFURCA O CAMBIA A LA SUBSECCION moveRight
	beq	$t3, 97, moveLeft	# SI $t3 es igual "a" SE BIFURCA O CAMBIA A LA SUBSECCION moveLeft
	beq	$t3, 119, moveUp	# SI $t3 es igual "w" SE BIFURCA O CAMBIA A LA SUBSECCION moveUP
	beq	$t3, 115, moveDown	# SI $t3 es igual "w" SE BIFURCA O CAMBIA A LA SUBSECCION moveDOWN
	beq	$t3, 0, moveUp		# CUANDO INICIA NO HA TECLA PRESIONADA POR LO TANTO AUTOMATICAMENTE SE MOVERA HACIA ARRIBA

moveUp:
	lw	$s3, snakeUp	# REG $s3 CONTENDRA O GUARDARA LA DIRECCION DE LA SERPIENTE
	moveSnake
	
moveDown:
	lw	$s3, snakeDown	# REG $s3 CONTENDRA O GUARDARA LA DIRECCION DE LA SERPIENTE
	moveSnake

moveLeft:
	lw	$s3, snakeLeft	# # REG $s3 CONTENDRA O GUARDARA LA DIRECCION DE LA SERPIENTE
	moveSnake
	
moveRight:
	lw	$s3, snakeRight	# s3 = direction of snake
	moveSnake

justExit:
	j 	gameUpdateLoop		

updateSnake:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer
	
	lw	$t0, posx		# DIBUJO CABEZA DE LA SERPIENTE, SE REGISTRA LAS POSICIONES DE LA SERPIENTE, TANTO X COMO Y
	lw	$t1, posy		
	lw	$t2, convertFactX	# SE ASIGNA LOS VALORES PARA LO CONVERSION DE LOS VALORES DE POSICION A DISPLAY EN BITMAP
	mult	$t1, $t2		# POSY * 64
	mflo	$t3			# t3 = POSY * 64, SE MUEVE EL RESULTADO DE MULTIPLICACION HACIA REG $t3
	add	$t3, $t3, $t0		# t3 = POSY * 64 + POSX
	lw	$t2, convertFactY	# t2 = 4
	mult	$t3, $t2		# (POSY * 64 + POSX) * 4
	mflo	$t0			# t0, CONTENDRA EL RESULTADO DE LA MULTIPLICACION ANTERIOR
	
	la 	$t1, Bufferbitmap	# CARGA DIRECCION DEL BITMAP
	add	$t0, $t1, $t0		# SE SUMA (POSICIONA) EL VALOR DE LA POSICION A PONER EN EL BITMAP
	lw	$t4, 0($t0)		# REGISTRO DEL VALOR ORIGINAL DEL PIXEL A PINTAR
	sw	$a0, 0($t0)		# GUARDA EL VALOR, PINTA
	
	lw	$t2, snakeUp			# SE CARGA EL VALOR ASIGNADO 
	beq	$a0, $t2, setSpeedUp		#SI DIRECCION DE LA CABEZA Y EL COLOR A PINTAR SON IGUAL EJECUTA SUBSECCION DE VELOCIDAD CORRESPONDIENTE PARA QUE CAMINE LA SERPIENTE
	
	lw	$t2, snakeDown			# SE CARGA EL VALOR ASIGNADO
	beq	$a0, $t2, setSpeedDown	#SI DIRECCION DE LA CABEZA Y EL COLOR A PINTAR SON IGUAL EJECUTA SUBSECCION DE VELOCIDAD CORRESPONDIENTE PARA QUE CAMINE LA SERPIENTE
	
	lw	$t2, snakeLeft			# SE CARGA EL VALOR ASIGNADO
	beq	$a0, $t2, setSpeedLeft	#SI DIRECCION DE LA CABEZA Y EL COLOR A PINTAR SON IGUAL EJECUTA SUBSECCION DE VELOCIDAD CORRESPONDIENTE PARA QUE CAMINE LA SERPIENTE
	
	lw	$t2, snakeRight			# SE CARGA EL VALOR ASIGNADO
	beq	$a0, $t2, setSpeedRight	#SI DIRECCION DE LA CABEZA Y EL COLOR A PINTAR SON IGUAL EJECUTA SUBSECCION DE VELOCIDAD CORRESPONDIENTE PARA QUE CAMINE LA SERPIENTE
	
setSpeedUp:
	speed(0, -1) 
	
setSpeedDown:
	speed(0, 1) 
	
setSpeedLeft:
	speed(-1, 0)
	
setSpeedRight:
	speed(1, 0)
	
exitSpeed:
	
	lw 	$t2, RedColor	        # CARGO COLOR de manzana
	bne	$t2, $t4, headNotApple	# SI NO SON IGUALES, PIXEL COLOR ORIGINAL GUARDADO ANTERIORMENTE Y COLOR DE MANZANA, SE EJECUTA SUBSECCION HEADNOTAPPLE
	
	jal 	newLocApple
	jal     eatAppleSound
	
	jal	drawApple	        #SALTO DIBUJO NUEVA MANZANA 
	TheAppleCount 
	lw      $t7, appleCount
   	addi    $t7, $t7, 1
   	sw      $t7,appleCount
   	li      $v0, 1
   	lw      $a0, appleCount
   	syscall
    
	j	exitUpdateSnake
	
headNotApple:
	lw	$t2, SkyColor		# CARGA COLOR VERDE
	beq	$t2, $t4, HeadValidation	
	jal     gameOverSound
	# Mostrar mensaje por consola
	la	$a0, finDelJuego	# Cargar direccion de la cadena de caracteres
	li	$v0, 4			# Codigo de la llamada del sistema para imprimir una cadena de caracteres
	syscall				# Imprimir el mensaje por consola
	j	ExitProgram		# Salir del programa

HeadValidation:
	lw	$t0, tail		# t0 = tail
	la 	$t1, Bufferbitmap	# CARGA DIRECCION DE BITMAP
	add	$t2, $t0, $t1		# SE OBTIENE POSICION DE LA COLA EN BITMAP
	lw 	$t3, SkyColor	        # CARGA COLOR VERDE
	lw	$t4, 0($t2)		# CARGA COLOR Y DIRECCION COLA
	sw	$t3, 0($t2)		# SE REEMPLAZA COLOR DE COLA CON COLOR DE BACKGROUND
	
	lw	$t5, snakeUp		# SE CARGA EL VALOR ASIGNADO 
	beq	$t5, $t4, NewTailUp	#SI DIRECCION DE LA COLA Y EL COLOR A PINTAR SON IGUAL EJECUTA SUBSECCION DE ACTUALIZACION DE COLA CORRESPONDIENTE PARA QUE CAMINE LA SERPIENTE
	
	lw	$t5, snakeDown		# SE CARGA EL VALOR ASIGNADO 
	beq	$t5, $t4, NewTailDown	#SI DIRECCION DE LA COLA Y EL COLOR A PINTAR SON IGUAL EJECUTA SUBSECCION DE ACTUALIZACION DE COLA  CORRESPONDIENTE PARA QUE CAMINE LA SERPIENTE
	
	lw	$t5, snakeLeft		# SE CARGA EL VALOR ASIGNADO 
	beq	$t5, $t4, NewTailLeft	#SI DIRECCION DE LA COLA Y EL COLOR A PINTAR SON IGUAL EJECUTA SUBSECCION DE ACTUALIZACION DE COLA CORRESPONDIENTE PARA QUE CAMINE LA SERPIENTE
	
	lw	$t5, snakeRight		# SE CARGA EL VALOR ASIGNADO 
	beq	$t5, $t4, NewTailRight	#SI DIRECCION DE LA COLA Y EL COLOR A PINTAR SON IGUAL EJECUTA SUBSECCION DE ACTUALIZACION DE COLA  CORRESPONDIENTE PARA QUE CAMINE LA SERPIENTE
	
NewTailUp:
	newTail(-256)
	
NewTailDown:
	newTail(256)
	
NewTailLeft:
	newTail(-4)
	
NewTailRight:
	newTail(4)
	
exitUpdateSnake:
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code
	
updateHead:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer	
	
	lw	$t3, speedx	# CARGA VALORES DE MEMORIA
	lw	$t4, speedy	
	lw	$t5, posx	
	lw	$t6, posy	
	add	$t5, $t5, $t3	# SE ACTUALIZA POSICIONES
	add	$t6, $t6, $t4	
	sw	$t5, posx	# SE GUARDAN LOS VALORES ACTUALIZADOS
	sw	$t6, posy	# SE GUARDAN LOS VALORES ACTUALIZADOS
	
	jal exitUpdateSnake	

drawApple:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer
	
	lw	$t0, applex		# CARGA POSICION DE MANZANA
	lw	$t1, appley		# CARGA POSICION DE MANZANA
	lw	$t2, convertFactX	# CARGA CONVERSION A BITMAP EN X
	mult	$t1, $t2		# CONVERSION
	mflo	$t3			# t3 = appley * 64 CONVERSION
	add	$t3, $t3, $t0		# t3 = appley * 64 + applex CONVERSION
	lw	$t2, convertFactY	# CARGA CONVERSION A BITMAP EN Y
	mult	$t3, $t2		# (yPos * 64 + applex) * 4
	mflo	$t0			# t0 = (appley * 64 + applex) * 4 SE OBTIENE DIRECCION A DIBUJAR
	
	la 	$t1, Bufferbitmap	# CARGA DIRECCION DE BITMAP
	add	$t0, $t1, $t0		# SE POSICIONA LA DIRECCION A OBTENIDA EN EL BITMAP
	li	$t4, 0x00ff0000		#CARGA COLOR ROJO
	sw	$t4, 0($t0)		# SE GUARDA LA DIRECCION DE ESTO
	
	jal exitUpdateSnake	

newLocApple:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer

locRandom:		
	addi	$v0, $zero, 42	# NUMERO ALEATORIO
	addi	$a1, $zero, 63	# limite
	syscall
	add	$t1, $zero, $a0	# NUMERO ALEATORIO PARA POSICION X
	
	addi	$v0, $zero, 42	# NUMERO ALEATORIO
	addi	$a1, $zero, 31	# limite
	syscall
	add	$t2, $zero, $a0	# NUMERO ALEATORIO PARA POSICION Y
	
	lw	$t3, convertFactX	# t3 = 64, CARGA VALOR DE CONVERSION
	mult	$t2, $t3		# CONVERSION NUM ALEATORIO Y
	mflo	$t4			# ASIGNA DIRECCION
	add	$t4, $t4, $t1		# SUMA NUM ALEATORIO X
	lw	$t3, convertFactY	# CARGA VALOR DE CONVERSION
	mult	$t3, $t4		# CALCULO NUEVA DIRECCION ALEATORIA
	mflo	$t4			# ASGINA DIRECCION
	
	la 	$t0, Bufferbitmap	# CARGA DIRECCION BITMAP
	add	$t0, $t4, $t0		# POSICIONA POSICION ALEATORIA EN BITMPA
	lw	$t5, 0($t0)		# GUARDA POSICION ORIGINAL
	
	lw	$t6,  SkyColor		# CARGA COLOR VERDE
	beq	$t5, $t6, Apple	#SALTO POSICION PARA NUEVA MANZANA
	j locRandom

Apple:
	sw	$t1, applex
	sw	$t2, appley	

	jal exitUpdateSnake

eatAppleSound:
    li $v0, 31      	# Carga la llamada del sistema para el sonido
    li $a0, 72     	# Establecer el tipo de sonido 
    li $a1, 1000    	# Establecer la duracion del sonido (en milisegundos)
    li $a2, 12     	# Establecer la frecuencia
    li $a3, 127     	# Establece el volumen del sonido 
    syscall        	# Realizar una llamada al sistema para reproducir el sonido 
    jr $ra         	

gameOverSound:		
	li $v0, 31   	# Carga la llamada del sistema para el sonido
	li $a0, 5    	# Establecer el tipo de sonido "beep"
	li $a1, 2000    # Establecer la duracion del sonido (en milisegundos)
	li $a2, 0       # Establecer la frecuencia
	li $a3, 127	# Establece el volumen del sonido 
	syscall	     	# Realizar una llamada al sistema para reproducir el sonido 
	jr $ra 
	
ExitProgram:
	li $v0, 10      # Codigo de la llamada del sistema para salir del programa
	syscall         # Llamar al sistema para salir del programa

   
