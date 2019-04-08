#name: Kiara Barias
#id: 23402450
#date: March 26, 2019
#a program that takes in two dimensions to create a blue cross at the center of the bitmap display
.data
frameBuffer: .space 0x80000 # 512 wide X 256 high pixels
n: .word 45
m: .word 63
.text

lw $s0, n # s0 <- n
lw $s1, m # s1 <- m
addi $s2, $s2, 1 # s2 <- 1

nCheck: #check if n is odd
andi $t0,$s0, 1 # t0 <- gets 1 if n is odd, else gets 0
beq $t0, $s2, makeNeven #if t0 = 1 then n is odd and go to makeNeven
j ignoreN #if n not odd jump to ignoreN
makeNeven: addi $s0, $s0, 1 #s0 <- n+1 if odd

mCheck: #check if m is odd
ignoreN: andi $t0,$s1, 1 # t0 <- gets 1 if m is odd, else gets 0
beq $t0, $s2, makeMeven #if t0 = 1 then m is odd and go to makeMeven
j ignoreM #if m not odd jump to ignoreM
makeMeven: addi $s1, $s1, 1 #s1 <- m+1 if odd

frameCheck: #check if n and m together fit in frame
ignoreM: add $t0, $s1, $s1 #t0 <- 2m
add $s7, $t0, $s0 #t0 <- n + 2m
addi $t1, $t1, 257 #t1 <- 257, height greater than frame
slt $t3, $s7, $t1 #t3 <- 1 if s7 < t1, (n + 2m) < 257, else gets 0
beq $t3, $zero TooBig #if t3 = 0, (n + 2s1) >= 257, go to TooBig. Don't print anything

YellowBackground:
la $t1,frameBuffer #t1 <- address of framebuffer
andi $t0,$t0,0 # t0 <- 0
li $t3,0x0FFFF000 #t3 <- yellow

addi $t6, $t6, 256 # t6 <- 256
height: beq $t6, $zero, endforloop #if height 256 reached exit loop (endforloop)
add $t0, $t0, $t1 #t0 <- address of framebuffer
addi $t2,$t2,512 #t2 <- 512
width: beq $t2, $zero, Ewidth #if the width of 512 is reached exit the width loop (Ewidth)
sw $t3, 0($t0) #store yellow at framebuffer + t0 
addi $t0, $t0, 4 #t0 <- t0 + 4, increment by 4
addi $t2, $t2, -1 #t2 <- t2 - 1, decrement width counter
j width #jump back to width loop
Ewidth: addi $t1, $t1, 2048 #t1 <- t1 + 2048, column 0 + new row
andi $t0,$t0,0x00000 #t0 <- 0
addi $t6, $t6, -1 #t6 <- t6 - 1, decrement height counter
j height #jump back to height loop

CenterOfFrame:
endforloop: li $t3,0x00000FFF #t3 <- blue
la $t4,frameBuffer #t4 <- address of framebuffer
andi $t0, $t0, 0 #t0 <- 0
andi $t1, $t1, 0 #t1 <- 0
addi $t0,$t0, 128 #t0 <- 256/2
addi $t1,$t1, 256 #t1 <- 512/2
sll $t0, $t0, 11 #t0 <- 128 * 2048
sll $t1, $t1, 2 #t1 <- 256 * 4
add $t0, $t0, $t1 #t0 <- 263168, offset to center
add $s3, $t0, $t4 #s3 <- framebuffer + 263168, center of frame

leftMostCorner:
srl $s4, $s0, 1 #s4 <- n/2
add $t0, $s1, $s4 #t0 <- m + n/2
sll $t1, $t0, 2 # t1 <- (m + n/2) * 4
sub $t1, $s3, $t1 #t1 <- center - (m + n/2)
sll $t2, $s4, 11 # t2 <- (n/2) * 2048, offset to upward corner 
sub $s5, $t1, $t2 #s5 <- [center - (m + n/2)] - [(n/2) * 2048], leftmost corner

topLeftCorner:
sll $t1, $s4, 2 #t1 <- (n/2) * 4
sub $t1, $s3, $t1 #t1 <- center - 4(n/2)
add $t0, $s1, $s4 #t0 <- m + n/2
sll $t0, $t0, 11 #t0 <- (m + n/2) * 2048, offest to left top corner
sub $s6, $t1, $t0 #s6 <- [center - 4(n/2)] - [(m + n/2) * 2048], top left corner

BlueCross:
add $t9, $zero, $s5 #t9 <- address of leftmost corner
add $t7, $zero, $s0 #t7 <- n
heightn: beq $t7, $zero, endHeight #if height n reached exit loop (endHeight)
add $t0, $zero, $t9 #t0 <- address of leftmost corner
add $t6, $zero, $s7 #t6 <- width 2m + n
widthm: beq $t6, $zero, EndWidth #if width of 2m + n is reached exit
sw $t3, 0($t0) #store black at leftmost corner +$t0
addi $t0, $t0, 4 #t0 <- t0 + 4, increment leftmost corner copy by 4
addi $t6, $t6, -1 #t6 <- t6 - 1, decrement width counter
j widthm #jump to widthm
EndWidth: addi $t9, $t9, 2048 #t9 <- t9 + 2048
andi $t0, $t0, 0 #t0 <- 0
addi $t7, $t7, -1 #t7 <- t7 - 1, decrement height counter
j heightn #jump to heightn
endHeight: 

add $t9, $zero, $s6 #t9 <- address of top left corner
add $t7, $zero, $s7 #t7 <- 2m + n
height2: beq $t7, $zero, endHeight2 #if height 2m + n reached exit loop
add $t0, $zero, $t9 #t0 <- address of top left corner
add $t6, $zero, $s0 #t6 <- width n
width2: beq $t6, $zero, EWidth2 #if width of n is reached exit
sw $t3, 0($t0) #store black at leftmost corner +$t0
addi $t0, $t0, 4 #t0 <- t0 + 4, increment leftmost corner copy by 4
addi $t6, $t6, -1 #t6 <- t6 -1, decrement width counter
j width2 #jump to width2
EWidth2: addi $t9, $t9, 2048 #t9 <- t9 + 2048
andi $t0, $t0, 0 #t0 <- 0
addi $t7, $t7, -1 #t7 <- t7 - 1, decrement height counter
j height2 #jump to height2
endHeight2: 

TooBig:li $v0,10 #exit code
syscall
