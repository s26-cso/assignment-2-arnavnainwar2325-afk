# ============================================================================
# q2.s - Next Greater Element (NGE) using Stack
# Find the next greater element to the right for each array element
# Input: Command line arguments (space-separated integers)
# Output: Space-separated indices of next greater elements (-1 if none)
# Time: O(n), Space: O(n)
# ============================================================================

.section .text

# ----------------------------------------------------------------------------
# main - Entry point
# Arguments: argc in a0, argv in a1
# Returns: exit code in a0
# ----------------------------------------------------------------------------
.globl main
main:
    addi sp, sp, -48
    sd ra, 0(sp)
    sd s0, 8(sp)
    sd s1, 16(sp)
    sd s2, 20(sp)
    sd s3, 24(sp)
    sd s4, 28(sp)
    sd s5, 32(sp)
    sd s6, 36(sp)
    sd s7, 40(sp)
    
    # Save argc and argv
    mv s0, a0               # s0 = argc
    mv s1, a1               # s1 = argv
    
    # Edge case: No arguments (just program name)
    addi t0, s0, -1         # t0 = n = argc - 1
    ble t0, x0, empty_input
    
    # Allocate array for values (n * 4 bytes)
    mv s2, t0               # s2 = n
    slli a0, s2, 2          # a0 = n * 4 bytes
    call malloc
    mv s3, a0               # s3 = values array pointer
    
    # Allocate array for result (n * 4 bytes)
    slli a0, s2, 2
    call malloc
    mv s4, a0               # s4 = result array pointer
    
    # Allocate stack for indices (n * 4 bytes)
    slli a0, s2, 2
    call malloc
    mv s5, a0               # s5 = stack array pointer
    li s6, 0                # s6 = stack top index (-1 = empty)
    addi s6, s6, -1         # Initialize to -1 (empty stack)
    
    # Parse command line arguments into values array
    li s7, 0                # s7 = loop counter i = 0
    addi t0, s1, 8          # t0 = argv[1] (skip program name)
    
parse_loop:
    bge s7, s2, parse_done
    
    # Load argument string
    ld t1, 0(t0)            # t1 = argv[i+1]
    mv a0, t1
    call atoi               # Convert string to int
    sw a0, 0(s3)            # values[i] = converted int
    
    addi s7, s7, 1          # i++
    addi t0, t0, 8          # Next argv pointer
    j parse_loop
    
parse_done:
    # ========================================================================
    # Next Greater Element Algorithm
    # Process array from right to left using stack
    # ========================================================================
    
    li s7, 0                # Initialize result array to -1
init_result:
    bge s7, s2, init_done
    li t0, -1
    sw t0, 0(s4)            # result[i] = -1
    addi s4, s4, 4          # Move result pointer (temporary)
    addi s7, s7, 1
    j init_result
init_done:
    sub s4, s4, s2, 2       # Restore result pointer to start (s4 = s4 - n*4)
    slli t0, s2, 2
    sub s4, s4, t0
    
    # Main algorithm loop: for i from n-1 down to 0
    addi s7, s2, -1         # s7 = i = n-1
    
algorithm_loop:
    blt s7, x0, algorithm_done
    
    # While stack not empty AND values[stack.top] <= values[i]
    # Pop from stack
    blt s6, x0, process_stack  # if stack not empty
    j check_stack_empty
    
process_stack:
    # Get stack top index
    slli t0, s6, 2          # t0 = top * 4
    add t1, s5, t0          # t1 = &stack[top]
    lw t2, 0(t1)            # t2 = stack[top]
    
    # Get values[stack.top] and values[i]
    slli t3, t2, 2          # t3 = stack_top_idx * 4
    add t4, s3, t3          # t4 = &values[stack_top_idx]
    lw t5, 0(t4)            # t5 = values[stack.top]
    
    slli t3, s7, 2          # t3 = i * 4
    add t4, s3, t3          # t4 = &values[i]
    lw t6, 0(t4)            # t6 = values[i]
    
    # Compare values[stack.top] and values[i]
    ble t5, t6, pop_stack   # if stack_val <= current_val, pop
    j set_result
    
pop_stack:
    addi s6, s6, -1         # stack.pop()
    j process_stack         # Continue checking
    
check_stack_empty:
    # If stack empty, result[i] stays -1
    j push_current
    
set_result:
    # result[i] = stack.top
    sw t2, 0(s4)            # Store at result[i] (offset already handled)
    
push_current:
    # Push current index onto stack
    addi s6, s6, 1          # top++
    slli t0, s6, 2          # t0 = top * 4
    add t1, s5, t0          # t1 = &stack[top]
    sw s7, 0(t1)            # stack[top] = i
    
    # Move to next index (decrement i)
    addi s4, s4, 4          # Move result pointer (we store from left to right)
    addi s7, s7, -1         # i--
    j algorithm_loop
    
algorithm_done:
    # Reset result pointer to beginning
    sub s4, s4, s2, 2
    slli t0, s2, 2
    sub s4, s4, t0
    
    # ========================================================================
    # Output results
    # ========================================================================
    
    li s7, 0                # s7 = i = 0
    
print_loop:
    bge s7, s2, print_done
    
    # Load result[i]
    slli t0, s7, 2
    add t1, s4, t0
    lw a0, 0(t1)            # a0 = result[i]
    call print_int          # Print integer
    
    # Print space (except after last element)
    addi t0, s7, 1
    beq t0, s2, print_done
    li a0, ' '
    call print_char
    
    addi s7, s7, 1
    j print_loop
    
print_done:
    # Print newline
    li a0, '\n'
    call print_char
    
    # Free allocated memory
    mv a0, s3
    call free
    mv a0, s4
    call free
    mv a0, s5
    call free
    
    li a0, 0                # Return 0
    j main_end
    
empty_input:
    # No numbers provided - just print newline
    li a0, '\n'
    call print_char
    li a0, 0
    
main_end:
    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    ld s2, 20(sp)
    ld s3, 24(sp)
    ld s4, 28(sp)
    ld s5, 32(sp)
    ld s6, 36(sp)
    ld s7, 40(sp)
    addi sp, sp, 48
    ret

# ============================================================================
# Helper Functions
# ============================================================================

# ----------------------------------------------------------------------------
# atoi - Convert ASCII string to integer
# @param a0: char* string
# @return a0: int
# ----------------------------------------------------------------------------
.globl atoi
atoi:
    li t0, 0                # result = 0
    li t1, 1                # sign = 1
    lb t2, 0(a0)            # first char
    
    # Check for negative sign
    li t3, '-'
    bne t2, t3, atoi_loop
    
    li t1, -1               # sign = -1
    addi a0, a0, 1          # skip '-'
    
atoi_loop:
    lb t2, 0(a0)
    beq t2, x0, atoi_done   # end of string
    li t3, '0'
    blt t2, t3, atoi_done   # not a digit
    li t3, '9'
    bgt t2, t3, atoi_done   # not a digit
    
    # result = result * 10 + (digit)
    li t3, 10
    mul t0, t0, t3
    addi t2, t2, -48        # convert ASCII to digit
    add t0, t0, t2
    
    addi a0, a0, 1
    j atoi_loop
    
atoi_done:
    mul a0, t0, t1
    ret

# ----------------------------------------------------------------------------
# print_int - Print integer to stdout
# @param a0: int to print
# ----------------------------------------------------------------------------
.globl print_int
print_int:
    addi sp, sp, -32
    sd ra, 0(sp)
    sd s0, 8(sp)
    sd s1, 16(sp)
    
    li t0, 0
    mv s0, a0               # save number
    li t1, 10               # divisor
    
    # Handle negative numbers
    bge s0, x0, print_int_positive
    li a0, '-'
    call print_char
    neg s0, s0
    
print_int_positive:
    # Convert to string in reverse
    la s1, print_buffer_end
    addi s1, s1, -1         # point to last char
    
print_int_loop:
    rem t0, s0, t1          # t0 = digit
    div s0, s0, t1          # s0 = s0 / 10
    addi t0, t0, '0'        # convert to ASCII
    sb t0, 0(s1)            # store in buffer
    addi s1, s1, -1         # move backward
    bnez s0, print_int_loop
    
    # Print the string
    addi s1, s1, 1          # move to first digit
    mv a0, s1
    call print_string
    
    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    addi sp, sp, 32
    ret

# ----------------------------------------------------------------------------
# print_string - Print string to stdout
# @param a0: char* string
# ----------------------------------------------------------------------------
.globl print_string
print_string:
    addi sp, sp, -16
    sd ra, 0(sp)
    
    mv t0, a0
print_string_loop:
    lb a0, 0(t0)
    beq a0, x0, print_string_done
    call print_char
    addi t0, t0, 1
    j print_string_loop
    
print_string_done:
    ld ra, 0(sp)
    addi sp, sp, 16
    ret

# ----------------------------------------------------------------------------
# print_char - Print single character to stdout
# @param a0: char to print
# ----------------------------------------------------------------------------
.globl print_char
print_char:
    li a7, 11               # RISC-V Linux syscall for print_char
    ecall
    ret

# ============================================================================
# Data Section
# ============================================================================
.section .data
print_buffer:
    .space 32               # Buffer for integer to string conversion
print_buffer_end: