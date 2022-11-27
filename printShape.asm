section .data
    ;string for name
    name:     db 'Niko Arakelyan',10    
    nameLen:  equ $-name       
    ;strings for shapes
    rectangle:     db 'Rectangle',10
    rectangleLen:  equ $-rectangle  
    triangle:     db 'Triangle',10
    triangleLen:  equ $-triangle       
    diamond:     db 'Diamond',10
    diamondLen:  equ $-diamond  
    ;string for the stars that are printed
    star:     db '*'   
    starLen:  equ $-star  
    ;string for a space we'll use for triangles/diamond
    spaceString:     db ' '   
    spaceStringLen:  equ $-spaceString  
    
section .bss
    ;filler variable to skip a new line and to skip a space
    newLine resb 2
    space resb 1
    ;a variable to store the choice of shape
    shapeChoice resb 1
    ;our variables to hold up the different parameters: width (# of columns) and height (# of rows) are for rectangle, base (width of the longest row) is for triangle/diamond
    width resb 2
    height resb 2
    base resb 2
    ;our variables to count up to the parameters during the loops (as well as a counter for the leadingSpaces in triangles and diamonds)
    counterHeight resb 1
    counterStars resb 1 ;essentially a counter for width since width is for # of columns 
    counterBase resb 1
    counterSpaces resb 1
    ;our variables to hold each digit of the parameters
    tensDig resb 2
    onesDig resb 2
    ;a variable to hold the amount of leadingSpaces for printing triangles and diamonds
    leadingSpaces resb 2
    ;a temp variable in between calculations
    temp resb 2


section .text
	global _start

_start:
    ;prints the name at the top before the main loop
	mov eax,4            
	mov ebx,1          
	mov ecx,name       
	mov edx,nameLen                
	int 80h   
again:
    ;reads shape's letter
    mov eax,3
    mov ebx,0
    mov ecx,shapeChoice
    mov edx,1
    int 80h
    
    ;if a period was read, we're at the end of the program and we call end
    cmp [shapeChoice], byte "."
    je end 
    ;else, check to see which shape was read and jump to the approperiate block to print the shape
    cmp [shapeChoice], byte "R"
    je RECTANGLE
    cmp [shapeChoice], byte "T"
    je TRIANGLE
    cmp [shapeChoice], byte "D"
    je DIAMOND

RECTANGLE:
    ;since a rectangle was read, we can expect 2 parameters, so we read space after letter and continue to read parameters
    mov eax,3
    mov ebx,0
    mov ecx,space
    mov edx,1
    int 80h
    ;procedure to read the tens and ones dig and convert to decimal
    call readDigs
    ;reads space after first parameter
    mov eax,3
    mov ebx,0
    mov ecx,space
    mov edx,1
    int 80h
    ;then, we multiply the tens digit by 10 since it's in the tens place, and move it to the height
    mov ax, 0
    mov ax, [tensDig]
    mov bx, 10
    mul bx
    mov [height], ax
    ;finally, we get the ones digit and simply add it it to the height since it's in the ones place
    mov ax, 0
    mov ax, [height]
    add ax, [onesDig]
    mov [height], ax ;our height is now complete
    
    ;continue reading the second parameter, procedure will read each digit and convert to decimal
    call readDigs
    ;uses newline variable to make sure the compiler is ready to read the next line (for subsequent loops)
    mov eax,3
    mov ebx,0
    mov ecx,newLine
    mov edx,2
    int 80h
    ;then, we multiply the tens digit by 10 since it's in the tens place, and move it to the width
    mov ax, 0
    mov ax, [tensDig]
    mov bx, 10
    mul bx
    mov [width], ax
    ;finally, we get the onesDig digit and simply add it it to the width since it's in the ones place
    mov ax, 0
    mov ax, [width]
    add ax, [onesDig]
    mov [width], ax ;our width is now complete
    
    ;prints title of shape
    mov eax,4            
	mov ebx,1          
	mov ecx,rectangle       
	mov edx,rectangleLen                
	int 80h 
    
    ;checks if either height or width is 0, if so just jump back to again and read next line since shape can't be printed
    mov ax, 0
    mov ax, [height]
    cmp ax, byte 0
    je again
    mov bx, 0
    mov bx, [width]
    cmp bx, byte 0
    je again
    
    ;else, just continue on and print the shape like normal
    ;converts the completed parameters from ASCII to decimal for future operations
    sub [height], word '0'
    sub [width], word '0'
    
    ;gets counter for number of stars ready
    mov [counterStars], byte 0
    sub [counterStars], byte '0' ;make sure you sub just a byte
    ;gets counter for height (number of rows) ready
    mov [counterHeight], byte 1
    sub [counterHeight], byte '0' ;make sure you sub just a byte
    
    printRectStars:
        ;prints a star
        call printStar
        ;now that a star is printed, increment the star counter
        inc byte [counterStars] 
        ;then, compare to see if we're at the end of the row
        mov ax, 0
        mov ax, [counterStars]
        cmp al, [width]
        je printNewRectRow ;if the counter is equal to number of stars, jump to get a new row for the rectangle ready
        jmp printRectStars ;else, jump back to print another star and increment until it does match
                 
    
TRIANGLE:
    ;note: base parameter is for base width
    ;since a triangle was read, we can expect 1 parameter, so we read space after letter and continue to read the one parameter
    mov eax,3
    mov ebx,0
    mov ecx,space
    mov edx,1
    int 80h
    ;procedure to read the tens and ones dig and convert to decimal
    call readDigs
    ;uses newline variable to make sure the compiler is ready to read the next line (for subsequent loops)
    mov eax,3
    mov ebx,0
    mov ecx,newLine
    mov edx,2
    int 80h
    ;then, we multiply the tens digit by 10 since it's in the tens place, and move it to the base
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov ax, [tensDig]
    mov bx, 10
    mul bx
    mov [base], ax
    ;finally, we get the ones digit and simply add it it to the base since it's in the ones place
    mov ax, 0
    mov ax, [base]
    add ax, [onesDig]
    mov [base], ax ;our base is now complete
    
    ;prints title of shape
    mov eax,4            
	mov ebx,1          
	mov ecx,triangle       
	mov edx,triangleLen                
	int 80h 
    
    ;checks if shape has a base of 0 (print nothing and jump back to main loop)
    mov ax, [base]
    cmp al, byte 0
    je again

    ;gets counter for base (length of bottom row) ready
    mov [counterBase], byte 1 ;we set it to 1, and will increment by 2 every new triangle row until we match the value of base 
    ;also gets a counter for the # of stars in each row ready
    mov [counterStars], byte 0 
    ;finally, gets a counter for number of spaces printed ready
    mov [counterSpaces], byte 0 

    ;gets the number of leading spaces for the first row, from there we will decrement this by 1 for each row 
    call calcLeadingSpaces
    
    printTriSpaces:
        ;check if we need more spaces
        mov ax, 0
        mov ax, [counterSpaces]
        cmp al, [leadingSpaces]
        je printTriStars ;if we have enough spaces, move on to print the stars for the row
        ;else, continue this block and eventually jump back up to compare again till it matches
        ;prints a space
        call printSpace
        ;now that a space is printed, increment the space counter
        inc byte [counterSpaces] 
        ;jump back to the top of this block to compare again
        jmp printTriSpaces  
    
    printTriStars:
        ;prints a star
        call printStar
        ;now that a star is printed, increment the star counter 
        inc byte [counterStars] 
        
        ;first, check to see if the current # of stars is equal to the base inputted by user; if so, we're at the final row and can jump back to the main loop
        mov ax, 0
        mov ax, [counterStars]
        cmp al, [base]
        je lastTriRow ;jumps to a block that'll print one more new line and then jump back to the main loop (again)
        
        ;otherwise, compares to see if the current row has the correct number of stars or if we need to loop back to add more stars
        cmp al, [counterBase]
        je printNewTriRow ;if the current length is equal to number counter for the base, then the row is finished and we can jump to get a new row for the triangle
        jmp printTriStars ;else, jump back to print another star and increment until it does match
        
    
    
DIAMOND:
    ;note: base in this case means the length of the middle row (longest row)
    ;since a diamond was read, we can expect 1 parameter, so we read space after letter and continue to read the one parameter
    mov eax,3
    mov ebx,0
    mov ecx,space
    mov edx,1
    int 80h
    ;procedure to read the tens and ones dig and convert to decimal
    call readDigs
    ;uses newline variable to make sure the compiler is ready to read the next line (for subsequent loops)
    mov eax,3
    mov ebx,0
    mov ecx,newLine
    mov edx,2
    int 80h
    ;then, we multiply the tens digit by 10 since it's in the tens place, and move it to the base
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov ax, [tensDig]
    mov bx, 10
    mul bx
    mov [base], ax
    ;finally, we get the ones digit and simply add it it to the base since it's in the ones place
    mov ax, 0
    mov ax, [base]
    add ax, [onesDig]
    mov [base], ax ;our base is now complete
    
    ;prints title of shape
    mov eax,4            
	mov ebx,1          
	mov ecx,diamond       
	mov edx,diamondLen                
	int 80h 
    
    ;checks if shape has a base of 0 (print nothing and jump back to main loop)
    mov ax, [base]
    cmp al, byte 0
    je again

    ;gets counter for base (length of middle row) ready
    mov [counterBase], byte 1 ;we set it to 1, and will increment by 2 every new diamond row until we match the value of the middle row (base). then, we'll decrement by 2 till the last row
    ;also gets a counter for the # of stars ready
    mov [counterStars], byte 0 
    ;finally, gets a counter for number of spaces printed ready
    mov [counterSpaces], byte 0 

    ;gets the number of leading spaces for the first row, from there we will decrement this by 1 for each row until the middle row. then, we'll increment by 1 till the last row
    call calcLeadingSpaces

    printDiaSpaces:
        ;check if we need more spaces
        mov ax, 0
        mov ax, [counterSpaces]
        cmp al, [leadingSpaces]
        je printDiaStars ;if we have enough spaces, move on to print the stars for the row
        ;else, continue this block and eventually jump back up to compare again till it matches
        ;prints a space
        call printSpace
        ;now that a space is printed, increment the space counter
        inc byte [counterSpaces] 
        ;jump back to the top of this block to compare again
        jmp printDiaSpaces 
        
    printDiaStars:
        ;prints a star
        call printStar
        ;now that a star is printed, increment the star counter 
        inc byte [counterStars] 
        
        ;first, check to see if the current # of stars is equal to the base inputted by user; if so, we're at the middle row and need to jump to the bottom half blocks
        mov ax, 0
        mov ax, [counterStars]
        cmp al, [base]
        je printNewDiaRowBottom ;jumps to the block that'll print a new row for the bottom half
        
        ;otherwise, compares to see if the current row has the correct number of stars or if we need to loop back to add more stars
        cmp al, [counterBase]
        je printNewDiaRowTop ;if the current length is equal to number counter for the base, then the row is finished and we can jump to get a new row for the diamond
        jmp printDiaStars ;else, jump back to print another star and increment until it does match

    printDiaSpacesBottom:
        ;check if we need more spaces
        mov ax, 0
        mov ax, [counterSpaces]
        cmp al, [leadingSpaces]
        je printDiaStarsBottom ;if we have enough spaces, move on to print the stars for the row
        ;else, continue this block and eventually jump back up to compare again till it matches
        ;prints a space
        call printSpace
        ;now that a space is printed, increment the space counter
        inc byte [counterSpaces] 
        ;jump back to the top of this block to compare again
        jmp printDiaSpacesBottom 
        
    printDiaStarsBottom:
        ;prints a star
        call printStar
        ;now that a star is printed, increment the star counter 
        inc byte [counterStars] 
        ;compares to see if the current row has the correct number of stars or if we need to loop back to add more stars
        mov ax, 0
        mov ax, [counterStars]
        cmp al, [counterBase]
        je printNewDiaRowBottom ;if the current length is equal to number counter for the base, then the row is finished and we can jump to get a new row for the diamond
        jmp printDiaStarsBottom ;else, jump back to print another star and increment until it does match
        

;simple procedures to print stars and lines, read digits, and print/calculate spaces
printStar:
    ;prints a star
	mov eax,4            
	mov ebx,1          
	mov ecx,star       
	mov edx,starLen                
	int 80h 
ret
printNewLine:
    ;prints the new line
    mov eax,4            
    mov ebx,1          
    mov ecx,newLine       
    mov edx,2              
    int 80h 
ret
printSpace:
    ;prints a space (used for triangle and diamond)
    mov eax,4            
    mov ebx,1          
    mov ecx,spaceString       
    mov edx,spaceStringLen          
    int 80h 
ret
readDigs:
    ;reads tensDig
    mov eax,3
    mov ebx,0
    mov ecx,tensDig 
    mov edx,1
    int 80h
    ;reads oneDig
    mov eax,3
    mov ebx,0
    mov ecx,onesDig 
    mov edx,1
    int 80h
    ;converts to decimal
    sub [tensDig], word '0'
    sub [onesDig], word '0'
ret
;The formula for leading spaces is (base - 1)/2
calcLeadingSpaces:
    ;clears variables first
    mov ax, 0
    mov bx, 0
    mov dx, 0
    ;calculates formula and stores in leadingSpaces
    mov ax, [base]
    sub ax, byte 1
    mov [temp], ax
    mov ax, [temp]
    mov bx, 2
    div bx
    mov [leadingSpaces], ax  
ret

printNewRectRow:
    ;calls procedure that prints new line
    call printNewLine
    ;compares the counter to the number of rows read (height) and sees if we're at final row or not
    mov ax, 0
    mov ax, [counterHeight]
    cmp al, [height]
    je again ;if counter matches number of rows, the shape is done printing and we can jump back to the main loop to read the next line
    
    ;if it doesn't match, this code will compile, which leads to printing another row of stars
    inc byte [counterHeight]  ;increments the counter for height since we're going to start a new line
    
    ;resets the counter for stars so subsequent loops don't use the old value for number of stars
    mov [counterStars], byte 0
    sub [counterStars], byte '0' ;make sure you sub just a byte
    ;now that a new line is printed and we know there's another row to print, jump back to print more rectangle stars
    jmp printRectStars
    
    
printNewTriRow:
    ;calls procedure that prints new line
    call printNewLine
    ;we know that there needs to be another row, so increment the counterBase variable by 2 so the next line has 2 more stars
    inc byte [counterBase]
    inc byte [counterBase]
    ;resets the counter for stars and spaces so subsequent loops don't use the old values
    mov [counterStars], byte 0
    mov [counterSpaces], byte 0
    ;the next row will always have 1 less leading space than the row above it, so we can just decrement the leadingSpaces variable for the upcoming row
    ;for example, take an input of 07 - as you can see, the number of leadingSpaces decreases by 1 every row
    ;xxx*xxx
    ;xx***xx
    ;x*****x
    ;*******
    dec byte [leadingSpaces]
    ;then, jump back to print the spaces 
    jmp printTriSpaces
    
;the last triangle row doesn't skip a line so this block will, and then jump to again to read the next shape
lastTriRow:
    ;calls procedure that prints new line (for the next shape)
    call printNewLine
    ;jumps back to the main loop
    jmp again
    
printNewDiaRowTop:
    ;calls procedure that prints new line
    call printNewLine
    ;we know that there needs to be another row, so increment the counterBase variable by 2 so the next line has 2 more stars
    inc byte [counterBase]
    inc byte [counterBase]
    ;resets the counter for stars and spaces so subsequent loops don't use the old values
    mov [counterStars], byte 0
    mov [counterSpaces], byte 0
    ;the next row will always have 1 less leading space than the row above it, so we can just decrement the leadingSpaces variable for the upcoming row
    ;for example, take the top half of an input of 07 - as you can see, the number of leadingSpaces decreases by 1 every row
    ;xxx*xxx
    ;xx***xx
    ;x*****x
    ;*******
    dec byte [leadingSpaces]
    ;then, jump back to print the spaces 
    jmp printDiaSpaces
    
printNewDiaRowBottom:
    ;calls procedure that prints new line
    call printNewLine
    ;then, we must check if we're on the final row - since we're on the bottom half, having a counterStars of 1 means that we printed the final row (only the first/bottom row have one star)
    mov ax, [counterStars]
    cmp al, byte 1
    je again ;if counterStars was 1, then we just printed the last row and can return to the main loop
    ;else, just move on and process the next row like normal
    ;we know that there needs to be another row, and we're now in the bottom half, so decrement the counterBase variable by 2 so the next line has 2 less stars
    dec byte [counterBase]
    dec byte [counterBase]
    ;resets the counter for stars and spaces so subsequent loops don't use the old values
    mov [counterStars], byte 0
    mov [counterSpaces], byte 0
    ;the next row will always have 1 more leading space than the row above it, so we can just increment the leadingSpaces variable for the upcoming row
    ;for example, take the bottom half of an input of 07 - as you can see, the number of leadingSpaces increases by 1 every row
    ;*******
    ;x*****x
    ;xx***xx
    ;xxx*xxx
    inc byte [leadingSpaces]
    ;then, jump back to print the spaces 
    jmp printDiaSpacesBottom
    
;terminates
end:
    mov eax,1 
    mov ebx,0 
    int 80h
