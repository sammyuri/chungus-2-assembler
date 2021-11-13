// SETUP
.PAGE:0
PST R0, 68  // clear screen
PST R0, 70

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
PLD R0, 74  // output initial score (0)
MST R0, 0  // store initial score

LIM R0, 1  // draw rectangle containing all bricks
PST R0, 64
LIM R0, 3
PST R0, 65
LIM R0, 29
PST R0, 66
LIM R0, 16
PST R0, 87

LIM R1, 5  // setup loop
LOOPSRC .horizontaldeleteloop
LOOPCNT 3

PST R1, 65  // delete row
PST R1, 95
.horizontaldeleteloop
ADI R1, R1, 3  // increment counter

PLD R0, 64  // make sure screen is not getting overloaded
LIM R0, 3  // load top/bottom y values
PST R0, 65
LIM R0, 16
PST R0, 67
LIM R1, 5  // setup loop
LOOPSRC .verticaldeleteloop
LOOPCNT 4

PST R1, 64  // delete column
PST R1, 94
.verticaldeleteloop
ADI R1, R1, 5  // increment counter

LIM R0, 13  // draw initial paddle
PST R0, 64
LIM R0, 17
PST R0, 66
LIM R1, 31
PST R1, 65
PST R1, 87

LIM R4, 2  // load initial ball velocity (diagonally up/right)
LIM R5, -2

LIM R6, 12  // load initial ball x/y
LIM R7, 20

PLD R1, 1  // offset x and y by random values between 0 and 7
AIM R1, 7
ADD R6, R6, R1
PLD R1, 1
AIM R1, 7
ADD R7, R7, R1

PST R6, 64  // draw ball
PST R7, 83
BSLI R6, R6, 1  // upscale x/y coordinates to fixed point
BSLI R7, R7, 1

JMP .setupdirections



// SET UP BOUNCE DIRECTIONS
.PAGE:1
.setupdirections
LIM R0, 2
MST R0, 42
LIM R0, -2
MST R0, 43
LIM R0, 0
MST R0, 44
LIM R0, -2
MST R0, 45

LIM R0, 1
MST R0, 74
LIM R0, -2
MST R0, 75
LIM R0, -1
MST R0, 76
LIM R0, -2
MST R0, 77

LIM R0, 0
MST R0, 70
LIM R0, -2
MST R0, 71
LIM R0, -2
MST R0, 72
LIM R0, -2
MST R0, 73

LIM R0, -1
MST R0, 66
LIM R0, -2
MST R0, 67
LIM R0, -2
MST R0, 68
LIM R0, -1
MST R0, 69

LIM R0, -2
MST R0, 62
LIM R0, -2
MST R0, 63
LIM R0, -2
MST R0, 64
LIM R0, -1
MST R0, 65

LIM R0, -2
MST R0, 58
LIM R0, -1
MST R0, 59
LIM R0, -2
MST R0, 60
LIM R0, -1
MST R0, 61

LIM R0, -2
MST R0, 26
LIM R0, -1
MST R0, 27
LIM R0, -2
MST R0, 28
LIM R0, -1
MST R0, 29

LIM R0, 15  // store initial paddle x
MST R0, 1

PST R0, 69  // buffer screen and wait
JMP .physicsloop  // let the game begin!



// MAIN LOOP
.PAGE:2
.physicsloop
LIM R2, 0  // check if has bounced
CMP R7, 62  // check if hit floor
BRT LESS, .notded
JMP .ded  // died

.notded
BSRI R1, R6, 1  // erase previous ball
PST R1, 64
BSRI R1, R7, 1
PST R1, 91

ADD R3, R5, R7  // calculate new y coordinate
XOR R1, R3, R7  // check if it is the same as the old one
CMA R1, 254
BRT NZERO, .ycalc
.skipcalcy
JMP .physicsx

.ycalc
CMA R3, 128  // check if hit ceiling
BRN NZERO, .hitceiling

BSRI R1, R3, 1  // check if collided with block or paddle
PST R1, 65
BSRI R1, R6, 1
PST R1, 64
PLD R1, 71
BRT ZERO, .skipcalcy

ADI R2, R2, 1  // note that collision happened
CMP R7, 60  // check if hit paddle
BRT LESS, .nothitpaddle
JMP .hitpaddle

.nothitpaddle
BSRI R3, R3, 1  // collided with block - delete that block
PSH R3
BSRI R3, R6, 1
PSH R3
CAL .breakblock
SUB R5, R0, R5  // invert y velocity
JMP .physicsx  // continue

.hitceiling
ADI R2, R2, 1  // note that collision happened
SUB R5, R0, R5  // invert y velocity
JMP .physicsx  // continue

// BLOCK BREAKING
.breakblock
POP R1  // calculate x coord of rectangle
LIM R3, 5
DIV R1, R1, R3
MUL R1, R1, R3
ADI R1, R1, 1
PST R1, 64  // load to screen
ADI R1, R1, 3
PST R1, 66

POP R1  // calculate y coord of rectangle
LIM R3, 3
DIV R1, R1, R3
MUL R1, R1, R3
PST R1, 65  // load to screen and erase
ADI R1, R1, 1
PST R1, 95

MLD R1, 0  // increment score
ADI R1, R1, 1
MST R1, 0
PST R1, 78  // write new score to screen
RET  // return



// MAIN LOOP (part 2)
.PAGE:3
.physicsx
ADD R3, R4, R6  // calculate new x coordinate
XOR R1, R3, R6  // check if it is the same as the old one
CMA R1, 254
BRT NZERO, .xcalc
.skipcalcx
JMP .finishmainloop

.xcalc
CMP R3, 64  // check if hit wall
BRN CARRY, .hitwall

BSRI R3, R3, 1  // check if collided with block
PST R3, 64
BSRI R1, R7, 1
PST R1, 65
PLD R1, 71
BRT ZERO, .skipcalcx

ADI R2, R2, 1  // note that collision happened
BSRI R1, R7, 1  // collided with block - delete that block
PSH R1
PSH R3
CAL .breakblock
SUB R4, R0, R4  // invert x velocity
JMP .finishmainloop  // continue

.hitwall
ADI R2, R2, 1  // note that collision happened
SUB R4, R0, R4  // invert x velocity
JMP .finishmainloop // continue

.finishmainloop
CMP R2, 0  // check if collision has not happened
BRN NZERO, .hascollisions

ADD R6, R6, R4  // get new x and y
ADD R7, R7, R5
BSRI R1, R6, 1  // check if corner collision happened
PST R1, 64
BSRI R1, R7, 1
PST R1, 65
PLD R1, 71
BRT ZERO, .hascollisions

SUB R4, R0, R4  // corner collision - flip both x and y
SUB R5, R0, R5
BSRI R1, R7, 1  // delete block
PSH R1
BSRI R1, R6, 1
PSH R1
CAL .breakblock
ADD R6, R6, R4  // fix x and y
ADD R7, R7, R5

.hascollisions
BSRI R1, R6, 1  // draw ball
PST R1, 64
BSRI R1, R7, 1
PST R1, 83

JMP .paddlecalc  // continue

// PADDLE
.PAGE:4
.paddlecalc
MLD R2, 1  // get paddle x
LIM R0, 31  // load y 31 (paddle y)
PST R0, 65
PLD R1, 0  // get direction
CMA R1, 1  // check if paddle moves right
BRT ZERO, .skipright

ADI R2, R2, -2  // move paddle right
PST R2, 90
ADI R2, R2, 5
PST R2, 82
ADI R2, R2, -4
PST R2, 90
ADI R2, R2, 5
PST R2, 82
ADI R2, R2, -2  // store new paddle x
MST R2, 1
JMP .lastbitofloop

.skipright
CMA R1, 8  // check if paddle moves left
BRT ZERO, .lastbitofloop

ADI R2, R2, 2  // move paddle left
PST R2, 90
ADI R2, R2, -5
PST R2, 82
ADI R2, R2, 4
PST R2, 90
ADI R2, R2, -5
PST R2, 82
ADI R2, R2, 2  // store new paddle x
MST R2, 1

.lastbitofloop
PLD R0, 69  // buffer and wait
JMP .physicsloop // continue

.hitpaddle
LIM R2, 0  // flip bit
MLD R1, 1  // check paddle x
BSRI R3, R6, 1  // compare with ball x
SUB R1, R1, R3
BRT ZERO, .paddlemiddle  // hit paddle in the middle - reflection
BRT GRTR, .skipflip
ADI R2, R2, 1  // note that velocity needs to be flipped
SUB R1, R0, R1  // invert sign
SUB R4, R0, R4  // invert x velocty

.skipflip
BSLI R3, R5, 3  // get direction ID
ADD R3, R4, R3
BSLI R3, R3, 1
ADD R3, R3, R1
BSLI R3, R3, 1
POI R3  // get new x velocity
MLD R4, 0
POI R3  // get new y velocity
MLD R5, 1

CMP R2, 0  // check if needs to be flipped now
BRT ZERO, .goback

SUB R4, R0, R4  // flip velocity
SUB R5, R0, R5

.paddlemiddle
SUB R5, R0, R5  // flip y velocity
.goback
LIM R2, 1  // note that ball has bounced
JMP .physicsx  // continue

.ded
JMP .outputded


.PAGE:5
.outputded
LIM R0, "Y"  // output "YOU LOSE!"
PST R0, 73
LIM R0, "O"
PST R0, 73
LIM R0, "U"
PST R0, 73
LIM R0, "@"
PST R0, 73
LIM R0, "L"
PST R0, 73
LIM R0, "O"
PST R0, 73
LIM R0, "S"
PST R0, 73
LIM R0, "E"
PST R0, 73
LIM R0, "!"
PST R0, 73
PST R0, 69  // buffer screen
HLT  // game over!