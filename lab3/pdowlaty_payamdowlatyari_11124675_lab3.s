jal main
#                         ICS 51, Lab #2
#
#      IMPORTANT NOTES:
#
#      Write your assembly code only in the marked blocks.
#
#      DO NOT change anything outside the marked blocks.
#
#      Remember to fill in your name, student ID in the designated fields.
#
#
#      contact sajjadt@uci.edu
###############################################################
#                           Data Section
.data
student_name: .asciiz "Payam Dowlatyari"
student_id: .asciiz "11124675"

identity_m: .word 1, 0, 0, 0, 1, 0
scale_m:    .word 2, 0, 0, 0, 1, 0
rotation_m: .word 0, 1, 0, 1, 0, 0
shear_m:    .word 1, 1, 0, 0, 1, 0

input_1: .byte 100, 60, 81, 2
input_2: .byte 10, 20, 30, 110, 127, 130, 210, 220, 230
input_3: .byte 0, 10, 20, 30, 40, 110, 128, 130, 140, 210, 220, 230, 240, 250, 255, 55
output_1: .space 4
output_2: .space 9
output_3: .space 16

# Part 1 tests data
# thresh value = 128
test_11_expected_output: .byte 0, 0, 0, 0
test_12_expected_output: .byte 0, 0, 0, 0, 0, 255, 255, 255, 255
test_13_expected_output: .byte 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0

# Part 2 tests data
# identity and rotation on input 2
test_221_expected_output: .byte 10, 20, 30, 110, 127, 130, 210, 220, 230
test_222_expected_output: .byte 10, 110, 210, 20, 127, 220, 30, 130, 230
# identity, scale, rotation, and shear on input 3
test_231_expected_output: .byte 0, 10, 20, 30, 40, 110, 128, 130, 140, 210, 220, 230, 240, 250, 255, 55
test_232_expected_output: .byte 0, 20, 0, 0, 40, 128, 0, 0, 140, 220, 0, 0, 240, 255, 0, 0
test_233_expected_output: .byte 0, 40, 140, 240, 10, 110, 210, 250, 20, 128, 220, 255, 30, 130, 230, 55
test_234_expected_output: .byte 0, 10, 20, 30, 110, 128, 130, 0, 220, 230, 0, 0, 55, 0, 0, 0

# Messages
new_line: .asciiz "\n"
space: .asciiz " "
i_str: .asciiz  "Program input:   " 
po_str: .asciiz "Program output:  " 
eo_str: .asciiz "Expected output: " 
t1_str: .asciiz "Testing part 1: \n" 
t2_str_0: .asciiz "Testing part 2 (identity): \n" 
t2_str_1: .asciiz "Testing part 2 (scale): \n" 
t2_str_2: .asciiz "Testing part 2 (rotation): \n" 
t2_str_3: .asciiz "Testing part 2 (shear): \n" 

# Files
fin: .asciiz "lenna.pgm"
fout_thresh: .asciiz "lenna_thresh.pgm"
fout_rotate: .asciiz "lenna_rotation.pgm"
fout_shear: .asciiz "lenna_shear.pgm"
fout_scale: .asciiz "lenna_scale.pgm"

# Input/output buffers
.align 2
in_buffer: .space 400000
in_buffer_end:
.align 2
out_buffer: .space 400000
out_buffer_end:

###############################################################
#                           Text Section
.text
# Utility function to print byte arrays
#a0: array
#a1: length
print_array:
li $t1, 0
move $t2, $a0
print:
lb $a0, ($t2)
andi $a0, $a0, 0xff
li $v0, 1   
syscall
li $v0, 4
la $a0, space
syscall
addi $t2, $t2, 1
addi $t1, $t1, 1
blt $t1, $a1, print
jr $ra
########################################################################################
#a0 = input array
#a1 = output array
#a2 = matrix
#s3 = input dim
#s4 = test str
#s5 = expected array
# Test transform function
########################################################################################
test_p2:
# save ra
addi $sp, $sp, -4
sw $ra, 0($sp)

addi $sp, $sp, -4
sw $a0, 0($sp)
addi $sp, $sp, -4
sw $a1, 0($sp)
addi $sp, $sp, -4
sw $a2, 0($sp)
addi $sp, $sp, -4
sw $a3, 0($sp)
addi $sp, $sp, -4
sw $s4, 0($sp)
addi $sp, $sp, -4
sw $s5, 0($sp)


#a0: input buffer address
#a1: output buffer address
#a2: transform matrix address
#a3: image dimension  (Image will be square sized, i.e. total size = a3*a3)
jal transform 

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

# s5: exp arraay
# s4: input string
# s3: input dimenstion
# s2: matrix
# s1: user out
# s0: inputd

mul $s3, $s3, $s3

move $a0, $s4
syscall
la $a0, i_str
syscall
move $a0, $s0
move $a1, $s3
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, po_str
syscall
move $a0, $s1
move $a1, $s3
jal print_array
li $v0, 4
la $a0, new_line
syscall
la $a0, eo_str
syscall
move $a0, $s5
move $a1, $s3
jal print_array
li $v0, 4
la $a0, new_line
syscall
syscall

# restore ra
lw $ra, 0($sp)
addi $sp, $sp, 4

jr $ra
###############################################################
###############################################################
#                       PART 1 (Image Thresholding)
#a0: input buffer address
#a1: output buffer address
#a2: image dimension (Image will be square sized, i.e., number of pixels = a2*a2)
#a3: threshold value 
###############################################################
threshold:
############################## Part 1: your code begins here ###
li $s0, 0 
li $s1, 0
li $t0, 0 # index
li $t1, 0 # temp
li $t2, 0

move $t2, $a2 # size
mul $t2, $t2, $t2

	start_loop:

add $s0, $a0, $t0 # s0 = input + index
add $s1, $a1, $t0 # s1 = output + index
lbu $t1, 0($s0) # load to evaluate

bge $t1, $a3, dark # t1 > treshold value
j light # t1 < treshold value

	dark:
	
li $t1, 0xff
j store

	light:
	
li $t1, 0x00

	store:
	
sb $t1, 0($s1) # store 0x00 or 0xff 

addi $t0, $t0, 1
blt $t0, $t2, start_loop

	end_loop:
					
############################### Part 1: your code ends here ###
jr $ra
###############################################################
###############################################################
#                           PART 2 (Matrix Transform)
#a0: input buffer address
#a1: output buffer address
#a2: transform matrix address
#a3: image dimension  (Image will be square sized, i.e., number of pixels = a3*a3)
###############################################################
transform:
############################### Part 2: your code begins here ##

li $s0, 0 # input address
li $s1, 0 # output address
li $s3, 0 # index input
li $s4, 0 # index output

li $t0, 0 # x
li $t1, 0 # x0
li $t2, 0 # y
li $t3, 0 # y0

li $t4, 0 # temp 
li $t5, 0 # temp
li $t6, 0 # temp

	outer_loop:

addi $t2, $zero, 0 # reset x

		inner_loop:

###################### x0 = Moo x + Mo1 y + M02
lw $t5, 0($a2)
mul $t5, $t5, $t0
lw $t6, 4($a2)
mul $t6, $t6, $t2
lw $t1, 8($a2)
add $t1, $t1, $t5
add $t1, $t1, $t6

###################### y0 = M1o x + M11 y + M12
lw $t5, 12($a2)
mul $t5, $t5, $t0
lw $t6, 16($a2)
mul $t6, $t6, $t2
lw $t3, 20($a2)
add $t3, $t3, $t5
add $t3, $t3, $t6

	bge $t1, $a3, set_zero
	bge $t3, $a3, set_zero
		j next_step

	set_zero:
	li $t4, 0
		j store_value

	next_step:
	mul $s4, $t3, $a3
	add $s4, $s4, $t1
	add $s0, $a0, $s4
	lbu $t4, 0($s0) # load input


	store_value:
	mul $s3, $t2, $a3 
	add $s3, $s3, $t0 
	add $s1, $a1, $s3 # index output = address + s3
	sb $t4, 0($s1)


	addi $t2, $t2, 1
	blt $t2, $a3, inner_loop
		end_inner:

addi $t0, $t0, 1
blt $t0, $a3, outer_loop
	end_outer:

############################### Part 2: your code ends here  ##
jr $ra
###############################################################

###############################################################
#                          Main Function
.globl main
main:

.text

li $v0, 4
la $a0, student_name
syscall
la $a0, new_line
syscall  
la $a0, student_id
syscall 
la $a0, new_line
syscall


# Test threshold function
li $v0, 4
la $a0, t1_str
syscall

la $a0, input_1
la $a1, output_1
li $a2, 2
li $a3, 128
jal threshold

la $a0, i_str
syscall
la $a0, input_1
li $a1, 4
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, po_str
syscall
la $a0, output_1
li $a1, 4
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, eo_str
syscall
la $a0, test_11_expected_output
li $a1, 4
jal print_array
li $v0, 4
la $a0, new_line
syscall
syscall

la $a0, input_2
la $a1, output_2
li $a2, 3
li $a3, 128
jal threshold

la $a0, i_str
syscall
la $a0, input_2
li $a1, 9
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, po_str
syscall
la $a0, output_2
li $a1, 9
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, eo_str
syscall
la $a0, test_12_expected_output
li $a1, 9
jal print_array
li $v0, 4
la $a0, new_line
syscall
syscall

la $a0, input_3
la $a1, output_3
li $a2, 4
li $a3, 128
jal threshold

la $a0, i_str
syscall
la $a0, input_3
li $a1, 16
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, po_str
syscall
la $a0, output_3
li $a1, 16
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, eo_str
syscall
la $a0, test_13_expected_output
li $a1, 16
jal print_array
li $v0, 4
la $a0, new_line
syscall
syscall

# Part 2 testing
#a0 = input array
#a1 = output array
#a2 = matrix
#s3 = input dim
#s4 = test str
#s5 = expected array

la $a0, input_2
la $a1, output_2
la $a2, identity_m
li $a3, 3 # dim
la $s4, t2_str_0
la $s5, test_221_expected_output
jal test_p2

la $a0, input_2
la $a1, output_2
la $a2, rotation_m
li $a3, 3 # dim
la $s4, t2_str_2
la $s5, test_222_expected_output
jal test_p2

########
la $a0, input_3
la $a1, output_3
la $a2, identity_m
li $a3, 4 # dim
la $s4, t2_str_0
la $s5, test_231_expected_output
jal test_p2

la $a0, input_3
la $a1, output_3
la $a2, scale_m
li $a3, 4 # dim
la $s4, t2_str_1
la $s5, test_232_expected_output
jal test_p2

la $a0, input_3
la $a1, output_3
la $a2, rotation_m
li $a3, 4 # dim
la $s4, t2_str_2
la $s5, test_233_expected_output
jal test_p2

la $a0, input_3
la $a1, output_3
la $a2, shear_m
li $a3, 4 # dim
la $s4, t2_str_3
la $s5, test_234_expected_output
jal test_p2


#### Test on images
#open the file for writing
li   $v0, 13       # system call for open file
la   $a0, fin      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, in_buffer   # address of buffer to which to read
la   $a2, in_buffer_end     # hardcoded buffer length
sub $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall

## Copy the header
la $t0, in_buffer
la $t1, out_buffer
lw $t2, ($t0)
sw $t2, ($t1)
lw $t2, 4($t0)
sw $t2, 4($t1)
lw $t2, 8($t0)
sw $t2, 8($t1)
lw $t2, 12($t0)
sw $t2, 12($t1)

# Threshold
la $a0, in_buffer
addi $a0, $a0, 16
la $a1, out_buffer
addi $a1, $a1, 16
li $a2, 512
li $a3, 80
jal threshold 


#open a file for writing
li   $v0, 13       # system call for open file
la   $a0, fout_thresh      # board file name
li   $a1, 1        # Open for writing
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor
# write back
li   $v0, 15       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, out_buffer   # address of buffer to which to read
la   $a2, out_buffer_end     # hardcoded buffer length
subu $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall    


#open the file for writing
li   $v0, 13       # system call for open file
la   $a0, fin      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, in_buffer   # address of buffer to which to read
la   $a2, in_buffer_end     # hardcoded buffer length
sub $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall



## Copy the header
la $t0, in_buffer
la $t1, out_buffer
lw $t2, ($t0)
sw $t2, ($t1)
lw $t2, 4($t0)
sw $t2, 4($t1)
lw $t2, 8($t0)
sw $t2, 8($t1)
lw $t2, 12($t0)
sw $t2, 12($t1)

# Rotate
la $a0, in_buffer
addi $a0, $a0, 16
la $a1, out_buffer
addi $a1, $a1, 16
la $a2, rotation_m
li $a3, 512
jal transform 


#open a file for writing
li   $v0, 13       # system call for open file
la   $a0, fout_rotate      # board file name
li   $a1, 1        # Open for writing
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor
# write back
li   $v0, 15       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, out_buffer   # address of buffer to which to read
la   $a2, out_buffer_end     # hardcoded buffer length
subu $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall



#open the file for writing
li   $v0, 13       # system call for open file
la   $a0, fin      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, in_buffer   # address of buffer to which to read
la   $a2, in_buffer_end     # hardcoded buffer length
sub $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall



## Copy the header
la $t0, in_buffer
la $t1, out_buffer
lw $t2, ($t0)
sw $t2, ($t1)
lw $t2, 4($t0)
sw $t2, 4($t1)
lw $t2, 8($t0)
sw $t2, 8($t1)
lw $t2, 12($t0)
sw $t2, 12($t1)

# Shear
la $a0, in_buffer
addi $a0, $a0, 16
la $a1, out_buffer
addi $a1, $a1, 16
la $a2, shear_m
li $a3, 512
jal transform 


#open a file for writing
li   $v0, 13       # system call for open file
la   $a0, fout_shear      # board file name
li   $a1, 1        # Open for writing
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor
# write back
li   $v0, 15       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, out_buffer   # address of buffer to which to read
la   $a2, out_buffer_end     # hardcoded buffer length
subu $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall




#open the file for writing
li   $v0, 13       # system call for open file
la   $a0, fin      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, in_buffer   # address of buffer to which to read
la   $a2, in_buffer_end     # hardcoded buffer length
sub $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall



## Copy the header
la $t0, in_buffer
la $t1, out_buffer
lw $t2, ($t0)
sw $t2, ($t1)
lw $t2, 4($t0)
sw $t2, 4($t1)
lw $t2, 8($t0)
sw $t2, 8($t1)
lw $t2, 12($t0)
sw $t2, 12($t1)

# scale
la $a0, in_buffer
addi $a0, $a0, 16
la $a1, out_buffer
addi $a1, $a1, 16
la $a2, scale_m
li $a3, 512
jal transform 


#open a file for writing
li   $v0, 13       # system call for open file
la   $a0, fout_scale      # board file name
li   $a1, 1        # Open for writing
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor
# write back
li   $v0, 15       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, out_buffer   # address of buffer to which to read
la   $a2, out_buffer_end     # hardcoded buffer length
subu $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall


_end_program:
# end program
li $v0, 10
syscall
