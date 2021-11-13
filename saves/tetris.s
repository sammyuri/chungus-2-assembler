// SETUP
.PAGE:0
// load all tile rotation data
LIM R1, 0b00000110
MST R1, 9
MST R1, 11
MST R1, 13
MST R1, 15
MST R1, 19
MST R1, 31
MST R1, 33
MST R1, 37
MST R1, 41
MST R1, 45
LIM R1, 0b00000010
MST R1, 21
MST R1, 43
MST R1, 47
MST R1, 49
MST R1, 51
MST R1, 55
LIM R1, 0b01100000
MST R1, 8
MST R1, 10
MST R1, 12
MST R1, 14
MST R1, 22
MST R1, 26
LIM R1, 0b01000100
MST R1, 0
MST R1, 1
MST R1, 4
MST R1, 5
MST R1, 23
MST R1, 30
LIM R1, 0b01100010
MST R1, 34
MST R1, 38
MST R1, 54
LIM R1, 0b00000100
MST R1, 29
MST R1, 35
MST R1, 39
LIM R1, 0b01100100
MST R1, 42
MST R1, 46
LIM R1, 0b00110000
MST R1, 40
MST R1, 44
LIM R1, 0b11000000
MST R1, 32
MST R1, 36
LIM R1, 0b01110000
MST R1, 28
MST R1, 48
LIM R1, 0b00100010
MST R1, 18
MST R1, 27
LIM R1, 0b00001111
MST R1, 3
MST R1, 7
JMP .continuesetup



// SETUP (part 2)
.PAGE:1
.continuesetup
PST R0, 68  // clear screen
PST R0, 70
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

LIM R1, 0b01110010  // finish loading tile data
MST R1, 52
LIM R1, 0b00110010
MST R1, 50
LIM R1, 0b00001110
MST R1, 25
LIM R1, 0b00100000
MST R1, 24
LIM R1, 0b11100000
MST R1, 20
LIM R1, 0b00000111
MST R1, 17
LIM R1, 0b01000000
MST R1, 16

LIM R6, 5  // store first tile coordinates
LIM R7, 2
MST R0, 60  // score score

LIM R1, 1  // draw playing area rectangle
PST R1, 64
PST R1, 65
LIM R0, 12
PST R0, 66
LIM R0, 30
PST R0, 87
LIM R1, 2
PST R1, 64
PST R1, 65
LIM R0, 11
PST R0, 66
LIM R0, 29
PST R0, 95

LIM R0, 18  // draw next tile rectangle
PST R0, 64
LIM R0, 7
PST R0, 65
LIM R0, 25
PST R0, 66
LIM R0, 14
PST R0, 87
LIM R0, 19
PST R0, 64
LIM R0, 8
PST R0, 65
LIM R0, 24
PST R0, 66
LIM R0, 13
PST R0, 95

JMP .finishscreensetup  // continue setup



// SETUP (part 3)
.PAGE:2
.finishscreensetup
LIM R0, 15  // get coordinates of text
PST R0, 64
LIM R0, 1
PST R0, 65

LIM R0, 0b01010101  // draw big "N" on screen
PST R0, 96
LIM R0, 0b01010011
PST R0, 104
PLD R0, 112  // make sure the screen is not getting overloaded

LIM R0, 0b00010011  // draw big "E" on screen
PST R0, 96
LIM R0, 0b00010111
PST R0, 104
LIM R0, 19
PST R0, 64
PST R0, 112

LIM R0, 0b01010010  // draw big "X" on screen
PST R0, 96
LIM R0, 0b01010101
PST R0, 104
LIM R0, 23
PST R0, 64
PST R0, 112

LIM R0, 0b00100010  // draw big "T" on screen
PST R0, 96
LIM R0, 0b00100111
PST R0, 104
LIM R0, 27
PST R0, 64
PLD R0, 112  // make sure the screen is not getting overloaded

JMP .finishothersetup  // continue setup


// COLLISION DETECTION
.collisiondetect
LIM R1, 0  // reset counter

.detectloop
POI R1
MLD R2, 72  // load x of next pixel
POI R1
MLD R3, 73  // load y of next pixel
PST R2, 64  // load pixel from screen
PST R3, 65
PLD R4, 71
BRN NZERO, .collisionfound  // check if pixel is lit

ADI R1, R1, 2  // increment counter
CMP R1, 8  // loop back if not done
BRT NZERO, .detectloop
PSH R0  // return 0 (no collision)
RET

.collisionfound
PSH R4  // return 1 (collision)
RET



// SETUP (part 4)
.PAGE:3
.finishothersetup
LIM R0, 5  // draw lowest pixels of all letters
PST R0, 65
LIM R0, 15  // N
PST R0, 82
LIM R0, 17
PST R0, 82
LIM R0, 19  // E
PST R0, 82
LIM R0, 20
PST R0, 82
LIM R0, 21
PST R0, 82
LIM R0, 23  // X
PST R0, 82
LIM R0, 25
PST R0, 82
LIM R0, 28  // T
PST R0, 82

.getnewtile_SETUP_1
PLD R1, 1  // get random number
AIM R1, 7
CMP R1, 7  // make sure it is between 0-6
BRN ZERO, .getnewtile_SETUP_1
MST R0, 58  // store initial tile rotation (0)
MST R1, 59  // store as current tile ID
BSLI R1, R1, 3  // get pointer to tile data
PSH R1
CAL .loadtile  // load tile

LIM R1, 0  // draw first tile and make permanent
LOOPSRC .setupdrawloop
LOOPCNT 3

EPOI R1
MLD R2, 72
MLD R3, 73
MST R2, 64
MST R3, 65
POI R0
PST R2, 64
PST R3, 83
.setupdrawloop
ADI R1, R1, 2

.getnewtile_SETUP_2
PLD R1, 1  // get random number
AIM R1, 7
CMP R1, 7  // make sure it is between 0-6
BRN ZERO, .getnewtile_SETUP_2
MST R1, 61  // store as next tile ID

CAL .drawnext  // draw next tile

MST R0, 84  // load score values of different numbers of rows
LIM R0, 1
MST R0, 85
LIM R0, 4
MST R0, 86
LIM R0, 15
MST R0, 87
LIM R0, 40
MST R0, 88

PLD R0, 69  // buffer screen and wait
JMP .mainloop  // let the game begin!



// LOAD TILE
// Convert the compressed tile (pointer at top of stack) to temporary coordinates
.PAGE:4
.loadtile
POP R1  // get data
EPOI R1
MLD R1, 0
MLD R2, 1

BSRI R3, R1, 4  // split data into 4 bit rows
BSRI R4, R2, 4
AIM R1, 15
AIM R2, 15
POI R0  // clear extended pointer
MST R1, 80
MST R3, 81
MST R2, 82
MST R4, 83

LIM R2, 0  // y offset
LIM R4, 0  // coordinate counter
.loadloop
LIM R1, 0  // reset x offset
POI R2  // get 4 bit row
MLD R3, 80
LOOPSRC .loadloopend  // set up loop
LOOPCNT 3

BRT EVEN, .loadloopskip  // skip if 0
EPOI R4  // write byte
ADD R5, R1, R6  // offset x and write
MST R5, 72
ADD R5, R2, R7  // offset y and write
MST R5, 73
ADI R4, R4, 2  // increment coordinate counter

.loadloopskip
ADI R1, R1, 1  // increment x offset
.loadloopend
BSRI R3, R3, 1  // right shift to get next bit

ADI R2, R2, 1  // increment y offset
CMP R2, 4  // loop back if not done
BRT NEQUAL, .loadloop

POI R0  // clear extended pointer
RET  // return


.drawnext
LIM R0, 20  // load x1, y1
PST R0, 64
LIM R0, 9
PST R0, 65

MLD R1, 61  // get pointer to tile data
BSLI R1, R1, 3
EPOI R1
MLD R2, 0  // get tile data
MLD R3, 1
POI R0  // clear extended pointer
PST R3, 96  // load sprite data
PST R2, 104

LIM R0, 23  // erase previous tile
PST R0, 66
LIM R0, 12
PST R0, 95

PST R0, 112  // draw sprite
RET  // return



// MAIN LOOP
.PAGE:5
.mainloop
LIM R1, 0  // reset counter
LOOPSRC .eraseloop  // setup loop
LOOPCNT 3

EPOI R1  // load x and y
MLD R2, 64
MLD R3, 65
POI R0  // clear extended pointer
PST R2, 64  // load coords and erase pixel
PST R3, 91
.eraseloop
ADI R1, R1, 2  // increment counter

PLD R1, 0  // load button input(s)
CMP R1, 16  // check if needs to go all the way down
BRT LESS, .skipdown
JMP .alltheway

.skipdown
CMA R1, 6  // check if tile needs to rotate
BRT ZERO, .skiprotate
JMP .rotate

.skiprotate
CMA R1, 9  // check if tile needs to move left/right
BRT ZERO, .skiptranslate
JMP .translate

.skiptranslate
LIM R1, 0  // reset counter
LOOPSRC .downloop_main  // setup loop
LOOPCNT 3

EPOI R1  // load x and y
MLD R2, 64
MLD R3, 65
ADI R3, R3, 1  // increment y (move down)
MST R2, 72  // store x and y in temp area
MST R3, 73
.downloop_main
ADI R1, R1, 2  // increment counter

POI R0  // clear extended pointer
CAL .collisiondetect  // check if collided with anything below
POP R1
BRT ZERO, .nothitbottom  // branch if collided
JMP .hitbottom

.nothitbottom
ADI R7, R7, 1  // move y coord down 1

.mainloop_redraw
// add delay if fps is too high
LIM R1, 0  // draw tile and make permanent
LOOPSRC .maindrawloop
LOOPCNT 3

EPOI R1
MLD R2, 72
MLD R3, 73
MST R2, 64
MST R3, 65
POI R0
PST R2, 64
PST R3, 83
.maindrawloop
ADI R1, R1, 2

PLD R0, 69  // buffer screen
JMP .mainloop



// MOVE LEFT/RIGHT AND ROTATE
.PAGE:6
.translate
LIM R5, 1
CMA R1, 1  // check if going right or left
BRT NZERO, .goingright
ADI R5, R5, -2

.goingright
LIM R1, 0  // reset counter
LOOPSRC .translateloop  // setup loop
LOOPCNT 3

EPOI R1  // load x and y
MLD R2, 64
MLD R3, 65
ADD R2, R2, R5  //  adjust x of each pixel
MST R2, 72  // store x and y in temp area
MST R3, 73
.translateloop
ADI R1, R1, 2  // increment counter

POI R0  // clear extended pointer
CAL .collisiondetect  // check if collided with anything below
POP R1
BRN NZERO, .cannottranslate  // branch if collided

ADD R6, R6, R5  // adjust x coordinate
JMP .mainloop_redraw  // continue

.cannottranslate
LIM R1, 0  // reset counter
LOOPSRC .cannottranslateloop
LOOPCNT 3

EPOI R1  // load x and y
MLD R2, 64
MLD R3, 65
MST R2, 72  // store original values
MST R3, 73
.cannottranslateloop
ADI R1, R1, 2  // increment counter

POI R0  // clear extended pointer
JMP .mainloop_redraw  // continue


.rotate
LIM R5, 1
CMA R1, 2  // check if rotating clockwise or anticlockwise
BRT NZERO, .clockwise
ADI R5, R5, -2

.clockwise
MLD R1, 58  // load current tile ID and rotation
MLD R2, 59
ADD R1, R1, R5  // rotate
AIM R1, 3
PSH R1  // save new rotation for later

BSLI R2, R2, 2  // calculate pointer to tile data
ADD R2, R2, R1
BSLI R2, R2, 1
PSH R2  // load new tile
CAL .loadtile

CAL .collisiondetect  // check if collided with anything
POP R1
POP R5  // get back new rotation
CMP R1, 0
BRN NZERO, .cannottranslate  // branch if collided

MST R5, 58  // save new rotation
JMP .mainloop_redraw  // continue



// GO ALL THE WAY DOWN
.PAGE:7
.alltheway
LIM R1, 0  // reset counter
LIM R4, 0  // collision detection
LOOPSRC .downloop_alltheway  // setup loop
LOOPCNT 3

EPOI R1  // load x and y
MLD R2, 64
MLD R3, 65
ADI R3, R3, 1  // increment y (move down)
MST R3, 65  // store updated y
POI R0  // clear extended pointer
PST R2, 64  // check if collision
PST R3, 65
PLD R5, 71
OR R4, R4, R5
.downloop_alltheway
ADI R1, R1, 2  // increment counter

CMP R4, 0  // check if collision
BRN NZERO, .allthewaycollision


ADI R7, R7, 1  // increment y
LIM R1, 0  // reset counter
LOOPSRC .drawloop_alltheway  // setup loop
LOOPCNT 3

EPOI R1  // load x and y
MLD R2, 64
MLD R3, 65
POI R0  // clear extended pointer
PST R2, 64  // draw x and y
PST R3, 83
.drawloop_alltheway
ADI R1, R1, 2  // increment counter

PLD R0, 69  // buffer and wait
LIM R1, 0  // reset counter
LOOPSRC .eraseloop_alltheway  // setup loop
LOOPCNT 3

EPOI R1  // load x and y
MLD R2, 64
MLD R3, 65
POI R0  // clear extended pointer
PST R2, 64  // erase x and y
PST R3, 91
.eraseloop_alltheway
ADI R1, R1, 2  // increment counter

JMP .alltheway  // keep on going until hits bottom


.allthewaycollision
LIM R1, 0  // reset counter
LOOPSRC .fixloop_alltheway  // setup loop
LOOPCNT 3

EPOI R1  // load y
MLD R3, 65
ADI R3, R3, -1  // adjust y and store
MST R3, 65
.fixloop_alltheway
ADI R1, R1, 2  // increment counter

POI R0  // clear extended pointer
JMP .hitbottom  // continue



// REACHED THE BOTTOM
.PAGE:8
.hitbottom
LIM R1, 0  // reset counter
LOOPSRC .drawloop_hitbottom  // setup loop
LOOPCNT 3

POI R1  // get x and y
MLD R2, 64
POI R1
MLD R3, 65
PST R2, 64  // load x and y and draw pixel
PST R3, 83
.drawloop_hitbottom
ADI R1, R1, 2  // increment counter

ADI R7, R7, 3  // get bottom of tile
CMP R7, 30  // make sure doesn't go off the bottom of screen
BRT LESS, .skipfixheight
LIM R7, 29
.skipfixheight
LIM R6, 0  // count how many rows checked
MST R0, 62  // reset number of full rows

.findfullloop
PST R7, 65  // load y
LIM R1, 2  // reset x counter

.fullcheckloop
PST R1, 64  // load x and get pixel
PLD R3, 71
BRN ZERO, .notfull  // branch if zero (row not full)
ADI R1, R1, 1  // increment x counter
CMP R1, 12  // loop if not done
BRT NZERO, .fullcheckloop

MLD R5, 62  // increment number of full rows
ADI R5, R5, 1
MST R5, 62
ADI R5, R7, -1  // get starting y values
MOV R4, R7

.movedownloop
PST R4, 65  // erase current row
PST R4, 67
LIM R0, 2
PST R0, 64
LIM R0, 11
PST R0, 94
LIM R1, 2  // reset x counter
LIM R2, 0  // check if any pixels moved
LOOPSRC .movedownsubloop  // setup loop
LOOPCNT 9

PST R1, 64  // load x
PST R5, 65  // load top y
PLD R3, 71  // load pixel
BRT ZERO, .skipdraw_movedown
PST R4, 83  // load bottom y and draw pixel
.skipdraw_movedown
OR R2, R2, R3
.movedownsubloop
ADI R1, R1, 1  // increment counter

CMP R2, 0  // end loop if no pixels moved (gaps are impossible)
BRN ZERO, .findfullloop

ADI R5, R5, -1  // move y values up
ADI R4, R4, -1
BRT TRUE, .movedownloop

.notfull
ADI R7, R7, -1  // adjust counters
ADI R6, R6, 1
CMP R6, 4  // check if finished
BRT NZERO, .findfullloop

MLD R1, 60  // increment score if needed
MLD R2, 62
POI R2
MLD R2, 84
ADD R1, R1, R2
MST R1, 60  // store new score and draw to screen
PST R1, 78
PLD R0, 69  // buffer screen
JMP .newtile  // continue



// GENERATE NEW TILE
.PAGE:9
.newtile
LIM R6, 5  // reset tile coordinates
LIM R7, 2
MLD R1, 61  // set current tile ID to next tile ID
MST R1, 59
MST R0, 58  // reset current tile rotation
BSLI R1, R1, 3  // get pointer to tile data
PSH R1
CAL .loadtile  // load tile

LIM R1, 0  // draw tile and make permanent
LOOPSRC .drawloop_newtile
LOOPCNT 3

EPOI R1
MLD R2, 72
MLD R3, 73
MST R2, 64
MST R3, 65
POI R0
PST R2, 64
PST R3, 65
PLD R4, 71  // check if collided with anything
BRN NZERO, .ded
PST R3, 83
.drawloop_newtile
ADI R1, R1, 2

LIM R0, 19  // erase previous next tile display
PST R0, 64
LIM R0, 8
PST R0, 65
LIM R0, 24
PST R0, 66
LIM R0, 13
PST R0, 95

.getnewtile_newtile
PLD R1, 1  // get random number
AIM R1, 7
CMP R1, 7  // make sure it is between 0-6
BRN ZERO, .getnewtile_newtile
MST R1, 61  // store as next tile ID

CAL .drawnext  // draw next tile

PLD R0, 69  // buffer screen and wait
JMP .mainloop  // continue game

.ded
LOOPCNT 0
LIM R0, "G"  // output "GAME OVER!"
PST R0, 73
LIM R0, "A"
PST R0, 73
LIM R0, "M"
PST R0, 73
LIM R0, "E"
PST R0, 73
LIM R0, "@"
PST R0, 73
LIM R0, "O"
PST R0, 73
LIM R0, "V"
PST R0, 73
LIM R0, "E"
PST R0, 73
LIM R0, "R"
PST R0, 73
LIM R0, "!"
PST R0, 73

PST R0, 69  // buffer screen
HLT  // game over!