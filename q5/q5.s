# ============================================================================
# q5.s - Palindrome checker for arbitrarily large file
# Reads "input.txt" character by character from both ends using lseek.
# Outputs "Yes" if palindrome, "No" otherwise.
# Time: O(n), Space: O(1)
# ============================================================================

.section .text
.globl main

main:
    # Save registers
    addi sp, sp, -32
    sd ra, 0(sp)
    sd s0, 8(sp)   # file descriptor
    sd s1, 16(sp)  # file size
    sd s2, 20(sp)  # left index
    sd s3, 24(sp)  # right index

    # Open input.txt (read-only)
    la a0, filename
    li a1, 0        # O_RDONLY
    li a2, 0
    li a7, 56       # sys_open
    ecall
    mv s0, a0
    blt a0, x0, error_open

    # Get file size: lseek(fd, 0, SEEK_END)
    mv a0, s0
    li a1, 0
    li a2, 2        # SEEK_END
    li a7, 62       # sys_lseek
    ecall
    mv s1, a0
    blt a0, x0, error_lseek

    # Seek back to start
    mv a0, s0
    li a1, 0
    li a2, 0        # SEEK_SET
    li a7, 62
    ecall

    # Initialize indices
    li s2, 0                # left = 0
    addi s3, s1, -1         # right = size - 1

    # Main comparison loop
compare_loop:
    bge s2, s3, is_palindrome   # left >= right -> done

    # Read character at left position
    mv a0, s0
    mv a1, s2
    li a2, 0
    li a7, 62
    ecall
    mv a0, s0
    la a1, buffer
    li a2, 1
    li a7, 63               # sys_read
    ecall
    lb t0, buffer

    # Read character at right position
    mv a0, s0
    mv a1, s3
    li a2, 0
    li a7, 62
    ecall
    mv a0, s0
    la a1, buffer
    li a2, 1
    li a7, 63
    ecall
    lb t1, buffer

    # Compare
    bne t0, t1, not_palindrome

    # Move inward
    addi s2, s2, 1
    addi s3, s3, -1
    j compare_loop

is_palindrome:
    la a0, yes_msg
    li a7, 64               # sys_write
    li a2, 4                # "Yes\n" length
    ecall
    j close_and_exit

not_palindrome:
    la a0, no_msg
    li a7, 64
    li a2, 3                # "No\n" length
    ecall
    j close_and_exit

error_open:
    la a0, no_msg
    li a7, 64
    li a2, 3
    ecall
    j exit

error_lseek:
    mv a0, s0
    li a7, 57               # sys_close
    ecall
    la a0, no_msg
    li a7, 64
    li a2, 3
    ecall

close_and_exit:
    mv a0, s0
    li a7, 57
    ecall

exit:
    li a0, 0
    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    ld s2, 20(sp)
    ld s3, 24(sp)
    addi sp, sp, 32
    ret

.section .data
filename: .string "input.txt"
buffer:   .byte 0
yes_msg:  .string "Yes\n"
no_msg:   .string "No\n"