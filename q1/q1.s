# ============================================================================
# BST Implementation (RISC-V)
# struct Node { int val; Node* left; Node* right; };  // 24 bytes
# ============================================================================

.section .text

# ----------------------------------------------------------------------------
# make_node(int val) -> Node*
# ----------------------------------------------------------------------------
.globl make_node
make_node:
    addi sp, sp, -16
    sd ra, 0(sp)
    sd s0, 8(sp)
    mv s0, a0               # save val
    li a0, 24
    call malloc
    beq a0, x0, 1f          # malloc failed -> return NULL
    sw s0, 0(a0)            # val
    sd x0, 8(a0)            # left = NULL
    sd x0, 16(a0)           # right = NULL
    j 2f
1:  mv a0, x0
2:  ld ra, 0(sp)
    ld s0, 8(sp)
    addi sp, sp, 16
    ret

# ----------------------------------------------------------------------------
# insert(Node* root, int val) -> Node*
# ----------------------------------------------------------------------------
.globl insert
insert:
    addi sp, sp, -32
    sd ra, 0(sp)
    sd s0, 8(sp)
    sd s1, 16(sp)
    mv s0, a0               # root
    mv s1, a1               # val
    beq s0, x0, insert_empty
    lw t0, 0(s0)            # root->val
    beq s1, t0, insert_done
    blt s1, t0, insert_left
    # insert right
    ld a0, 16(s0)
    mv a1, s1
    call insert
    sd a0, 16(s0)
    j insert_done
insert_left:
    ld a0, 8(s0)
    mv a1, s1
    call insert
    sd a0, 8(s0)
    j insert_done
insert_empty:
    mv a0, s1
    call make_node
    mv s0, a0
insert_done:
    mv a0, s0
    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    addi sp, sp, 32
    ret

# ----------------------------------------------------------------------------
# get(Node* root, int val) -> Node*
# ----------------------------------------------------------------------------
.globl get
get:
    beq a0, x0, get_not_found
    addi sp, sp, -16
    sd ra, 0(sp)
    sd s0, 8(sp)
    mv s0, a0
    lw t0, 0(s0)
    beq a1, t0, get_found
    blt a1, t0, get_left
    ld a0, 16(s0)
    mv a1, a1
    call get
    j get_return
get_left:
    ld a0, 8(s0)
    mv a1, a1
    call get
get_return:
    ld ra, 0(sp)
    ld s0, 8(sp)
    addi sp, sp, 16
    ret
get_found:
    mv a0, s0
    ld ra, 0(sp)
    ld s0, 8(sp)
    addi sp, sp, 16
    ret
get_not_found:
    li a0, 0
    ret

# ----------------------------------------------------------------------------
# getAtMost(int val, Node* root) -> int (greatest <= val, or -1)
# ----------------------------------------------------------------------------
.globl getAtMost
getAtMost:
    addi sp, sp, -32
    sd ra, 0(sp)
    sd s0, 8(sp)
    sd s1, 16(sp)
    mv s0, a1               # root
    mv s1, a0               # target
    beq s0, x0, empty
    lw s2, 0(s0)            # current value
    beq s2, s1, exact
    bgt s2, s1, search_left
    # current < target: candidate = current, check right
    ld a0, 16(s0)
    mv a1, s1
    call getAtMost
    li t0, -1
    beq a0, t0, use_current
    j done
search_left:
    ld a0, 8(s0)
    mv a1, s1
    call getAtMost
    li t0, -1
    beq a0, t0, no_candidate
    j done
use_current:
    mv a0, s2
    j done
exact:
    mv a0, s2
    j done
empty:
    li a0, -1
    j done
no_candidate:
    li a0, -1
done:
    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    addi sp, sp, 32
    ret