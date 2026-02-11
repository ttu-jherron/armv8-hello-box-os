#include "libos.h"

int box(unsigned int srow, unsigned int scol, unsigned int erow, unsigned int ecol);


// Here clear_scr returns 1 on error per spec, but we can return 0 for success
int clear_scr(int start_row, int start_col, int width, int height) {
    // The assignment passes 21, 49, 79, 27
    // we interpret width as end_col and height as end_row, inclusive.
    for (unsigned int r= (unsigned int)start_row; r<= (unsigned int) height; r++) {
        for (unsigned int c = (unsigned int) start_col; c <= (unsigned int) width; c++) {
            putc_to(r,c, ' ');
        }
    }
    return 0;
}

int main(void) {
    // Clear region, then print text at the requestsed coordinates
    clear_scr(21, 49, 79, 27);
    box(21, 49, 27, 79);
    print_to(24, 59, "Hello world");
    return 0;
}