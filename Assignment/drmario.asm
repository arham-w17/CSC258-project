################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Aryan Hrishikesh Nair, 1008755410
# Student 2: Name, Student Number (if applicable)
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       TODO
# - Unit height in pixels:      TODO
# - Display width in pixels:    TODO
# - Display height in pixels:   TODO
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data

  # To store the location of the CAPSULE
  # CAPSULE_X:          .word   0     # pointer to the x co-ordinate of the capsule.
  # CAPSULE_Y:          .word   0     # pointer to the y co-ordinate of the capsule.
  # CAPSULE_COLOUR1:    .byte   0     # a 3-value variable for the colour of the left-half of the capsule.
  # CAPSULE_COLOUR2:    .byte   0     # a 3-value variable for the colour of the right-half of the capsule.
  # DRMARIO_GRID:       .space  1024  # allocate a space in memory for my Dr. Mario grid.  
##############################################################################
# Immutable Data


##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
  li $t1, 0x00ffff     # $t1 stores the value for the colour cyan.
  lw $t0, ADDR_DSPL    # $t0 = base address for display

  # # Creating the loop variables
  # add $t2, $zero, $zero # initialize the loop variable $t5 to 0. (Register $zero is 'off-limits', always stores 0)
  # addi $t3, $zero, 10   # initialize $t6 to the final value of the loop variable.

  ## start of draw_line function
  ## draws a single line from a starting position
  # Takes in the following parameters:
  # - $a0 : The x co-ordinate for the starting point of vertical line 1
  # - $a1 : The y co-ordinate for the starting point of vertical line 1
  # - $a2 : The x co-ordinate for the starting point of vertical line 2.
  # - $a3 : The y co-ordinate for the starting point of vertical line 2.

  jal draw_bottle
  # jal draw_capsule

  draw_bottle:
    addi $a1, $t0, 928   # the left line starts at ...
    add $a3, $a1, 64     # the right line starts at ...
    add $a0, $zero, $a1  # top left corner of the bottle
    add $a2, $zero, $a3  # top right corner of the bottle
    
    addi $t2, $t2, 0  # index variable for draw_vertical_line_loop
    addi $t3, $t3, 0  # index variable for draw_top_loop
    addi $t4, $t4, 0  # index variable for draw_bottle_neck
    draw_top_loop:
      beq $t3, 5, draw_bottle_neck  # once $t3 == 10, start drawing the bottle neck
      sw $t1, 0($a0)                # paint the current position of $a0 cyan
      sw $t1, 0($a2)                # paint the current position of $a2 cyan
      addi $a0, $a0, 4              # move $a0 forward by 1 pixel
      addi $a2, $a2, -4             # move $a2 backward by 1 pixel
      addi $t3, $t3, 1              # increment the index variale by 1
      j draw_top_loop

    draw_bottle_neck:
      beq $t4, 5, draw_vertical_line_loop  # once $t4 == 5. start drawing the vertical edges of the bottle.
      sw $t1, 0($a0)                       # paint the current position of $a0 cyan
      sw $t1, 0($a2)                       # paint the current position of $a2 cyan
      addi $a0, $a0, -128                  # move $a0 up by 1 pixel
      addi $a2, $a2, -128                  # move $a2 up by 1 pixel
      addi $t4, $t4, 1                     # increment the index variale by 1
      j draw_bottle_neck
      
    draw_vertical_line_loop:
      beq $t2, 20, draw_base_loop  # If $a1 == 512 jump out of the loop.
      addi $a1, $a1, 128		   # Move current pixel position of $a1 one pixel to the bottom.
      addi $a3, $a3, 128           # Move current pixel position of $a2 one pixel to the bottom.
      sw $t1, 0($a1)			   # Draw pixel at current value of $a1.
      sw $t1, 0($a3)               # Draw pixel at current value of $a3.
      # addi $a1, $a1, 128		   # Move current pixel position of $a1 one pixel to the bottom.
      # addi $a3, $a3, 128         # Move current pixel position of $a2 one pixel to the bottom.
      addi $t2, $t2, 1             # Increment the index value by 1.
      j draw_vertical_line_loop    # Jump to beginning of loop

    # sw $t1, 0($a3)       # paint the pixel that $a3 currently stores cyan so that the bottom right corner of the bottle isn't empty.
    # addi $a1, $a1, 4     # move the position stored in $a1 1 over to the right.
    draw_base_loop:
      beq $a1, $a3, randomize_left_half_colour  # Loop termintaes when $a1 == $a3.
      sw $t1, 0($a1)                            # paint the colour corresponding to the value stored in $t1 at $a1 
      addi $a1, $a1, 4                          # move the current position by 4
      j draw_base_loop                          # Jump back to the beginning of the loop

    end_draw_line:
      jr $ra  # Return to calling program

  randomize_left_half_colour:
    li $v0, 42  # assign 42 to $v0 so that we may add an upper bound for the random number.
    li $a0, 0   # generate a random integer >= 0 and < 3.
    li $a1, 3
    syscall

  assign_blue_capsule_left_half:                # paint the left half of the capsule blue.
    bne $a0, 0, assign_green_capsule_left_half  # if $a0 does not store 0, then check to see if it stores 1.
    li $t4, 0x0000ff                            # if $a0 does store 0, then store the blue colour code in $t4.
    j draw_left_half_capsule                    # jump to the function that draws the capsule.

  assign_green_capsule_left_half:             # paint the left half of the capsule green.
    bne $a0, 1, assign_red_capsule_left_half  # if $a0 does not store 1, then check to see if it stores 0.
    li $t4, 0x00ff00                          # if $a0 does store 1, then store the green colour code in $t4.
    j draw_left_half_capsule                  # jump to the function that draws the capsule.

  assign_red_capsule_left_half:         # paint the left half of the capsule red.
    bne $a0, 2, draw_left_half_capsule  # if $a0 does not store 2, then draw the left half of the capsule.
    li $t4, 0xff0000                    # if $a0 does store 1, then store the red colour code in $t4.
    j draw_left_half_capsule            # jump to the function that draws the capsule.

  draw_left_half_capsule:
    addi $a0, $t0, 576  # reusing $a0 to now store the position of the left half of the pixel.
    sw $t4, 0($a0)      # paint the left half of the capsule the colour determined by randomize_left_half_colour and assign_colour_capsule_left_half.

  randomize_right_half_colour:
    li $v0, 42  # assign 42 to $v0 so that we may add an upper bound for the random number.
    li $a0, 0   # generate a random integer >= 0 and < 3.
    li $a1, 3
    syscall

  assign_blue_capsule_right_half:                # paint the right half of the capsule blue.
    bne $a0, 0, assign_green_capsule_right_half  # if $a0 does not store 0, then check to see if it stores 1.
    li $t4, 0x0000ff                             # if $a0 does store 0, then store the blue colour code in $t4.
    j draw_right_half_capsule                    # jump to the function that draws the capsule.

  assign_green_capsule_right_half:             # paint the right half of the capsule green.
    bne $a0, 1, assign_red_capsule_right_half  # if $a0 does not store 1, then check to see if it stores 0.
    li $t4, 0x00ff00                           # if $a0 does store 1, then store the green colour code in $t4.
    j draw_right_half_capsule                  # jump to the function that draws the capsule.

  assign_red_capsule_right_half:         # paint the right half of the capsule red.
    bne $a0, 2, draw_right_half_capsule  # if $a0 does not store 2, then draw the right half of the capsule.
    li $t4, 0xff0000                     # if $a0 does store 1, then store the red colour code in $t4.
    j draw_right_half_capsule            # jump to the function that draws the capsule.

  draw_right_half_capsule:
    addi $a0, $t0, 580  # reusing $a0 to now store the position of the right half of the pixel.
    sw $t4, 0($a0)      # paint the right half of the capsule the colour determined by randomize_right_half_colour and assign_colour_capsule_right_half.
  
  # assign_colour_capsule_left_half:  # assign a colour to the left half of the capsule.
  #   beq $a0, 0, randomize_right_half_colour
  #   li $t4, 0x0000ff  # if randomize_left_half_colour generates 0, the left half of the capsule will be blue (blue colour code stored in $t4).
  #   beq $a0, 1, randomize_right_half_colour
  #   li $t4, 0x00ff00  # if randomize_left_half_colour generates 1, the left half of the capsule will be green (green colour code stored in $t4).
  #   beq $a0, 2, randomize_right_half_colour
  #   li $t4, 0xff0000  # if randomize_left_half_colour generates 2, the left half of the capsule will be red (red colour code stored in $t4).
    
  # randomize_right_half_colour:
  #   li $v0, 42    # assign 42 to $v0 so that we may add an upper bound for the random number.
  #   li $a0, 0  # generate a random number >= 1312 and < 3293.
  #   li $a1, 2
  #   syscall

  # assign_colour_capsule_right_half:  # assign a colour to the right half of the capsule.
  #   beq $a0, 0, draw_capsule
  #   li $t5, 0x0000ff  # if randomize_right_half_colour generates 0, the right half of the capsule will be blue (blue colour code stored in $t5).
  #   beq $a0, 1, draw_capsule
  #   li $t5, 0x00ff00  # if randomize_right_half_colour generates 1, the right half of the capsule will be green (green colour code stored in $t5).
  #   beq $a0, 2, draw_capsule
  #   li $t5, 0xff0000  # if randomize_right_half_colour generates 2, the right half of the capsule will be red (red colour code stored in $t5).

  # draw_capsule:
  #   addi $a0, $t0, 576  # reusing $a0 to now store the position of the left half of the pixel.
  #   add $a1, $a0, 4     # reusing $a1 to now store the position of the right half of the pixel.
  #   sw $t4, 0($a0)      # paint the left half of the capsule the colour determined by randomize_left_half_colour and assign_colour_capsule_left_half.
  #   sw $t5, 0($a1)      # paint the right half of the capsule the colour determined by randomize_right_half_colour and assign_colour_capsule_right_half.

    
    # multu $a2, $a0, 2    # reusing $a2 to now store twice the random number generated by randomize_colour which can be used as a shift factor for the capsule colour. 
    # addi $a0, $t0, 576   # reusing $a0 to now store the position of the left half of the pixel.
    # add $a1, $a0, 4      # reusing $a1 to now store the position of the right half of the pixel.
     
    # li $t4, 0x0000ff    # $t4 stores the colour blue by default.
    # sll $t4, $t4, 
    # li $t5, 0x00ff00   # $t5 stores the colour green.
    # j draw_viruses
  
  draw_viruses:
    addi $a0, $t0, 1472  # reusing $a0 to now store the position of the first virus.
    add $a1, $a0, 496    # resuing $a1 to now store the position of the second virus, 4 rows below and to the left of the first one.
    add $a2, $a1, 796    # resuing $a2 to now store the position of the third virus, 6 rows below and to the right of the second one.
    li $t4, 0xff0000     # $t4 stores the colour red.
    li $t5, 0x00ff00     # $t5 stores the colour green.
    li $t6, 0x0000ff     # $t6 stores the colour blue.
    sw $t4, 0($a0)       # paint the first virus red ($t4 stores red from the previous function)
    sw $t5, 0($a1)       # paint the second virus green ($t5 stores green from the previous function)
    sw $t6, 0($a2)       # paint the third virus blue

  # handle_A_key:
    # la $t1, capsule_x -> set $t1 to the address of the left half of the capsule.
    # lw $t2, 0($t1) -> fetch the x co-ordinate of the cpasule and store in $t2.
    
Exit:
li $v0, 10  # terminate the program gracefully
syscall

  # Note: In Assembly, registers are shared across functions (unlike other programming languages).
  
    # # Initialize the game
    # lw $t0, ADDR_DSPL     # $t0 = base address for display. Top-left corner of the bitmap display. Place in memory from where we look for new pixels.
    # li $t3, 0x0000ff      # Register $t3 stores blue
    
    # add $t5, $zero, $zero # initialize the loop variable $t5 to 0. (Register $zero is 'off-limits', always stores 0)
    # addi $t6, $zero, 10   # initialize $t6 to the final value of the loop variable.
    # addi $t7, $zero, 400  # set the starting address for the line (draw at the 400th pixel).
    
    # jal draw_line         # call the line-drawing function.

    # ## start of draw_line function
    # ## draws a single line from a starting position
    # # Takes in the following parameters:
    # # - $a0 : The x co-ordinate for the starting point of the line
    # # - $a1 : The y co-ordinate for the starting point of the line
    # # - $a2 : The length of the line.
    # draw_line:
    # # Main line drawing loop
    # pixel_draw_start:            # adding the colon makes this the line's label
    # sll $a1, $a1, 7              # calculate the vertical offset from the top-row (multiply $a1 by 128, i.e., perform a logical left shift on $a1 by 7 bits).
    # add $t7, $t0, $a1            # calculate the horizontal offset from the left column.
    # # add the vertical and horizontal offsets to the top-left corner of the bitmap.
    # sw $t3, 0($t0)
    # addi $t5, $t5, 1             # increment the loop variable.
    # addi $t0, $t0, 4             # move to the next pixel in the row (each pixel is 4 bytes).
    # beq $t5, $a2, pixel_draw_end # break out of the loop after drawing the last pixel in this row/line.
    # j pixel_draw_start           # currently, this is an infinite loop
    # pixel_draw_end:              # the end label for the pixel drawing loop. If we do not include this, we get an infinite loop. No conditions here.
    # jr $ra                       # return to the calling program. $ra stands for return address. When this function is called (jumped into), the address from where we enter the function is stored in $ra.
    # ## end of draw_line function

## Notes:
  # Memory lives in the data section.
  # Use stack to hold on to values which are needed later on.

  # To store the location of the CAPSULE
  # CAPSULE_X:    .word  0
  # CAPSULE_Y:    .word  0

game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop
