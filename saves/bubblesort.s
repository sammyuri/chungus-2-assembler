LIM R1, 14
LOOPSRC .skipswap
.loop
LIM R2, 0
POI R1
LOOPCNT 0
.subloop
EPOI R2
MLD R3, 0
MLD R4, 1
SUB R0, R4, R3
BRN GRTREQ, .skipswap
MST R3, 1
MST R4, 0
.skipswap
ADI R2, R2, 1
ADI R1, R1, -1
BRT GRTR, .loop
HLT