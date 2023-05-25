##########################################################################################################
#------------------------------------------------Readme---------------------------------------------------
# The program uses two main ideas to implement binary, quadratic, and octal conversions of decimal integer
#
# For non-negative types of input, I use the classic conversion method,using the division and get the 
# remainder to get the converted expression step by step, the registers and details used in this way will 
# be explained in detail in the corresponding part of the subsequent code.
#
# For negative type input, I first convert the input negative number to an integer equal to its absolute 
# value, and after getting the correct binary expression, use the binary complement conversion to convert 
# it to the correct expression in negative form.
# The negative expressions in quadrature and octal are converted from the binary complement expressions 
# by converting every two binary complements to quadrature complements and every three binary complements 
# to octal complements. The use of registers and code details will be explained in detail in the relevant 
# section.
##########################################################################################################
    .data    # all the data will used are declared here
ask:       .asciiz "Enter a number: "
display:   .asciiz "Input number is "
restart:   .asciiz "\nContinue? (1=Yes/0=No): "
output1:   .asciiz "\nBinary: "
output2:   .asciiz "\nQuaternary: "
output3:   .asciiz "\nOctal: "
output4:   .asciiz "Bye! "
number1:   .space 33
number2:   .space 17
number3:   .space 12

#########################################################################################################
# Registers used in code (main)
# $s0 -> store input int(10)
# $t1 -> (only used when input is negative) store one bit of tha array, convenient for compare
# $t2 -> the flag for continue(1 or 0) to control the loop
# $t3 -> store the address of the current location in the arrays, also a very important counter
# $t4 -> used to initialize or change the value of an element in an array, usually 1 or 0 (ASCII type)
# $t5 -> always be 1 a const number, because "sub" not support for immediate number
# $t6 -> used in division to represent the divisor, i.e. represent 2,4,8 
# $t7 -> used to store the remainder
# $t8 -> used to store the quotient
# $t9 -> a copy of the input int (10)
# Notice: some registers will have different usage when input is negative!! (see detail in negative part)
#########################################################################################################
    .text
    .globl main
main:
Loop:
    la $a0, ask               # The input sentence
    li $v0, 4
    syscall

    li $v0, 5                 # Read in the input int
    syscall
    move $s0, $v0

    la $a0, display           # The display sentence to show the input int (10)
    li $v0, 4
    syscall

    li $v0, 1                 # Display the input int (10)
    move $a0, $s0
    syscall

    blt $s0, 0, negative      # Detect if the input is negative

    li $t3, 0                 # Initialize the registers that will be used in the later operations
    li $t4, 0
    li $t5, 1
    li $t6, 2
    li $t7, 0
    li $t8, 0
    add $t9, $zero, $s0       # copy the input for convenience

# Binary compute
BL1:                          
    # The BL1(Binary Loop 1) part represents the initialization of the binary array,
    # this loop will fill the array with zeros and store the address of 
    # the last bit of the array in $t3 at the end.

    addiu $t4, $zero, 48      # add 48 to change the int type in to ASCII type so it can be store in the array
    sb $t4, number1($t3)      
    addi $t3, $t3, 1
    bne $t3, 32, BL1
    sub $t3, $t3, $t5
BL2:                          # The BL2(Binary Loop 2) part uses the method of successive division
    div $t9, $t6              # to obtain the binary expression of the input number and
    mfhi $t7                  # stores it in an array by backward division, and then types it out.
    mflo $t8
    move $t9, $t8

    addiu $t7, $t7, 48        # After store the remainder in right locaton make the address - 1 
    sb $t7, number1($t3)      # so that it ready for next store operation
    sub $t3, $t3, $t5
    bne $t8, 0, BL2

    la $a0, output1           # Print out the whole array
    li $v0, 4 
    syscall

    la $a0, number1
    li $v0, 4
    syscall

# Quaternary compute
    li $t3, 0
    li $t4, 0
    li $t6, 4                 # change 2 to 4, switch Binary mode to Quaternary mode

    add $t9, $zero, $s0

QL1:
    addiu $t4, $zero, 48      # the same structure of the Binary mode
    sb $t4, number2($t3)
    addi $t3, $t3, 1
    bne $t3, 16, QL1
    sub $t3, $t3, $t5
QL2:
    div $t9, $t6
    mfhi $t7
    mflo $t8
    move $t9, $t8

    addiu $t7, $t7, 48
    sb $t7, number2($t3)
    sub $t3, $t3, $t5
    bne $t8, 0, QL2

    la $a0, output2
    li $v0, 4
    syscall

    la $a0, number2
    li $v0, 4
    syscall

# Octal compute
    li $t3, 0
    li $t4, 0
    li $t6, 8                 # change 2 to 4, switch Quaternary mode to Octal mode
    add $t9, $zero, $s0

OL1:
    addiu $t4, $zero, 48      # the same structure of the Binary mode
    sb $t4, number3($t3)
    addi $t3, $t3, 1

    bne $t3, 11, OL1

    sub $t3, $t3, $t5
OL2:
    div $t9, $t6
    mfhi $t7
    mflo $t8
    move $t9, $t8

    addiu $t7, $t7, 48
    sb $t7, number3($t3)
    sub $t3, $t3, $t5
    bne $t8, 0, OL2

    la $a0, output3
    li $v0, 4
    syscall

    la $a0, number3
    li $v0, 4
    syscall

    j Afterloop               # jump the nagative part

####################################################################################
# In negative mode, some registers have different use compare with normal mode above
# because the The quadrature and octal in negative mode are implemented based on the
# conversion of binary in complementary form.
####################################################################################
#Negative Binary
negative:
    subu $s0, $0, $s0         # Converting a negative number to its absolute value
    li $t3, 0                 # Initialize the registers that will be used in the later operations
    li $t4, 0
    li $t5, 1
    li $t6, 2
    li $t7, 0
    li $t8, 0
NBL1:
    addiu $t4, $zero, 48      # the same structure of the Binary mode
    sb $t4, number1($t3)
    addi $t3, $t3, 1
    bne $t3, 32, NBL1
    sub $t3, $t3, $t5
NBL2:
    div $s0, $t6
    mfhi $t7
    mflo $t8
    move $s0, $t8

    addiu $t7, $t7, 48
    sb $t7, number1($t3)
    sub $t3, $t3, $t5
    bne $t8, 0, NBL2

    li $t3, 0                  # set $t3 location to the begining of the array for later getting the Binary Complement
NBL3:                          # part NBL3 to Judge is a loop to change the value in array(0 -> 1 and 1 -> 0)
    li $t4, 0
    lb $t1, number1($t3)
    bne $t1, 48, Not0          # compare in ASCII type (48 represent 0)
Is0:
    addiu $t4, $t4, 49         # 49 represent 1
    sb $t4, number1($t3)
    j Judge
Not0:
    addiu $t4, $t4, 48
    sb $t4, number1($t3)
Judge:
    addi $t3, $t3, 1
    bne $t3, 32, NBL3
    li $t3, 31
Add1:                          # after the loop above, the number need to add 1 to become the right Binary Complement
    li $t4, 0
    lb $t1, number1($t3)
    beq $t1, 48, NoCarry
Carry:                         # if there is already 1 in the location 1+1=10, which means there will be a carry bit
    addiu $t4, $t4, 48
    sb $t4, number1($t3)
    sub $t3, $t3, $t5
    j Add1                     # because there is a carry bit, so after change the value, it need to back to "Add1" part
NoCarry:
    addiu $t4, $t4, 49         # if there is a 0 in the location, there will be no carry bit, so this time the Binary Complement is right
    sb $t4, number1($t3)

    la $a0, output1            # output the answer
    li $v0, 4
    syscall

    la $a0, number1
    li $v0, 4
    syscall

#Negative Quaternary
#
# Quadratic complement is implemented on the basis of binary complement. converts every 
# two bits of a binary expression into one bit of quadrature. Therefore the role of 
# certain registers will change.
#
    li $t1, 0                   # $t1 represents the current location point in Binary array
    li $t2, 0                   # $t2 represents the current location point in Quaternary array
    li $t5, 48                  # $t5 store the const number 48

NQL:
    lb $t3, number1($t1)        # $t3 store the first bit of every two bits in Binary array
    addi $t1, $t1, 1            # $t4 store the second bit of every two bits in Binary array
    lb $t4, number1($t1)
    addi $t1, $t1, 1
    sub $t3, $t3, $t5           # change the ASCII type to int so that they can be compute correctly
    sub $t4, $t4, $t5
    sll $t3, $t3, 1             # $t3 = $t3 * 2
    addu $t3, $t3, $t4          # add to value
    addiu $t3, $t3, 48          # change it to ASCII type and store in the Quaternary array
    sb $t3, number2($t2)
    addi $t2, $t2, 1
    bne $t2, 16, NQL            # do the loop until every two bits have been convert

    la $a0, output2             # output the answer
    li $v0, 4
    syscall

    la $a0, number2
    li $v0, 4
    syscall

#Negative Octal
    li $t1, 0                   # similar structure with above
    li $t2, 0

    lb $t3, number1($t1)        # Because the binary complement has only thirty-two bits and is not 
    addi $t1, $t1, 1            # divisible by 3, the first two bits need to be handled separately
    lb $t4, number1($t1)
    addi $t1, $t1, 1

    sub $t3, $t3, $t5
    sub $t4, $t4, $t5
    sll $t3, $t3, 1
    addu $t3, $t3, $t4
    addiu $t3, $t3, 48
    sb $t3, number3($t2)
    addi $t2, $t2, 1

NOL:
    lb $t3, number1($t1)        # similar structure with the Negative Quaternary mode
    addi $t1, $t1, 1            # Here, three bits are taken out at a time and the result will store in an 
    lb $t4, number1($t1)        # octal array until every bit of the binary array has been calculated
    addi $t1, $t1, 1
    lb $t6, number1($t1)
    addi $t1, $t1, 1
    sub $t3, $t3, $t5
    sub $t4, $t4, $t5
    sub $t6, $t6, $t5
    sll $t3, $t3, 2
    sll $t4, $t4, 1

    addu $t3, $t3, $t4
    addu $t3, $t3, $t6
    addiu $t3, $t3, 48
    sb $t3, number3($t2)
    addi $t2, $t2, 1
    bne $t2, 11, NOL

    la $a0, output3             # output the answer
    li $v0, 4
    syscall

    la $a0, number3
    li $v0, 4
    syscall

Afterloop:
    la $a0, restart            # after all the result fot one number is printed out
    li $v0, 4                  # the programme will reach here
    syscall

    li $v0, 5                  # read in the input as int
    syscall
    move $t2, $v0

    beq $t2, 1, Loop           # if == 1, it will back to top and excuted again

    la $a0, output4
    li $v0, 4
    syscall

    li $v0, 10                 # Syscall number 10 is to terminate the program
    syscall                    # exit