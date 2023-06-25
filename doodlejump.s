#####################################################################
#
# CSC258H5S Winter 2021 Assembly Programming Project
# University of Toronto Mississauga
#
# Group members:
# - Student 1: Brooklyn Guo, 1006075523
# - Student 2: Samir Ghias, 1006537730
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Display the score on screen.
# 2. More platform types (moving platforms)
# 3. Opponents / lethal creatures that can move and hurt the Doodler.
# 4. Change Difficulty by decreasing platform sizes as score increases.
# 5. Dynamic Background: dynamically changing background (Clouds moving horizontally)
#
# Any additional information that the TA needs to know:
# - There are 5 additional features. Some of them overlap.
# - In the top right, we will display the score up to a max of 999. If this score 
#   is surpassed, the screen will print "gg".
# - There are moving platforms, in the form of white clouds. These white clouds can 
#   be used to jump higher. Some white clouds move slowly upwards, and wrap to bottom. 
#   Other clouds move slowly upwards, and wrap to top.
# - There are opponents, in the form of black clouds. These black clouds move 
#   horizontally, and also gradually move downwards, wrapping to top when they reach 
#   the bottom of the screen. If our doodler touches the black cloud from left, right, 
#   below, or above, the program will exit gracefully, screen will print "gg".
# - The difficulty increases as score increases. The platforms start off at a width of 
#   8 pixels. As score increases the platforms decrease by 1 pixel in fixed increments 
#   of the score. The smallest platform is width 1.
# - The background is dynamic, as the clouds also act as a background scenery. The black
#   and white clouds move horizontally, some up, some down, some left, some right. The 
#   clouds also wrap from bottom to top or top to bottom.
#
# === HOW TO PLAY ===
# 1. Click "Tools" in top bar. 
# 2. Click Bitmap Display.
# 3. Configure the settings of the display to what is mentioned above in lines 10-15.
# 4. Click "Tools" in top bar.
# 5. Click Keyboard and Display MMIO Simulator.
# 6. Click "Run" -> then click "Assemble".
# 7. Click the big green play button at the top of the screen.
# 8. The game will start. Use key 'j' to move left, key 'k' to move right.
#####################################################################

.data
	space: .asciiz " "
	gameOver: .asciiz " Game Over"
	bottomRight: .word 4096      # end of the bitmap
	listPlatforms: .space 40       # int array of 10 ints
    amountPlatforms: .word 40   # number of platforms * 4
	sleepTimer: .word 48        # control framerate
	doodlerColour: .word 0x2105a8    
	backgroundColour: .word 0x8fd2ff
	platformColour: .word 0xcfb77e
	startPos: .word 544
	fuel: .word 15	# jump duration in frames
	listClouds: .space 36
	cloud1: .word 396
	cloud2: .word 1520
	cloud3: .word 2572
	cloud4: .word 3696
	blackColor: .word 0x000000
	cloudsColor: .word 0xffffff
	greyColor: .word 0x444444
	arrayClouds: .word 396, 1520, 2572, 3696
    maxShiftNumber: .word 2560
    scoreColour: .word 0x147303
    ggColour: .word 0xfff708
	
.text
main:
	
	# paint background
	lw $a0, backgroundColour
	jal PaintBackground
	
	jal GeneratePlatforms
	
	lw $t0, startPos  		# player position
	li $t1, 0 			# player current direction
	li $t2, 0			# jumping fuel (if not 0, go up)
	lw $t3, bottomRight		# collision pointer
	li $t4, 0			# score initialize to 0
	lw $t5, cloud1			# cloud1 initial position
	lw $t6, cloud2			# cloud2 initial position
	lw $t7, cloud3			# cloud3 initial position
	lw $t8, cloud4			# cloud4 initial position

    j MainLoop


# a0: background colour
PaintBackground:
    #temporarily storing important information in a stack
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    li $t0, 0
    LoopPaintBackGround:
    beq $t0, 4096, ExitPaintBackGround
    add $t1, $t0, $gp # aligning screen dimension with base address
    sw $a0, ($t1) # colouring block
    addi $t0, $t0, 4 # incrementing to next block to paint
    j LoopPaintBackGround 
    ExitPaintBackGround:
    # restoring important information
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    jr $ra


# Paints cloud, a0: position, a1: colour
PaintCloud:
	addi $sp, $sp, -4
	sw $s0, ($sp)
	
	add $s0, $gp, $a0
	sw $a1, 0($s0)
	sw $a1, 124($s0)
	sw $a1, 128($s0)
	sw $a1, 132($s0)
	sw $a1, 248($s0)
	sw $a1, 252($s0)
	sw $a1, 256($s0)
	sw $a1, 260($s0)
	sw $a1, 264($s0)
	
	lw $s0, ($sp)
	addi $sp, $sp, 4
	jr $ra


# a0: colour to paint, a1: current score
PaintPlatforms:	
    # temporarily storing key info in stack
	addi $sp, $sp, -4
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
	li $t0, 0
    lw $t2, amountPlatforms
    la $t3, listPlatforms
	PaintPlat:
		beq $t0, $t2, ExitPaintPlat
        add $t1, $t3, $t0
        lw $t1, 0($t1)
		add $t1, $t1, $gp # aligning screen dimension with base address
		
		bge $a1, 36, LevelSeven
		bge $a1, 30, LevelSix
		bge $a1, 24, LevelFive
		bge $a1, 18, LevelFour
		bge $a1, 12, LevelThree
		bge $a1, 6, LevelTwo
		bge $a1, 0, LevelOne
		
		LevelOne:
			sw $a0, 0($t1)
			sw $a0, 4($t1)
			sw $a0, 8($t1)
			sw $a0, 12($t1)
			sw $a0, 16($t1)
			sw $a0, 20($t1)
			sw $a0, 24($t1)
			j ExitLevelPaint
		
		LevelTwo:
			sw $a0, 0($t1)
			sw $a0, 4($t1)
			sw $a0, 8($t1)
			sw $a0, 12($t1)
			sw $a0, 16($t1)
			sw $a0, 20($t1)
			j ExitLevelPaint
			
		LevelThree:
			sw $a0, 0($t1)
			sw $a0, 4($t1)
			sw $a0, 8($t1)
			sw $a0, 12($t1)
			sw $a0, 16($t1)
			j ExitLevelPaint
		
		LevelFour:
			sw $a0, 0($t1)
			sw $a0, 4($t1)
			sw $a0, 8($t1)
			sw $a0, 12($t1)
			j ExitLevelPaint
		
		LevelFive:
			sw $a0, 0($t1)
			sw $a0, 4($t1)
			sw $a0, 8($t1)	
			j ExitLevelPaint
		
		LevelSix:
			sw $a0, 0($t1)
			sw $a0, 4($t1)
			j ExitLevelPaint
		
		LevelSeven:
			sw $a0, 0($t1)	
			j ExitLevelPaint
		
		ExitLevelPaint:
		addi $t0, $t0, 4 # increment to next platform to paint
		j PaintPlat

	ExitPaintPlat:
    # restoring important information
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    jr $ra


# a0: coordinate, a1: colour
PaintDoodler:
    #temporarily storing important information in a stack
	addi $sp, $sp, -4
	sw $t0, ($sp) 
	add $t0, $gp, $a0 # aligning screen dimension with base address
	sw $a1, 0($t0) # colouring doodler
    # restoring important information
	lw $t0, ($sp)
	addi $sp, $sp, 4
	jr $ra


GeneratePlatforms:
    #temporarily storing important information in a stack
	addi $sp, $sp, -4
	sw $t0, ($sp)
    addi $sp, $sp, -4
	sw $t1, ($sp)
    addi $sp, $sp, -4
	sw $t2, ($sp)
    addi $sp, $sp, -4
	sw $t3, ($sp)
    addi $sp, $sp, -4
	sw $t4, ($sp)
	
	li $t0, 0
    lw $t2, amountPlatforms
    la $t3, listPlatforms
    li $t4, 16
	GeneratingLand:
		beq $t0, $t2, ExitGeneratePlatforms
		li $v0, 42
		li $a0, 0
		li $a1, 256
		syscall
        mult $a0, $t4
        mflo $a0
        add $t1, $t3, $t0
        sw $a0, 0($t1)
		addi $t0, $t0, 4
		j GeneratingLand
	
	ExitGeneratePlatforms:
        # restoring important information
        lw $t4, ($sp)
		addi $sp, $sp, 4
        lw $t3, ($sp)
		addi $sp, $sp, 4
        lw $t2, ($sp)
		addi $sp, $sp, 4
        lw $t1, ($sp)
		addi $sp, $sp, 4
		lw $t0, ($sp)
		addi $sp, $sp, 4
		jr $ra


KeyboardScan:
    #temporarily storing important information in a stack
	addi $sp, $sp, -4
	sw $s0, 0($sp)
    addi $sp, $sp, -4
	sw $s1, 0($sp)
	lw $s0, 0xffff0000 # get whether the keyboard detect input or not
	beq $s0, 0, ExitKeyboardScan # if no input, exit
	KeyPressed:
    lw $s1, 0xffff0004 # get the exact that was pressed
    beq $s1, 0x6A, KeyJPressed # if j is pressed
    beq $s1, 0x6B, KeyKPressed # if k is pressed
    j ExitKeyboardScan
	KeyJPressed:
    addi $t1, $t1, -4 # move player left 1 block
    j ExitKeyboardScan
	KeyKPressed:
    addi $t1, $t1, 4 # move player right 1 block
    j ExitKeyboardScan
	ExitKeyboardScan:
    # restoring important information
    lw $s1, 0($sp)
    addi $sp, $sp, 4
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    jr $ra


BottomSideCollisionScan:
    #temporarily storing important information in a stack
	addi $sp, $sp, -4
	sw $s0, 0($sp)
    addi $sp, $sp, -4
	sw $s1, 0($sp)
    addi $sp, $sp, -4
    sw $s2, 0($sp)
    addi $sp, $sp, -4
    sw $s3, 0($sp)
    addi $sp, $sp, -4
	sw $s4, 0($sp)
	lw $s2, platformColour
	lw $s3, cloudsColor
	lw $s4, greyColor
	add $s0, $gp, $t0   # aligning current player coordinate with base address
	lw $s1, 128($s0)	# one block below player
	beq $s1, $s4, EndGame # collide with grey cloud from above
	beq $s1, $s2, CollisionDetected  # one block CollisionDetected with platform
	beq $s1, $s3, CollisionDetected  # one block CollisionDetexted with cloud
	ExitCollisionDetected:
        # restoring important information
        sw $s4, 0($sp)
        addi $sp, $sp, 4
        sw $s3, 0($sp)
        addi $sp, $sp, 4
        sw $s2, 0($sp)
        addi $sp, $sp, 4
        sw $s1, 0($sp)
        addi $sp, $sp, 4
        sw $s0, 0($sp)
        addi $sp, $sp, 4
        jr $ra
	CollisionDetected:
        lw $t2, fuel	# reset fuel back to 10, since we landed
		addi $t1, $t1, -128		# cancel gravity (increase |x| to increase jump height)
		move $t3, $t0
        j ExitCollisionDetected

LeftRightUpSideCollisionScan:
    #temporarily storing important information in a stack
	addi $sp, $sp, -4
	sw $s0, 0($sp)
    addi $sp, $sp, -4
	sw $s1, 0($sp)
    addi $sp, $sp, -4
    sw $s2, 0($sp)
    addi $sp, $sp, -4
    sw $s3, 0($sp)
    addi $sp, $sp, -4
	sw $s4, 0($sp)
	add $s0, $gp, $t0 # aligning current player coordinate with base address
	lw $s1, -128($s0) # one block above player
	lw $s2, 4($s0)	# one block right of player
	lw $s3, -4($s0) # one block left of player
    lw $s4, greyColor # load grey cloud colour
	beq $s1, $s4, EndGame # collide with grey cloud from below
	beq $s2, $s4, EndGame # collide with grey cloud from left
	beq $s3, $s4, EndGame # collide with grey cloud from right
    # restoring important information
	sw $s4, 0($sp)
    addi $sp, $sp, 4
	sw $s3, 0($sp)
    addi $sp, $sp, 4
	sw $s2, 0($sp)
    addi $sp, $sp, 4
	sw $s1, 0($sp)
    addi $sp, $sp, 4
	sw $s0, 0($sp)
	addi $sp, $sp, 4
    jr $ra


DoodleJumping:
	addi $sp, $sp, -4
	sw $ra, ($sp) # must store $ra in a stack pointer, since we will call other functions in this function
	li $t1, 0   # make doodler movement static (stop falling)
	jal KeyboardScan # scan for keyboard input, and move left or right if needed
    beq $zero, $t2, FallDown # if we are out of fuel, fall down. Otherwise jump
    JumpUp:
		addi $t1, $t1, -128 # set direction to upward
        add $t0, $t0, $t1	# move doodler
		addi $t2, $t2, -1 # decrease fuel
        j ExitDoodleJumping
    FallDown:
        addi $t1, $t1, 128	# set direction to downward
	    jal BottomSideCollisionScan # check for bottom collision with enemy / platform
	    jal LeftRightUpSideCollisionScan # check for left right top collision with enemy
        add $t0, $t0, $t1	# move doodler
	    j ExitDoodleJumping # we now need to move the doodler
	ExitDoodleJumping:
		lw $ra, ($sp) # restore $ra
		addi $sp, $sp, 4 
		jr $ra


ShiftDown:
    #temporarily storing important information in a stack
	addi $sp, $sp, -4
	sw $s0, 0($sp)
    addi $sp, $sp, -4
	sw $s1, 0($sp)
    addi $sp, $sp, -4
	sw $s2, 0($sp)
    addi $sp, $sp, -4
	sw $s3, 0($sp)
    addi $sp, $sp, -4
	sw $s4, 0($sp)
    addi $sp, $sp, -4
	sw $s5, 0($sp)
    addi $sp, $sp, -4
	sw $s6, 0($sp)
    lw $s5, amountPlatforms
	lw $s4, maxShiftNumber
    la $s3, listPlatforms
    lw $s6, bottomRight
	bge $t3, $s4, ExitShiftDown
	addi $t3, $t3, 128 # the last block that is jumped off of has to shift down
	addi $t0, $t0, 128 # the doodler must go down
	li $s0, 0 # counter for platforms
	SmallShift:
		beq $s0, $s5, ExitShiftDown
        add $s1, $s3, $s0
        lw $s1, 0($s1)
		addi $s1, $s1, 128
		lw $s2, bottomRight
		blt $s1, $s2, BigShift
        addi $s6, $s6, -8192
		add $s1, $s1, $s6 # wrap platform to top if out of bounds
		addi $t4, $t4, 1 # increment the score
        
        #Below is solely for testing. prints the score
		# _____
		addi $sp, $sp, -4
		sw $a0, ($sp)
		
	
		li $v0, 4
		la $a0, space
		syscall
		
		li $v0, 1
		move $a0, $t4
		syscall
		
		
		lw $a0, ($sp)
		addi $sp, $sp, 4
		# ^^^^^^	
		
		BigShift:
			sw $s1, listPlatforms($s0)
			addi $s0, $s0, 4 # go to next platform
			j SmallShift
	ExitShiftDown:
        # restoring important information
        lw $s6, 0($sp)
        addi $sp, $sp, 4
        lw $s5, 0($sp)
        addi $sp, $sp, 4
        lw $s4, 0($sp)
        addi $sp, $sp, 4
        lw $s3, 0($sp)
        addi $sp, $sp, 4
        lw $s2, 0($sp)
        addi $sp, $sp, 4
		lw $s1, 0($sp)
        addi $sp, $sp, 4
		lw $s0, 0($sp)
		addi $sp, $sp, 4
		jr $ra

# Paints cloud, a0: position, a1: colour, a2: number
PaintScore:
	addi $sp, $sp, -4
	sw $t0, ($sp)
	
	lw $t0, ($sp)
	addi $sp, $sp, 4
	jr $ra

    beq $a2, 0, zero
    beq $a2, 1, one
    beq $a2, 2, two
    beq $a2, 3, three
    beq $a2, 4, four
    beq $a2, 5, five
    beq $a2, 6, six
    beq $a2, 7, seven
    beq $a2, 8, eight
    beq $a2, 9, nine

    add $t0, $gp, $a0

    zero:
        sw $a1, 4($t0)
        sw $a1, 8($t0)
        sw $a1, 12($t0)

        sw $a1, 144($t0)
        sw $a1, 272($t0)
        sw $a1, 400($t0)

        sw $a1, 656($t0)
        sw $a1, 784($t0)
        sw $a1, 912($t0)

        sw $a1, 1036($t0)
        sw $a1, 1032($t0)
        sw $a1, 1028($t0)

        sw $a1, 896($t0)
        sw $a1, 768($t0)
        sw $a1, 640($t0)

        sw $a1, 384($t0)
        sw $a1, 256($t0)
        sw $a1, 128($t0)

    one:
        sw $a1, 144($t0)
        sw $a1, 272($t0)
        sw $a1, 400($t0)
        
        sw $a1, 656($t0)
        sw $a1, 784($t0)
        sw $a1, 912($t0)

    two:
        sw $a1, 4($t0)
        sw $a1, 8($t0)
        sw $a1, 12($t0)

        sw $a1, 128($t0)
        sw $a1, 256($t0)
        sw $a1, 384($t0)

        sw $a1, 516($t0)
        sw $a1, 520($t0)
        sw $a1, 524($t0)

        sw $a1, 656($t0)
        sw $a1, 784($t0)
        sw $a1, 912($t0)

        sw $a1, 1028($t0)
        sw $a1, 1032($t0)
        sw $a1, 1036($t0)
        
    three:
        sw $a1, 4($t0)
        sw $a1, 8($t0)
        sw $a1, 12($t0)

        sw $a1, 128($t0)
        sw $a1, 256($t0)
        sw $a1, 384($t0)

        sw $a1, 516($t0)
        sw $a1, 520($t0)
        sw $a1, 524($t0)

        sw $a1, 640($t0)
        sw $a1, 768($t0)
        sw $a1, 896($t0)

        sw $a1, 1028($t0)
        sw $a1, 1032($t0)
        sw $a1, 1036($t0)

    four:
        sw $a1, 128($t0)
        sw $a1, 256($t0)
        sw $a1, 384($t0)

        sw $a1, 144($t0)
        sw $a1, 272($t0)
        sw $a1, 400($t0)

        sw $a1, 516($t0)
        sw $a1, 520($t0)
        sw $a1, 524($t0)

        sw $a1, 656($t0)
        sw $a1, 784($t0)
        sw $a1, 912($t0)

    five:
        sw $a1, 4($t0)
        sw $a1, 8($t0)
        sw $a1, 12($t0)

        sw $a1, 128($t0)
        sw $a1, 256($t0)
        sw $a1, 384($t0)

        sw $a1, 516($t0)
        sw $a1, 520($t0)
        sw $a1, 524($t0)

        sw $a1, 656($t0)
        sw $a1, 784($t0)
        sw $a1, 912($t0)

        sw $a1, 1028($t0)
        sw $a1, 1032($t0)
        sw $a1, 1036($t0)

    six:
        sw $a1, 4($t0)
        sw $a1, 8($t0)
        sw $a1, 12($t0)

        sw $a1, 128($t0)
        sw $a1, 256($t0)
        sw $a1, 384($t0)

        sw $a1, 516($t0)
        sw $a1, 520($t0)
        sw $a1, 524($t0)

        sw $a1, 640($t0)
        sw $a1, 768($t0)
        sw $a1, 896($t0)

        sw $a1, 656($t0)
        sw $a1, 784($t0)
        sw $a1, 912($t0)

        sw $a1, 1028($t0)
        sw $a1, 1032($t0)
        sw $a1, 1036($t0)

    seven:
        sw $a1, 4($t0)
        sw $a1, 8($t0)
        sw $a1, 12($t0)

        sw $a1, 144($t0)
        sw $a1, 272($t0)
        sw $a1, 400($t0)

        sw $a1, 656($t0)
        sw $a1, 784($t0)
        sw $a1, 912($t0)

    eight:
        sw $a1, 4($t0)
        sw $a1, 8($t0)
        sw $a1, 12($t0)

        sw $a1, 128($t0)
        sw $a1, 256($t0)
        sw $a1, 384($t0)

        sw $a1, 144($t0)
        sw $a1, 272($t0)
        sw $a1, 400($t0)

        sw $a1, 516($t0)
        sw $a1, 520($t0)
        sw $a1, 524($t0)

        sw $a1, 640($t0)
        sw $a1, 768($t0)
        sw $a1, 896($t0)

        sw $a1, 656($t0)
        sw $a1, 784($t0)
        sw $a1, 912($t0)

        sw $a1, 1028($t0)
        sw $a1, 1032($t0)
        sw $a1, 1036($t0)
        
    nine:
        sw $a1, 4($t0)
        sw $a1, 8($t0)
        sw $a1, 12($t0)

        sw $a1, 128($t0)
        sw $a1, 256($t0)
        sw $a1, 384($t0)

        sw $a1, 144($t0)
        sw $a1, 272($t0)
        sw $a1, 400($t0)

        sw $a1, 516($t0)
        sw $a1, 520($t0)
        sw $a1, 524($t0)

        sw $a1, 656($t0)
        sw $a1, 784($t0)
        sw $a1, 912($t0)

        sw $a1, 1028($t0)
        sw $a1, 1032($t0)
        sw $a1, 1036($t0)


PaintGG:    #a0 has the color, a1 has the location to print from
    add $s1, $a1, $gp #save s1 as gp and the offset
    sw $a0, 0($s1)
    sw $a0, 4($s1)
    sw $a0, 8($s1)
    sw $a0, 12($s1)
    sw $a0, 16($s1)

    sw $a0, 128($s1)
    sw $a0, 256($s1)
    sw $a0, 384($s1)
    sw $a0, 512($s1)
    sw $a0, 640($s1)

    sw $a0, 644($s1)
    sw $a0, 648($s1)
    sw $a0, 652($s1)
    sw $a0, 656($s1)

    sw $a0, 528($s1)
    sw $a0, 400($s1)
    sw $a0, 396($s1)
    sw $a0, 392($s1)

    jr $ra


MainLoop:
    # sleeping
    li $v0, 32
    lw $a0, sleepTimer
    syscall
    
    # restore background
    lw $a1, backgroundColour
    move $a0, $t5
    jal PaintCloud
    move $a0, $t6
    jal PaintCloud
    move $a0, $t7
    jal PaintCloud
    move $a0, $t8
    jal PaintCloud
    move $a1, $t4
    lw $a0, backgroundColour
    jal PaintPlatforms
    move $a0, $t0
    lw $a1, backgroundColour
    jal PaintDoodler
    
    # shifting screen
    jal ShiftDown
    
    # cloud movement
    moveCloud1:
        add $t5, $t5, 4
        blt $t5, 4096, dontWrapCloud1
        addi $t5, $t5, -4096
    dontWrapCloud1:
    moveCloud2:
        add $t6, $t6, -4
        bge $t6, -256, dontWrapCloud2
        addi $t6, $t6, 4096
    dontWrapCloud2:
    moveCloud3:
        add $t7, $t7, 4
        blt $t7, 4096, dontWrapCloud3
        addi $t7, $t7, -4096
    dontWrapCloud3:
    moveCloud4:
        add $t8, $t8, -4
        bge $t8, -256, dontWrapCloud4
        addi $t8, $t8, 4096
    dontWrapCloud4:
    
    # paint clouds
    lw $a1, cloudsColor # set white cloud colour before calling PaintCloud
    # paint cloud1
    move $a0, $t5
    jal PaintCloud
    # paint cloud2
    move $a0, $t6
    jal PaintCloud
    # paint cloud3 (enemy)
    lw $a1, greyColor # setting enemy cloud colour
    move $a0, $t7
    jal PaintCloud
    # paint cloud4 
    lw $a1, cloudsColor # setting back to friendly cloud colour
    move $a0, $t8
    jal PaintCloud
    
    # paint new platforms
    lw $a0, platformColour
    move $a1, $t4
    jal PaintPlatforms
    jal DoodleJumping # player movement
    # parining the player
    move $a0, $t0
    lw $a1, doodlerColour
    jal PaintDoodler
    bgt $t0, 4096, EndGame # if player goes below screen, end game
    
    j MainLoop
    
EndGame:
    li $v0, 4
    la $a0, gameOver
    syscall
    
    lw $a0, scoreColour    # $t1 stores the red colour code
    li $a1, 1448
    jal PaintGG
    li $a1, 1472
    jal PaintGG
    # lw $a0, blackColor
    # jal PaintBackground
    
    li $v0, 10 # terminate the program gracefully
    syscall
