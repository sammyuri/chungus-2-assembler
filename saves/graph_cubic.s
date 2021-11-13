.PAGE:0
LOOPSRC .clearloop  // clear memory
LOOPCNT 63
PSH R0
PSH R0
PSH R0
.clearloop
PSH R0

PST R0, 68  // clear screen
PST R0, 70  // clear char display

LIM R0, "X"  // write equation
PST R0, 72
LIM R0, "^"
PST R0, 72
LIM R0, "3"
PST R0, 72
PST R0, 72
LIM R0, "-"
PST R0, 72
PST R0, 72
LIM R0, "4"
PST R0, 72
LIM R0, "5"
PST R0, 72
LIM R0, "X"
PST R0, 72
PLD R0, 72
LIM R0, "-"
PST R0, 72
PST R0, 72

LIM R0, "3"
PST R0, 73
LIM R0, "0"
PST R0, 73
LIM R0, "Y"
PST R0, 73
PST R0, 73
LIM R0, "="
PST R0, 73
PST R0, 73
LIM R0, "0"
PST R0, 73
PLD R0, 73
PST R0, 73
PST R0, 73
PST R0, 73
PST R0, 73

LIM R1, 15  // draw axes
LIM R2, 31
PST R1, 65
PST R1, 67
PLD R0, 64  // wait
PST R2, 86
LIM R1, 16
PST R1, 64
PST R1, 66
PST R0, 65
PST R2, 87

PLD R0, 69  // buffer screen and wait
JMP .mainloop  // let the graph drawing begin!


.PAGE:1
.mainloop
LIM R7, -17  // loop over y and x
.yloop
LIM R6, -17
.xloop
CAL .calculate  // calculate if positive or negative

LIM R0, 17  // calculate byte of result
ADD R1, R7, R0
LIM R0, 6
MUL R1, R1, R0
LIM R0, 24
ADD R3, R6, R0
BSRI R2, R3, 3
ADD R1, R1, R2

POI R1  // load byte
MLD R4, 0
POP R5  // add bit to byte
BSL R5, R5, R3  // shift to right position
OR R4, R4, R5
POI R1
MST R4, 0  // store resultant byte

ADI R6, R6, 1  // increment x
CMP R6, 17  // check if reached end of row
BRT NZERO, .xloop
ADI R7, R7, 1  // increment y
CMP R7, 17  // check if reached end of grid
BRT NZERO, .yloop
JMP .display  // display resulting graph


.calculate
// THIS PART CHANGES DEPENDING ON GRAPH

// x^3 - 45x - 30y
PSH R6
CMA R6, 128  // check if -x is needed
BRT ZERO, .skipinvertx
SUB R6, R0, R6

.skipinvertx
MUL R2, R6, R6  // calculate x^3
MULU R3, R6, R6
MUL R4, R2, R6
MULU R5, R2, R6
MUL R1, R3, R6
ADD R5, R1, R5

LIM R1, 45  // calculate -45x
MUL R2, R6, R1
MULU R3, R6, R1
SUB R4, R4, R2
SUBC R5, R5, R3

POP R6
CMA R6, 128
BRT ZERO, .skipinvertx2
SUB R4, R0, R4
SUBC R5, R0, R5

.skipinvertx2
PSH R7
CMA R7, 128  // check if -y is needed
BRT ZERO, .skipinverty
SUB R7, R0, R7

.skipinverty
LIM R1, 30  // calculate -30*y
MUL R2, R7, R1
MULU R3, R7, R1

POP R7
CMA R7, 128
BRT ZERO, .skipinverty2
SUB R2, R0, R2
SUBC R3, R0, R3

.skipinverty2
SUB R4, R4, R2  // subtract from previous
SUBC R5, R5, R3

.finishcalc
BSRI R1, R5, 7
PSH R1
RET




.PAGE:2
.display
LIM R7, -16  // loop over y and x
.displayyloop
LIM R6, -16
.displayxloop

LIM R0, 17  // calculate byte
ADD R1, R7, R0
LIM R0, 6
MUL R1, R1, R0
LIM R0, 24
ADD R2, R6, R0

BSRI R3, R2, 3  // load bytes on the left
ADD R3, R1, R3
POI R3
MLD R4, -6
POI R3
MLD R5, 0
BSR R4, R4, R2  // extract bit
AIM R4, 1
ADI R4, R4, 1
BSR R5, R5, R2
AIM R5, 1
ADI R5, R5, 1
PSH R4  // push to stack
PSH R5

ADI R2, R2, 1  // load bytes on the right
BSRI R3, R2, 3
ADD R3, R1, R3
POI R3
MLD R4, -6
POI R3
MLD R5, 0
BSR R4, R4, R2  // extract bit
AIM R4, 1
ADI R4, R4, 1
BSR R5, R5, R2
AIM R5, 1
ADI R5, R5, 1

AND R4, R4, R5  // accumulate bits
POP R5
AND R4, R4, R5
POP R5
AND R4, R4, R5
BRT NZERO, .skipdraw  // skip if all the same 

LIM R1, 16  // adjust coordinates to screen
ADD R2, R1, R6
SUB R3, R1, R7
ADI R3, R3, -1
PST R2, 64  // draw pixel
PST R3, 83
PST R0, 69  // buffer screen

.skipdraw
ADI R6, R6, 1  // increment x
CMP R6, 16  // check if reached end of row
BRT NZERO, .displayxloop
ADI R7, R7, 1  // increment y
CMP R7, 16  // check if reached end of grid
BRT NZERO, .displayyloop

HLT
