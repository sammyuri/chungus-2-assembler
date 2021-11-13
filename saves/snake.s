// SETUP
.PAGE:0
// setup directions
// ASSUMES MEMORY INITIALISED TO ZEROES!!!!
LIM R1, 1
LIM R2, -1
MST R1, 131
MST R2, 138
MST R1, 148
MST R2, 150

// setup queue
MST R1, 0  // initial snake directions
MST R1, 1
MST R1, 162  // front of queue
LIM R1, 127  // back of queue
MST R1, 163

// setup graphics
PST R0, 68  // clear screen and character display
PST R0, 70
LIM R0, 0b01101111  // snake head sprite
PST R0, 96
LIM R0, 0b11110110
PST R0, 104
LIM R0, 16  // draw initial snake head
PST R0, 64
LIM R0, 12
PST R0, 65
PST R0, 112
LIM R0, 9  // draw initial snake body
PST R0, 64
LIM R0, 13
PST R0, 65
LIM R0, 15
PST R0, 66
LIM R0, 14
PST R0, 87

// setup snake in memory
LIM R1, 4  // snake head
LIM R2, 3
LIM R3, 2  // snake tail
LIM R4, 3

// setup food and score
CAL .generatefood  // generate food
MST R0, 164  // reset score
PST R0, 74  // output initial score (0)
PST R0, 78
LIM R0, "S"  // set character display to "SCORE"
PST R0, 72
LIM R0, "C"
PST R0, 72
LIM R0, "O"
PST R0, 72
LIM R0, "R"
PST R0, 72
LIM R0, "E"
PST R0, 72
LIM R0, ":"
PST R0, 72
PLD R0, 69  // buffer screen and wait until it's ready

// let the game begin!
JMP .mainloop



// FOOD AND DEATH
.PAGE:1
.generatefood
PLD R5, 1  // get random coordinates on screen as candidate location
AIM R5, 7
MST R5, 128  // store to memory
PLD R6, 1  // y
AIM R6, 7
MST R6, 129

BSLI R5, R5, 2  // upscale coordinates
ADI R5, R5, 1
BSLI R6, R6, 2
ADI R6, R6, 1
PST R5, 64  // load x and y to screen
PST R6, 65
PLD R7, 71  // check if space is already occupied
BRN NZERO, .generatefood

ADI R5, R5, 1  // draw food on screen
PST R5, 66
ADI R6, R6, 1
PST R6, 87  // draw rectangle
RET  // return

.eatfood
CAL .generatefood  // generate new food

MLD R6, 164  // increment score
ADI R6, R6, 1
MST R6, 164
PST R6, 78  // output score
JMP .drawhead  // skip erasing tail - snake gets 1 longer

.ded
LIM R0, "Y"  // output "YOU DIED!"
PST R0, 73
LIM R0, "O"
PST R0, 73
LIM R0, "U"
PST R0, 73
LIM R0, "@"
PST R0, 73
LIM R0, "D"
PST R0, 73
LIM R0, "I"
PST R0, 73
LIM R0, "E"
PST R0, 73
LIM R0, "D"
PST R0, 73
LIM R0, "!"
PST R0, 73
PST R0, 69  // buffer screen
HLT  // game over!

// NOTE: this is part of main loop! (the end of it)
.drawhead
BSLI R5, R1, 2  // get upscaled coords
BSLI R6, R2, 2
PST R5, 64  // load coords and draw head sprite
PST R6, 65
PST R0, 112
PST R0, 69  // buffer screen
JMP .mainloop  // repeat!



// MAIN LOOP
.PAGE:2
.mainloop
PLD R7, 0  // get direction
PSH R7  // push to stack for later
MLD R5, 162  // get front of queue
POI R5
MLD R6, 0  // get previous direction
ADI R5, R5, 1  // increment
AIM R5, 0b01111111
POI R5  // add direction to queue
MST R7, 0
MST R5, 162

TZR R6, R6
LIM R0, 0b00001000  // invert previous head direction
BSR R6, R0, R6
OR R7, R7, R6  // get both directions in one byte

// update previous head
PSH R4  // setup
BSLI R5, R1, 2
BSLI R6, R2, 2

NOR R7, R0, R7  // check if RIGHT should be erased
BRN EVEN, .skipright
ADI R4, R5, 3  // load x
PST R4, 64
ADI R4, R6, 1  // load y1 and erase
PST R4, 91
ADI R4, R4, 1  // load y2 and erase
PST R4, 91

.skipright
BSRI R7, R7, 1  // check if DOWN should be erased
BRN EVEN, .skipdown
ADI R4, R6, 3  // load y
PST R4, 65
ADI R4, R5, 1  // load x1 and erase
PST R4, 90
ADI R4, R4, 1  // load y2 and erase
PST R4, 90

.skipdown
BSRI R7, R7, 1  // check if UP should be erased
BRN EVEN, .skipup
PST R6, 65  // load y
ADI R4, R5, 1  // load x1 and erase
PST R4, 90
ADI R4, R4, 1  // load y2 and erase
PST R4, 90

.skipup
BSRI R7, R7, 1  // check if LEFT should be erased
BRN EVEN, .skipleft
PST R5, 64  // load x
ADI R4, R6, 1  // load y1 and erase
PST R4, 91
ADI R4, R4, 1  // load y2 and erase
PST R4, 91

.skipleft
POP R4  // return tail coords
POP R7  // return direction
EPOI R7
MLD R6, 130  // offset head x
ADD R1, R1, R6
CMP R1, 8  // check if collided with wall
BRN CARRY, .dedjump
MLD R6, 146  // offset head y
ADD R2, R2, R6
CMP R2, 8  // check if collided with wall
BRN CARRY, .dedjump

POI R0  // clear extended pointer
JMP .continuemainloop

.dedjump
POI R0
JMP .ded



// MAIN LOOP 2
.PAGE:3
.continuemainloop
MLD R5, 128  // check if food x matches head x
SUB R0, R5, R1
BRT NEQUAL, .skipfood
MLD R5, 129  // check if food y matches head y
SUB R0, R5, R2
BRT NEQUAL, .skipfood
JMP .eatfood  // food eaten

.skipfood
BSLI R5, R1, 2  // check if snake collided with itself
ADI R5, R5, 1
PST R5, 64
BSLI R5, R2, 2
ADI R5, R5, 1
PST R5, 65
PLD R5, 71  // load pixel value
BRT ZERO, .nocollision
JMP .ded

.nocollision
MLD R5, 163 // get back of queue
ADI R5, R5, 1  // increment
AIM R5, 0b01111111
MST R5, 163
POI R5
MLD R7, 0  // get tail direction

PSH R1  // push head coords to free registers
PSH R2
BSLI R1, R3, 2  // get upscaled coords
BSLI R2, R4, 2

CMP R7, 1  // check if direction RIGHT
BRN ZERO, .tailright
CMP R7, 2  // check if direction DOWN
BRN ZERO, .taildown
CMP R7, 4  // check if direction UP
BRN ZERO, .tailup

ADI R5, R1, -1  // x1
ADI R6, R2, 1  // y1
ADI R1, R1, 2  // x2
ADI R2, R2, 2  // y2
JMP .erasetail

.tailup
ADI R5, R1, 1
ADI R6, R2, -1
ADI R1, R1, 2
ADI R2, R2, 2
JMP .erasetail

.taildown
ADI R5, R1, 1
ADI R6, R2, 1
ADI R1, R1, 2
ADI R2, R2, 4
JMP .erasetail

.tailright
ADI R5, R1, 1
ADI R6, R2, 1
ADI R1, R1, 4
ADI R2, R2, 2

.erasetail
PST R5, 64  // load values and erase rectangle
PST R6, 65
PST R1, 66
PST R2, 95
POP R2  // restore head coords
POP R1
POI R7  // update tail coords
MLD R6, 130
ADD R3, R3, R6
POI R7
MLD R6, 146
ADD R4, R4, R6
JMP .drawhead
