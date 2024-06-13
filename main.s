.global main  // Declare the main function as a global symbol

.section .text  // Start of the text (code) section
.align 2  // Align the following code on a 4-byte boundary

main:  // Main function entry point
	ldr x0, =termtitle  // Load the address of termtitle into x0
	bl printf  // Call printf to print the terminal title
	
	bl initscr  // Initialize the ncurses screen
	mov x0, #0  // Set x0 to 0 (argument for curs_set)
	bl curs_set  // Set the cursor state to invisible
	bl refresh  // Refresh the screen to update changes
	
	adrp x9, win  // Load the address of the win label into x9
	add x9, x9, :lo12:win  // Add the lower 12 bits of the win label address to x9
	
	mov x0, #1  // Set x0 to 1 (file descriptor for stdout)
	mov x1, #0x5413  // Set x1 to the ioctl request code for getting window size
	ldr x2, =termsize  // Load the address of termsize into x2
	mov x8, #29  // Set x8 to 29 (syscall number for ioctl)
	svc #0  // Make a syscall to ioctl
	
	ldr x19,=termsize  // Load the address of termsize into x19
	
	mov x0, #10  // Set the minimum number of lines for the window
	mov x1, #30  // Set the minimum number of columns for the window
	ldr w4, [x19,#0]  // Load the number of lines from termsize
	mov x5, #2  // Set x5 to 2 for division
	udiv w2, w4, x5  // Divide the number of lines by 2 to find the center
	sub x2, x2, #5  // Adjust the position for the window's top-left corner
	ldr w4, [x19,#2]  // Load the number of columns from termsize
	mov x5, #2  // Set x5 to 2 for division
	udiv w3, w4, x5  // Divide the number of columns by 2 to find the center
	sub x3, x3, #15  // Adjust the position for the window's top-left corner
	bl newwin  // Create a new window with the specified dimensions and position
	str x0, [x9]  // Store the window pointer in win
	
	ldr x0, [x9]  // Load the window pointer from win
	sub sp, sp, #16  // Allocate space on the stack for local variables
	
	str x0, [sp]  // Store the window pointer on the stack
	mov x1, #0  // Set x1 to 0 (vertical position for box)
	mov x2, #0  // Set x2 to 0 (horizontal position for box)
	bl box  // Draw a box around the edges of the window

	ldr x0, [sp]  // Load the window pointer from the stack
	add sp, sp, #16  // Deallocate space from the stack
		
	bl wrefresh  // Refresh the window to show the box

	bl getch  // Wait for a key press
	bl endwin  // End the ncurses session and restore the terminal

	mov x8, 93  // Set x8 to 93 (syscall number for exit)
	mov x0, 0  // Set x0 to 0 (exit status)
	svc 0  // Make a syscall to exit

.section .data  // Start of the data section
termsize: .skip 4  // Reserve 4 bytes for the terminal size
termtitle: .asciz "\033]0;ARMv8 - Ncurses Window (Centered)\007"  // Terminal title string
win:  .quad 0  // Reserve 8 bytes for the window pointer
