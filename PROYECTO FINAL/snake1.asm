#ASIGNACION DE MEMORIA

.data
Bufferbitmap: .space 0x80000 # RESERVA BYTES PARA LA DISPLAY DEL BITMAP
speedx: .word	0		# VELOCIDAD DE INICIO PARA X
speedy: .word	0		# VELOCIDAD DE INICIO PARA Y
posx: .word	50		# POSICION X SERPIENTE
posy: .word	27		# POSICION Y SERPIENTE
tail: .word	7624		# POSICION INICIAL DE LA COLA DE LA SERPIENTE
applex:	 .word	32		# POSICION X MANZANA
appley: .word	16		# POSICION Y MANZANA
snakeUp: .word	0x00007F00	# PIXEL DIBUJA CUANDO LA SERPIETE VA PARA ARRIBA
snakeDown: .word	0x01007F00	# PIXEL DIBUJA CUANDO LA SERPIETE VA PARA ABAJO
snakeLeft: .word	0x02007F00	# PIXEL DIBUJA CUANDO LA SERPIETE VA PARA IZQUIERDA
snakeRight: .word	0x03007F00	# PIXEL DIBUJA CUANDO LA SERPIETE VA PARA DERECHA
convertFactX: .word	64		# CONVERSOR PARA DISPLAY EN BITMAP
convertFactY: .word	4		# CONVERSOR PARA DISPLAY EN BITMAP
SkyColor: .word 0xBBBBFFFF	
RedColor: .word 0x00ff0000
BlueColor: .word 0x000000FF

.macro DisplayScenario
la 	$t0, Bufferbitmap	# SE CARGA LA DIRECCION INICIAL DEL BITMAP
	li 	$t1, 0x20000		# DECLARA UN ESPACIO SUFICIENTE PARA 512*256 pixels
	lw 	$t2, SkyColor	# CARGA PIXEL COLOR VERDE
loop1:				#INGRESO LOOP
	sw   	$t2, 0($t0)	#ALMACENA VALOR DE MEMORIA DE $t0 EN $t2, direccion inicial bitmap,pinta
	addi 	$t0, $t0, 4 	# AVANZA SIGUIENTE POSICION DEL PIXEL EN DISPLAY
	addi 	$t1, $t1, -1	# SE DECREMENTA UNA POSICION DEL VALOR RESERVADO PARA EL BITMAP
	bnez 	$t1, loop1	# SE REPITE EL LOOP HASTA CUANDO EL NUMERO DE PIXELES SEA 0
.end_macro 


.text
#DIBUJO DE BITMAP DISPLAY
DisplayScenario
### DIBUJO DE BORDES DEL BITMAP
	
	# SECCION BORDE SUPERIOR
	la	$t0, Bufferbitmap	# SE CARGA LA DIRECCION INICIAL DEL BITMAP DENUEVO
	addi	$t1,$zero, 64		# REG DE t1 = 64 
	lw 	$t2, BlueColor		# CARGA PIXEL COLOR AZUL
drawTop:				#INGRESO LOOP PARA DIBUJAR TOP
	sw	$t2, 0($t0)		# ALMACENA VALOR DE MEMORIA DE $t2 EN $t0, direccion inicial bitmap,pinta
	addi	$t0, $t0, 4		# SIGUIENTE PIXEL
	addi	$t1, $t1, -1		# DECRECE CUENTA DE PIXEL
	bnez	$t1, drawTop		# SE REPITE EL LOOP HASTA CUANDO EL NUMERO DE PIXELES SEA 0
	
	# SECCION BORDE INFERIOR
	la	$t0, Bufferbitmap	# SE CARGA LA DIRECCION INICIAL DEL BITMAP DENUEVO
	addi	$t0, $t0, 7936		# SETEA PIXEL ABAJO IZQUIERDA
	addi	$t1, $zero, 64		# REG DE t1 = 64 

drawBot:				#INGRESO LOOP PARA DIBUJAR BOT
	sw	$t2, 0($t0)		# ALMACENA VALOR DE MEMORIA DE $t2 EN $t0, direccion inicial bitmap,pinta con color
	addi	$t0, $t0, 4		# SIGUIENTE PIXEL
	addi	$t1, $t1, -1		# DECRECE CUENTA DE PIXEL
	bnez	$t1, drawBot		# SE REPITE EL LOOP HASTA CUANDO EL NUMERO DE PIXELES SEA 0
	
	# SECCION BORDE IZQUIERDO
	la	$t0, Bufferbitmap	# SE CARGA LA DIRECCION INICIAL DEL BITMAP DENUEVO
	addi	$t1, $zero, 256		# REG DE t1 = 256 COLUMNA 

drawLeft:				#INGRESO LOOP PARA DIBUJAR LEFT
	sw	$t2, 0($t0)		# ALMACENA VALOR DE MEMORIA DE $t0 EN $t2, direccion inicial bitmap,pinta
	addi	$t0, $t0, 256		# SIGUIENTE PIXEL
	addi	$t1, $t1, -1		# DECRECE CUENTA DE PIXEL
	bnez	$t1, drawLeft		# SE REPITE EL LOOP HASTA CUANDO EL NUMERO DE PIXELES SEA 0
	
	# SECCION BORDE DERECHO
	la	$t0, Bufferbitmap	# SE CARGA LA DIRECCION INICIAL DEL BITMAP DENUEVO
	addi	$t0, $t0, 508		# PIXEL INICIADOR ARRIBA DERECHA
	addi	$t1, $zero, 255		#REG DE t1 = 255 COLUMNA 

drawRight:				#INGRESO LOOP PARA DIBUJAR RIGHT
	sw	$t2, 0($t0)		# ALMACENA VALOR DE MEMORIA DE $t0 EN $t2, direccion inicial bitmap,pinta GUARDA
	addi	$t0, $t0, 256		# SIGUIENTE PIXEL
	addi	$t1, $t1, -1		# DECRECE CUENTA DE PIXEL
	bnez	$t1, drawRight		# SE REPITE EL LOOP HASTA CUANDO EL NUMERO DE PIXELES SEA 0
	
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
	add	$a0, $s3, $zero	
	jal	updateSnake	#SALTO HASTA LA SIGUIENTE SUBSECCION DE updateSnake
	
	
	jal 	updateHead # SALTO HASTA LA SIGUIENTE SUBSECCION para mover a la serpiente
	
	j	justExit 	#SALTO HACIA justExit que ejecuta denuevo gameUpdateLoop

moveDown:
	lw	$s3, snakeDown	# REG $s3 CONTENDRA O GUARDARA LA DIRECCION DE LA SERPIENTE
	add	$a0, $s3, $zero	
	jal	updateSnake	#SALTO HASTA LA SIGUIENTE SUBSECCION DE updateSnake
	
	jal 	updateHead # SALTO HASTA LA SIGUIENTE SUBSECCION para mover a la serpiente
	
	j	justExit	#SALTO HACIA justExit que ejecuta denuevo gameUpdateLoop
	
moveLeft:
	lw	$s3, snakeLeft	# # REG $s3 CONTENDRA O GUARDARA LA DIRECCION DE LA SERPIENTE
	add	$a0, $s3, $zero	
	jal	updateSnake
	
	jal 	updateHead
	
	j	justExit	#SALTO HACIA justExit que ejecuta denuevo gameUpdateLoop
	
moveRight:
	lw	$s3, snakeRight	# s3 = direction of snake
	add	$a0, $s3, $zero	
	jal	updateSnake #SALTO HASTA LA SIGUIENTE SUBSECCION DE updateSnake

	jal 	updateHead # SALTO HASTA LA SIGUIENTE SUBSECCION para mover a la serpiente

	j	justExit	#SALTO HACIA justExit que ejecuta denuevo gameUpdateLoop

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
	addi	$t5, $zero, 0		# SETEO VELOCIDAD X 0
	addi	$t6, $zero, -1	 	# SETEO VELOCIDAD Y -1, ESTO SE DEBE A QUE SE ENCUENTRA INVERTIDO EL PLANO EN BITMAP
	sw	$t5, speedx		# SE GUARDA EN LA SPEEDX EL VALOR CORRESPONDIENTE A ESA VELOCIDAD
	sw	$t6, speedy		# SE GUARDA EN LA SPEEDY EL VALOR CORRESPONDIENTE A ESA VELOCIDAD
	j exitSpeed
	
setSpeedDown:
	addi	$t5, $zero, 0		# SETEO VELOCIDAD X 0
	addi	$t6, $zero, 1 		# SETEO VELOCIDAD Y 1, ESTO SE DEBE A QUE SE ENCUENTRA INVERTIDO EL PLANO EN BITMAP
	sw	$t5, speedx		# SE GUARDA EN LA SPEEDX EL VALOR CORRESPONDIENTE A ESA VELOCIDAD
	sw	$t6, speedy		# SE GUARDA EN LA SPEEDY EL VALOR CORRESPONDIENTE A ESA VELOCIDAD
	j exitSpeed
	
setSpeedLeft:
	addi	$t5, $zero, -1		# SETEO VELOCIDAD X -1
	addi	$t6, $zero, 0 		# SETEO VELOCIDAD Y 0
	sw	$t5, speedx		# SE GUARDA EN LA SPEEDX EL VALOR CORRESPONDIENTE A ESA VELOCIDAD
	sw	$t6, speedy		# SE GUARDA EN LA SPEEDY EL VALOR CORRESPONDIENTE A ESA VELOCIDAD
	j exitSpeed
	
setSpeedRight:
	addi	$t5, $zero, 1		# SETEO VELOCIDAD X 1
	addi	$t6, $zero, 0 		# SETEO VELOCIDAD Y 0
	sw	$t5, speedx		# SE GUARDA EN LA SPEEDX EL VALOR CORRESPONDIENTE A ESA VELOCIDAD
	sw	$t6, speedy		# SE GUARDA EN LA SPEEDY EL VALOR CORRESPONDIENTE A ESA VELOCIDAD
	j exitSpeed
	
exitSpeed:
	
	lw 	$t2, RedColor	# CARGO COLOR de manzana
	bne	$t2, $t4, headNotApple	# SI NO SON IGUALES, PIXEL COLOR ORIGINAL GUARDADO ANTERIORMENTE Y COLOR DE MANZANA, SE EJECUTA SUBSECCION HEADNOTAPPLE
	
	jal 	newLocApple
	jal	drawApple	#SALTO DIBUJO NUEVA MANZANA
	j	exitUpdateSnake
	
headNotApple:

	lw	$t2, SkyColor		# CARGA COLOR VERDE
	beq	$t2, $t4, HeadValidation	
	
	addi 	$v0, $zero, 10	# GAME OVER
	syscall
	
HeadValidation:

	lw	$t0, tail		# t0 = tail
	la 	$t1, Bufferbitmap	# CARGA DIRECCION DE BITMAP
	add	$t2, $t0, $t1		# SE OBTIENE POSICION DE LA COLA EN BITMAP
	lw 	$t3, SkyColor	        # CARGA COLOR VERDE
	lw	$t4, 0($t2)		# CARGA COLOR Y DIRECCION COLA
	sw	$t3, 0($t2)		# SE REEMPLAZA COLOR DE COLA CON COLOR DE BACKGROUND
	
	lw	$t5, snakeUp			# SE CARGA EL VALOR ASIGNADO 
	beq	$t5, $t4, NewTailUp		#SI DIRECCION DE LA COLA Y EL COLOR A PINTAR SON IGUAL EJECUTA SUBSECCION DE ACTUALIZACION DE COLA CORRESPONDIENTE PARA QUE CAMINE LA SERPIENTE
	
	lw	$t5, snakeDown			# SE CARGA EL VALOR ASIGNADO 
	beq	$t5, $t4, NewTailDown	#SI DIRECCION DE LA COLA Y EL COLOR A PINTAR SON IGUAL EJECUTA SUBSECCION DE ACTUALIZACION DE COLA  CORRESPONDIENTE PARA QUE CAMINE LA SERPIENTE
	
	lw	$t5, snakeLeft			# SE CARGA EL VALOR ASIGNADO 
	beq	$t5, $t4, NewTailLeft	#SI DIRECCION DE LA COLA Y EL COLOR A PINTAR SON IGUAL EJECUTA SUBSECCION DE ACTUALIZACION DE COLA CORRESPONDIENTE PARA QUE CAMINE LA SERPIENTE
	
	lw	$t5, snakeRight			# SE CARGA EL VALOR ASIGNADO 
	beq	$t5, $t4, NewTailRight	#SI DIRECCION DE LA COLA Y EL COLOR A PINTAR SON IGUAL EJECUTA SUBSECCION DE ACTUALIZACION DE COLA  CORRESPONDIENTE PARA QUE CAMINE LA SERPIENTE
	
NewTailUp:
	addi	$t0, $t0, -256		# ACTUALIZACION DE COLA EJE X
	sw	$t0, tail		# GUARDA O CARGA NUEVO VALOR DE COLA
	j exitUpdateSnake
	
NewTailDown:
	addi	$t0, $t0, 256		# ACTUALIZACION DE COLA  EJE X
	sw	$t0, tail		# GUARDA O CARGA NUEVO VALOR DE COLA
	j exitUpdateSnake
	
NewTailLeft:
	addi	$t0, $t0, -4		# ACTUALIZACION DE COLA  EJE Y
	sw	$t0, tail		# GUARDA O CARGA NUEVO VALOR DE COLA
	j exitUpdateSnake
	
NewTailRight:
	addi	$t0, $t0, 4		# ACTUALIZACION DE COLA  EJE Y
	sw	$t0, tail		# GUARDA O CARGA NUEVO VALOR DE COLA
	j exitUpdateSnake
	
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
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code	

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
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code		

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

	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code	
