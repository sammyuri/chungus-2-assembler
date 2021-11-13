.PAGE:0
PST R0, 68  // clear screen and char display
PST R0, 70

LIM R7, -16  // Y

.yloop
LIM R6, -25  // X
MST R7, 7

.xloop
MST R6, 6

LIM R4, 0
LIM R5, 0
ADD R6, R6, R6
ADD R7, R7, R7
MST R6, 0
MST R7, 2

CMA R6, 128
BRT ZERO, .skipinvertx
SUB R6, R0, R6
ADI R4, R4, 1

.skipinvertx
CMA R7, 128
BRT ZERO, .skipinverty
SUB R7, R0, R7
ADI R5, R5, 1

.skipinverty
CAL .mandelcalc
MLD R6, 6
MLD R7, 7
POP R1
BRT NZERO, .skipdraw

LIM R0, 16
ADD R2, R0, R7
PST R2, 65
LIM R0, 25
ADD R2, R0, R6
PST R2, 82
PLD R0, 69

.skipdraw
ADI R6, R6, 1
CMP R6, 7
BRT NZERO, .xloop

ADI R7, R7, 1
CMP R7, 16
BRT NZERO, .yloop

HLT



.PAGE:1
.mandelcalc
MST R0, 5

.mandelloop
// R7: imaginary part
// R6: real part
// R5: imaginary sign
// R4: real sign

// M0-M1: real offset
// M2-M3: imaginary offset
// M4: old sign real
// M5: counter
MUL R1, R6, R6  // get r^2 - i^2
MULU R2, R6, R6
MST R4, 4
MUL R3, R7, R7
MULU R4, R7, R7
SUB R1, R1, R3
SUBC R2, R2, R4

CMA R2, 128
BRT ZERO, .skipfixnegreal
LIM R0, 31
ADD R1, R1, R0
ADDC R2, R2, R0

.skipfixnegreal
BSRI R1, R1, 5  // fix point
BSLI R3, R2, 3
ADD R1, R1, R3

MLD R3, 0  // offset
ADD R1, R1, R3

LIM R4, 0
BSRI R0, R1, 7  // check if needs inverting
BRT ZERO, .skipinvertreal
SUB R1, R0, R1
LIM R4, 1

.skipinvertreal
CMP R1, 64  // check if too big
BRN GRTR, .outsideset
PSH R1

MUL R1, R6, R7  // get 2ri
MULU R2, R6, R7
ADD R1, R1, R1
ADDC R2, R2, R2
POP R6

CMP R2, 16
BRN GRTREQ, .outsideset
MLD R3, 4  // check if needs to invert
XOR R3, R3, R5
BRT ZERO, .skipinvertimaginary
SUB R1, R0, R1
SUBC R2, R0, R2

.skipinvertimaginary
CMA R2, 128
BRT ZERO, .skipfixnegimaginary
LIM R0, 31
ADD R1, R1, R0
ADDC R2, R2, R0

.skipfixnegimaginary
BSRI R1, R1, 5  // fix point
BSLI R3, R2, 3
ADD R7, R1, R3

MLD R3, 2  // offset
ADD R7, R7, R3

LIM R5, 0
BSRI R0, R7, 7  // check if needs inverting
BRT ZERO, .skipinvertimaginary2
SUB R7, R0, R7
LIM R5, 1

.skipinvertimaginary2
CMP R7, 64  // check if too big
BRN GRTR, .outsideset

MLD R1, 5  // check if done
ADI R1, R1, 1
MST R1, 5
CMP R1, 20
BRT NZERO, .mandelloop

LIM R0, 1
.outsideset
PSH R0
RET
