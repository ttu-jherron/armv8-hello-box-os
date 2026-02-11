.global box
.global _box_check_box_
.global _box_draw_corners_
.global _box_draw_top_bottom_
.global _box_draw_right_left_


box:
    // standard entry: save link and stack frame registers
    // load the stack frame with the pointer to current frame
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    // Save the arguments. Called functions may overwrite x0-x3
    sub     sp, sp, 32
    stp     x0, x1, [sp]
    stp     x2, x3, [sp, 16]

    // sr in w0, sc in w1, er int w2, ec in w3

    // Make sure the argument are valid

    bl      _box_check_box_
    cmp     w0, 0
    bne     _box_error_


    // first, draw the corners:
    // +        +
    // +        +
    ldp     x0, x1, [sp]        // this will restore srow, scol into x0,x1
    ldp     x2, x3, [sp, 16]    // this will restore erow, ecol into x2, x3
    bl      _box_draw_corners_

    //mov     w0, 0
    //b       _box_exit_

    // Now, draw the top and bottom:
    // +------+
    // +------+
    ldp     x0, x1, [sp]
    ldp     x2, x3, [sp, 16]
    bl      _box_draw_top_bottom_

    // You figure out what goes here

    // draw left and right slides
    ldp     x0, x1, [sp]
    ldp     x2, x3, [sp, 16]
    bl      _box_draw_right_left_

    // you figure out what goes here

    mov     w0, 0
    b       _box_exit_

_box_error_:
    mov     w0, 1

_box_exit_:
    add     sp, sp, 32  // pop save arg regs 

    ldp     x29, x30, [sp], 16
    ret

    //
    // int _box_check_box_(unsigned int srow, unsined int scol, unsigned int erow, unsigned int ecol);
    // Return 1 if invalid, else 0.
    //

_box_check_box_:
    // Prologue

    stp     x29, x30, [sp, -16]!
    mov     x29, sp 

    // Save args in callee-saved regs (x19-x22) so we can call other funcs 
    stp     x19, x20, [sp, -16]!
    stp     x21, x22, [sp, -16]!

    mov     w19, w0     // srow
    mov     w20, w1     // scol
    mov     w21, w2     // erow
    mov     w22, w3     // ecol

    // width = term_txtwidth()
    bl      term_txtwidth
    mov     w9, w0      // w9 = width

    // height = term_txtheight()
    bl      term_txtheight
    mov     w10, w0     // w10 = height

    // invalid if erow >= height
    cmp     w21, w10
    bhs     _check_invalid

    // invalid if ecol >= width
    cmp     w22, w9
    bhs     _check_invalid

    // invalid if erow <= srow
    cmp     w21, w19
    bls     _check_invalid

    // invalid if ecol <= scol
    cmp     w22, w20
    bls     _check_invalid

    // valid
    mov     w0, 0
    b       _check_done

_box_draw_corners_:
    
    stp     x29, x30, [sp, -16]!
    mov x29, sp

    // Save callee-saved regs
    stp     x19, x20, [sp, -16]!
    stp     x21, x22, [sp, -16]!

    // Save args in w19-w22
    mov     w19, w0     //srow
    mov     w20, w1     //scol
    mov     w21, w2     //erow
    mov     w22, w3     //ecol

    // Top-left: (srow, scol)
    mov     w0, w19
    mov     w1, w20
    mov     w2, #'+' // this char will go into w2
    bl      putc_to

    // Top-right: (srow, ecol)
    mov     w0, w19
    mov     w1, w22
    mov     w2, #'+'
    bl      putc_to

    // Bottom-left: (erow, scol)
    mov     w0, w21
    mov     w1, w20
    mov     w2, #'+'
    bl      putc_to

    // Bottom-right: (erow, ecol)
    mov     w0, w21
    mov     w1, w22
    mov     w2, #'+'
    bl      putc_to

    // Restore regs
    ldp     x21, x22, [sp], 16
    ldp     x19, x20, [sp], 16

    // Epilogue
    ldp     x29, x30, [sp], 16
    ret

_box_draw_top_bottom_:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    // Save callee-saved regs
    stp     x19, x20, [sp, -16]!
    stp     x21, x22, [sp, -16]!
    stp     x23, x24, [sp, -16]!

    // Save args
    mov     w19, w0     // srow
    mov     w20, w1     // scol
    mov     w21, w2     // erow
    mov     w22, w3     // ecol
    

    // col = scol + 1
    add     w23, w20, 1

    // end = ecol -1
    sub     w24, w22, 1

    // draw left and right slides
    ldp     x0, x1, [sp]
    ldp     x2, x3, [sp, 16]
    bl      _box_draw_right_left_


_topbot_loop:
    // while (col <= end)
    cmp     w23, w24
    bgt     _topbot_done

    // putc_to(srow, col, '-')
    mov     w0, w19
    mov     w1, w23
    mov     w2, #'-'
    bl      putc_to

    // putc_to(erow, col, '-')
    mov     w0, w21
    mov     w1, w23
    mov     w2, #'-'
    bl      putc_to

    add     w23, w23, 1
    b       _topbot_loop

_topbot_done:
    // Restore regs
    ldp     x23, x24, [sp], 16
    ldp     x21, x22, [sp], 16
    ldp     x19, x20, [sp], 16

    ldp     x29, x30, [sp], 16
    ret


_box_draw_right_left_:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    // save callee-saved regs
    stp     x19, x20, [sp, -16]!
    stp     x21, x22, [sp, -16]!
    stp     x23, x24, [sp, -16]!

    // Save args
    mov     w19, w0     // srow
    mov     w20, w1     // scol
    mov     w21, w2     // erow
    mov     w22, w3     // ecol

    // row = srow + 1
    add     w23, w19, 1

    // end = erow - 1
    sub     w24, w21, 1

_sides_loop:
    // while (row <= end)
    cmp     w23, w24
    bgt     _sides_done

    // putc_to (row, scol, '|')
    mov     w0, w23
    mov     w1, w20
    mov     w2, #'|'
    bl      putc_to

    // putc_to (row, ecol, '|')
    mov     w0, w23
    mov     w1, w22
    mov     w2, #'|'
    bl      putc_to

    add     w23, w23, 1
    b       _sides_loop

_sides_done:
    // Restore regs
    ldp     x23, x24, [sp], 16
    ldp     x21, x22, [sp], 16
    ldp     x19, x20, [sp], 16

    ldp     x29, x30, [sp], 16
    ret


_check_invalid:
    mov w0, 1

_check_done:
    // restore callee-saved regs 
    ldp     x21, x22, [sp], 16
    ldp     x19, x20, [sp], 16

    // Epilogue
    ldp     x29, x30, [sp], 16
    ret









    // return 0 (success)
    mov     w0, 0

    // standard exit
    ldp     x29, x30, [sp], 16
    ret


