.PAGE:0
LIM R1, 64
LOOPSRC .clearloop
LOOPCNT 31

POI R1
MST R0, 0
.clearloop
ADI R1, R1, 1

LIM R1, 1
CAL .create_LUT
LIM R0, 16
EPOI R0
CAL .create_LUT
POI R0
MST R1, 50

LIM R0, 64
EPOI R0
LIM R1, 0b00011000
MST R1, 6
MST R1, 13
LIM R1, 0b00110000
MST R1, 8
MST R1, 15
LIM R1, 0b00001000
MST R1, 10
MST R1, 17
LIM R1, 0b01100000
MST R1, 20
MST R1, 24
LIM R1, 0b11010000
MST R1, 22
LIM R1, 0b00010000
MST R1, 31
MST R1, 29
MST R1, 27
POI R0

MST R0, 96

JMP .draw

.create_LUT
MST R0, 32
MST R0, 33
MST R0, 34
MST R1, 35
MST R0, 36
MST R0, 37
MST R0, 38
MST R0, 39
MST R0, 40
RET



.PAGE:1
.draw
LIM R1, 0
LOOPSRC .moveloop
LOOPCNT 31

EPOI R1
MLD R2, 64
MST R2, 0
MST R0, 64
.moveloop
ADI R1, R1, 1

.drawloop
POI R0
PST R0, 68  // clear
LIM R7, 0

.yloop
POI R7
MLD R4, 0
PST R7, 65
ADI R7, R7, 1
POI R7
MLD R5, 0
PST R7, 67

LIM R6, 0
ROTI R4, R4, 7
.firstdrawloop
ROTI R4, R4, 1
BRT EVEN, .skipdraw
PST R6, 64
ADI R3, R6, 1
PST R3, 86

.skipdraw
ADI R6, R6, 2
CMP R6, 16
BRT NZERO, .firstdrawloop

ROTI R5, R5, 7
.seconddrawloop
ROTI R5, R5, 1
BRT EVEN, .skipdraw2
PST R6, 64
ADI R3, R6, 1
PST R3, 86

.skipdraw2
ADI R6, R6, 2
CMP R6, 32
BRT NZERO, .seconddrawloop

PLD R0, 69
ADI R7, R7, 1
CMP R7, 32
BRT NZERO, .yloop

MLD R1, 96
ADI R1, R1, 1
MST R1, 96
CMP R1, 8
BRT NZERO, .notfinished
HLT

.notfinished
JMP .life

.PAGE:2
.life
LIM R7, 0  // pointer

.lifeloop
LIM R6, 0  // counter
ADI R5, R7, -16
CAL .addcell
ADI R5, R5, -1
CAL .addcell
ADI R5, R5, 2
CAL .addcell
ADI R5, R7, 15
CAL .addcell
ADI R5, R5, 1
CAL .addcell
ADI R5, R5, 1
CAL .addcell
ADI R5, R7, -1
CAL .addcell
ADI R5, R5, 2
CAL .addcell

BSRI R4, R7, 3
EPOI R4
MLD R3, 0
MLD R1, 64
BSR R3, R3, R7
AIM R3, 1
BSLI R3, R3, 4
ADD R3, R3, R6
POI R3
MLD R2, 32
BSL R2, R2, R7
ADD R1, R1, R2
POI R4
MST R1, 64

ADI R7, R7, 1
BRT NZERO, .lifeloop
JMP .draw

.addcell
BSRI R4, R5, 3
POI R4
MLD R3, 0
BSR R3, R3, R5
AIM R3, 1
ADD R6, R6, R3
RET