; By:      Devin Kaltenbaugh
; Created: January 22, 2020
; Title:   The First Journey (Shadows over Altia)

include "emu8086.inc"

org 100h

;Set the screen to 320 x 200 pixels
mov AL, 13h
mov AH, 0h
int 10h

;Start main game loop in the sceneManager
call sceneManager

hlt

ret

;All should be 0s
sceneNum DB 0
switchScene DB 0

;All should be 0s
CavesActive DB 0
CityDocksActive DB 0
KeyRoomActive DB 0

;All should be 0s
collectedCityDungeon DB 0
collectedTemple DB 0
collectedCaveDown DB 0
collectedCaveUp DB 0

;All should be 1s
firstLoadCrossroads DB 1
firstLoadCity DB 1
firstCityDocks DB 1
firstIslandDocks DB 1
firstTempleEx DB 1
firstCavesEx DB 1

;Sets default room entrance direction
roomDirection DB 0

;sceneManager
;Runs mina game loop and controls the loading of 
;scene and their associated props and text
sceneManager Proc
    
    ;Main game loop is infinite
    gameLoop:
    cmp switchScene, 30
    jl switchedScene: ;Jumps to the switchScene process
     
    mov AH, 1h
    int 16h ;Check for buffer input 
    jz no_Input:
            
    mov AH, 0h
    int 16h ;Pulled buffered input
        
    call playerMove ;Run the playerMove procedure

    no_Input:
    jmp gameLoop:
    
    
    switchedScene:
    
    switchScene0: ;Title Screen
    cmp switchScene, 0
    jnz switchScene1:
        mov numChar, 695
        mov renderYPos, 0
        mov background, 00Eh
        mov loadMap, 0
        call mapRender ;Renders the map to the screen
        
        call waitTimer ;Waits 5 seconds
                
        mov switchScene, 1  ;Switches to next scene
        jmp gameLoop:  ;Returns to game loop
    
    switchScene1: ;Castle Interior
    cmp switchScene, 1
    jnz switchScene2:
        mov numChar, 695
        mov renderYPos, 0
        mov background, 7
        mov loadMap, 695
        call mapRender  ;Renders the map to screen
        
        mov readStart, 0
        mov readLength, 15
        call drawProps  ;Draws the props on the map
        
        mov runScriptedEvent, 0
        call eventManager  ;Starts scripted cutscene
    
        mov switchScene, 2 ;Switches to next scene
        jmp gameLoop:  ;Returns to game loop
    
    switchScene2: ;Castle Exterior
    cmp switchScene, 2
    jnz switchScene3:
        mov numChar, 695
        mov renderYPos, 0
        mov background, 027h
        mov loadMap, 1390
        call mapRender  ;Renders the map to screen
        
        mov readStart, 15
        mov readLength, 6
        call drawProps  ;Draws the props on the map
        
        mov runScriptedEvent, 1
        call eventManager ;Starts scripted cutscene
        
        call waitTimer  ;Waits 5 seconds
        
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 13119
        call mapRender  ; Renders directions text box
        
        mov playerColor, 02Eh       ;Sets player and background
        mov playerBackground, 020h  ;colors for moving the player
        
        mov switchScene, 99  ;Basic control flags set
        mov sceneNum, 2
        call bufferWipe  ;Wipe keyboard input buffer
        jmp gameLoop:  ;Returns to game loop
    
    switchScene3: ;Crossroads
    cmp switchScene, 3
    jnz switchScene4:
        mov numChar, 369
        mov renderYPos, 0
        mov background, 027h
        mov loadMap, 2085
        call mapRender  ;Renders the top part of the map
        
        mov numChar, 41
        mov renderYPos, 9
        mov background, 067h
        mov loadMap, 2454
        call mapRender ;Renders the center strip of the map
        
        mov numChar, 285
        mov renderYPos, 10
        mov background, 076h
        mov loadMap, 2495
        call mapRender  ;Renders the rest of the map
        
        mov playerColor, 02Eh
        mov playerBackground, 020h
        
        cmp firstLoadCrossroads, 1 ;Checks if player has loaded
        jnz notFirstCrossroads:    ;the scene for the first time
            mov readStart, 21
            mov readLength, 3
            call drawProps  ;Draws the props on the map
            
            mov numChar, 326
            mov renderYPos, 17
            mov background, 00Fh
            mov loadMap, 13445
            call mapRender  ;Renders the dialog text box
            
            call waitTimer  ;Waits 5 seconds
            
            mov loadMap, 13771
            call mapRender  ;Renders the next dialog text box
            
            call waitTimer  ;Waits 5 seconds
            
            dec firstLoadCrossroads  ;Sets a first flag
            
            mov xPos, 013h  ;Sets players X:Y Position for the
            mov yPos, 003h  ;player movement controller
            
            jmp swtichScene3end:
            
        notFirstCrossroads:  ;Checks if door to CavesEx is 
        cmp CavesActive, 1   ;unlocked
        jnz notCollectedTemple:
            mov readStart, 21
            mov readLength, 1
            call drawProps  ;Draws left door to the scene
            
            mov readStart, 24
            call drawProps  ;Draws right door to scene
            
            cmp roomDirection, 2   ;Checks which direction the 
            jnz crossroadsRoomDir: ;player entered from
                mov readStart, 25
                call drawProps     ;Draws the player on the map
                                   ;Left side
                mov xPos, 00Eh
                mov yPos, 006h
                
                jmp swtichScene3end:
            
            crossroadsRoomDir:
            mov readStart, 26
            call drawProps    ;Draws the player on the map
                              ;Right side
            mov xPos, 018h
            mov yPos, 006h
            
            jmp swtichScene3end:
            
        notCollectedTemple:
        mov readStart, 21
        mov readLength, 1  
        call drawProps  ;Draws left door to the scene
        
        mov readStart, 25
        call drawProps  ;Draws the player on the Left side
        
        mov xPos, 00Eh
        mov yPos, 006h
        
        swtichScene3end:
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 14097
        call mapRender  ;Renders the direction text box
        
        mov switchScene, 99
        mov sceneNum, 3
        call bufferWipe
        jmp gameLoop:  ;Returns to game loop
    
    switchScene4: ;City Center
    cmp switchScene, 4
    jnz switchScene5:
        mov numChar, 695
        mov renderYPos, 0
        mov background, 087h
        mov loadMap, 2780
        call mapRender  ;Renders the map to screen
        
        mov playerColor, 08Eh
        mov playerBackground, 080h
        
        cmp KeyRoomActive, 1   ;Checks if the City Morgue
        jnz checkCityDocks:    ;is active
            mov readStart, 27
            mov readLength, 4
            call drawProps     ;Draws the doors on the map
            jmp cityRoomDir0:
            
        checkCityDocks:        ;Checks if the City Docks are
        cmp CityDocksActive, 1 ;unlocked (All)
        jnz notCollectedCity:
            mov readStart, 27
            mov readLength, 3 
            call drawProps    ;Draws the doors on the map (L/U/R)
            jmp cityRoomDir0:
        
        notCollectedCity:    
        mov readStart, 27
        mov readLength, 2
        call drawProps    ;Draws the doors on the map (L/R)
                
        cityRoomDir0:
        cmp roomDirection, 3  ;Check which direction the player 
        jnz cityRoomDir1:     ;entered from
            mov readStart, 33
            mov readLength, 1
            call drawProps    ;Draws the player on the map (D)
            
            mov xPos, 013h    ;Assigns X:Y pos of player
            mov yPos, 003h
            
            jmp cityTextLoad:    
        
        cityRoomDir1:
        cmp roomDirection, 2
        jnz cityRoomDir2:
            mov readStart, 32
            mov readLength, 1
            call drawProps    ;Draws the player on the map (L)
            
            mov xPos, 00Ch    ;Assigns X:Y pos of player
            mov yPos, 008h
            
            jmp cityTextLoad:
        
        cityRoomDir2:
        mov readStart, 31
        mov readLength, 1
        call drawProps    ;Draws the player on the map (R)
        
        mov xPos, 01Ah    ;Assigns X:Y pos of player
        mov yPos, 008h
        
        cityTextLoad:
        cmp firstLoadCity, 1  ;Checks if this is first time city load
        jnz notFirstCity:
            mov numChar, 326
            mov renderYPos, 17
            mov background, 00Fh
            mov loadMap, 14423
            call mapRender   ;Renders the discription text on screen
            
            dec firstLoadCity   ;Set first city flag to off
            
            call waitTimer  ;Wait 5 seconds
        
        notFirstCity:
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 14749
        call mapRender    ;Renders the directions text on screen
        
        mov switchScene, 99
        mov sceneNum, 4
        call bufferWipe
        jmp gameLoop:  ;Returns to game loop
    
    switchScene5:  ;City Dungeon Ex
    cmp switchScene, 5
    jnz switchScene6:
        mov numChar, 695
        mov renderYPos, 0
        mov background, 067h
        mov loadMap, 3475
        call mapRender   ;Renders the map on the screen
        
        mov playerColor, 06Eh
        mov playerBackground, 060h
        
        call activeCheck   ;Checks what doors are open/closed due to keys
            
        cmp CollectedCityDungeon, 1   ;Checks if the city dungeon has
        jnz notCollectedCityDungeon:  ;been collected
            mov readStart, 35
            mov readLength, 6
            call drawProps            ;Draw props on the map - city dungeon
            jmp checkCityDungeonExMove:            
            
        notCollectedCityDungeon:   
        mov readStart, 34
        mov readLength, 7
        call drawProps   ;Draws props on the map + city dungeon
        
        checkCityDungeonExMove:    
        cmp roomDirection, 2     ;Checks room enterance direction
        jnz cityDungeonMoveLeft:
            mov readStart, 42
            mov readLength, 1
            call drawProps       ;Draws player on the map (L)
            
            mov xPos, 00Eh       ;Assigns X:Y pos of player
            mov yPos, 008h
            
            mov numChar, 326
            mov renderYPos, 17
            mov background, 00Fh
            mov loadMap, 16379
            call mapRender       ;Renders hint message on screen
            
            call waitTimer       ;Wait 5 seconds
            jmp textCityDungeon:
        
        cityDungeonMoveLeft:    
        mov readStart, 41
        mov readLength, 1
        call drawProps      ;Draws player on the map (R)
        
        mov xPos, 0019h     ;Assigns X:Y pos of player
        mov yPos, 008h
        
        textCityDungeon:
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 15075
        call mapRender      ;Renders directions text on screen
        
        mov switchScene, 99
        mov sceneNum, 5
        call bufferWipe
        jmp gameLoop:   ;Returns to game loop
    
    switchScene6:
    cmp switchScene, 6
    jnz switchScene7:
        mov numChar, 695
        mov renderYPos, 0
        mov background, 007h
        mov loadMap, 4170
        call mapRender
        
        mov readStart, 43
        mov readLength, 4
        call drawProps
        
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 15401
        call mapRender
        
        call waitTimer
        
        mov loadMap, 15727
        call mapRender
        
        mov xPos, 024h
        mov yPos, 00Ch
        
        mov playerColor, 00Eh
        mov playerBackground, 000h
               
        mov switchScene, 99
        mov sceneNum, 6
        call bufferWipe
        jmp gameLoop:   ;Returns to game loop
    
    switchScene7:
    cmp switchScene, 7
    jnz switchScene8:
        mov numChar, 369
        mov renderYPos, 0
        mov background, 061h
        mov loadMap, 4865
        call mapRender
        
        mov numChar, 205
        mov renderYPos, 9
        mov background, 067h
        mov loadMap, 5234
        call mapRender
        
        mov numChar, 121
        mov renderYPos, 14
        mov background, 027h
        mov loadMap, 5439
        call mapRender
        
        mov playerColor, 06Eh
        mov playerBackground, 060h
        mov toggleColor, 0
        
        cmp firstCityDocks, 1
        jnz notFirstCityDocks:
            mov readStart, 51
            mov readLength, 4
            call drawProps
                        
            mov numChar, 326
            mov renderYPos, 17
            mov background, 00Fh
            mov loadMap, 16705
            call mapRender
            
            call waitTimer
            
            mov loadMap, 17031
            call mapRender
            
            call waitTimer
            
            mov loadMap, 17357
            call mapRender
            
            call waitTimer
            
            dec firstCityDocks
            
            mov xPos, 013h
            mov yPos, 00Dh
            
            jmp renderCityDocksend:
        
        notFirstCityDocks:    
        mov readStart, 51
        mov readLength, 2
        call drawProps
        
        cmp roomDirection, 1
        jnz moveCityDocksUp:
            mov readStart, 54
            mov readLength, 1
            call drawProps
            
            mov xPos, 013h
            mov yPos, 00Dh
            
            jmp renderCityDocksend:
        
        moveCityDocksUp:    
        mov readStart, 55
        mov readLength, 1
        call drawProps
        
        mov xPos, 011h
        mov yPos, 005h 
        
        renderCityDocksend:
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 17683
        call mapRender
        
        mov switchScene, 99
        mov sceneNum, 7
        call bufferWipe
        jmp gameLoop:
    
    switchScene8:
    cmp switchScene, 8
    jnz switchScene9:
        mov numChar, 205
        mov renderYPos, 0
        mov background, 021h
        mov loadMap, 5560
        call mapRender
        
        mov numChar, 490
        mov renderYPos, 5
        mov background, 061h
        mov loadMap, 5765
        call mapRender
        
        mov numChar, 22
        mov renderYPos, 0
        mov renderXPos, 10
        mov background, 027h
        mov loadMap, 5570
        call mapRender
        mov renderYPos, 1
        mov loadMap, 5611
        call mapRender
        mov renderYPos, 2
        mov loadMap, 5652
        call mapRender
        mov renderYPos, 3
        mov loadMap, 5693
        call mapRender
        mov renderYPos, 4
        mov loadMap, 5734
        call mapRender
        mov renderXPos, 0
        
        mov readStart, 56
        mov readLength, 5
        call drawProps
        
        mov toggleColor, 1
        
        cmp roomDirection, 1
        jnz moveIslandDocksDown:
            mov readStart, 61
            mov readLength, 1
            call drawProps
            
            mov playerColor, 06Eh
            mov playerBackground, 060h
            
            mov xPos, 014h
            mov yPos, 00Ah
            
            jmp checkIslandDocksFirst:
        
        moveIslandDocksDown:    
        mov readStart, 62
        mov readLength, 1
        call drawProps
        
        mov playerColor, 02Eh
        mov playerBackground, 020h
        
        mov xPos, 016h
        mov yPos, 004h
        
        checkIslandDocksFirst:
        cmp firstIslandDocks, 1
        jnz notFirstIslandDocks:
            mov numChar, 326
            mov renderYPos, 17
            mov background, 00Fh
            mov loadMap, 18009
            call mapRender
            
            call waitTimer
            
            mov loadMap, 18335
            call mapRender
            
            call waitTimer
            
            dec firstIslandDocks
        
        notFirstIslandDocks:    
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 18661
        call mapRender
                                               
        mov switchScene, 99
        mov sceneNum, 8
        call bufferWipe
        jmp gameLoop:
    
    switchScene9:
    cmp switchScene, 9
    jnz switchScene10:
        mov numChar, 695
        mov renderYPos, 0
        mov background, 027h
        mov loadMap, 6255
        call mapRender
        
        mov playerColor, 02Eh
        mov playerBackground, 020h
        mov toggleColor, 0
        
        call activeCheck
        
        cmp firstTempleEx, 1
        jnz notFirstTempleEx:
            mov readStart, 63
            mov readLength, 2
            call drawProps
            
            mov readStart, 66
            mov readLength, 1
            call drawProps
            
            mov numChar, 326
            mov renderYPos, 17
            mov background, 00Fh
            mov loadMap, 18987
            call mapRender
            
            call waitTimer 
            
            dec firstTempleEx
            
            mov xPos, 016h
            mov yPos, 00Dh
            
            jmp textTempleExend:
        
        notFirstTempleEx:    
        mov readStart, 64
        mov readLength, 1
        call drawProps
        
        cmp collectedTemple, 0
        jnz collectedTempleKey:
            mov readStart, 63
            call drawProps
            jmp checkTempleExMoves:
        
        collectedTempleKey:
        mov readStart, 65
        call drawProps
        
        checkTempleExMoves:    
        cmp roomDirection, 1
        jnz moveTempleExDown:
            mov readStart, 66
            mov readLength, 1
            call drawProps
            
            mov xPos, 016h
            mov yPos, 00Dh
            
            jmp textTempleExend:
        
        moveTempleExDown:    
        mov readStart, 67
        mov readLength, 1
        call drawProps
        
        mov xPos, 013h
        mov yPos, 005h
        
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 20291
        call mapRender
            
        call waitTimer
            
        mov loadMap, 20617
        call mapRender
            
        call waitTimer
            
        mov loadMap, 20943
        call mapRender
            
        call waitTimer
        
        textTempleExend:
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 19313
        call mapRender                                 
        
        mov switchScene, 99
        mov sceneNum, 9
        call bufferWipe
        jmp gameLoop:
    
    switchScene10:
    cmp switchScene, 10
    jnz switchScene11:
        mov numChar, 695
        mov renderYPos, 0
        mov background, 007h
        mov loadMap, 6950
        call mapRender
        
        mov readStart, 68
        mov readLength, 23
        call drawProps
        
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 19639
        call mapRender
        
        call waitTimer
        
        mov loadMap, 19965
        call mapRender
        
        mov playerColor, 00Eh
        mov playerBackground, 000h
        
        mov xPos, 004h
        mov yPos, 00Eh
    
        mov switchScene, 99
        mov sceneNum, 10
        call bufferWipe
        jmp gameLoop:
    
    switchScene11:
    cmp switchScene, 11
    jnz switchScene12:
        mov numChar, 695
        mov renderYPos, 0
        mov background, 067h
        mov loadMap, 7645
        call mapRender
        
        mov playerColor, 06Eh
        mov playerBackground, 060h
        
        call activeCheck
        
        cmp firstCavesEx, 1
        jnz notFirstCavesEx:
            mov readStart, 92
            mov readLength, 4
            call drawProps
            
            mov numChar, 326
            mov renderYPos, 17
            mov background, 00Fh
            mov loadMap, 21595
            call mapRender
            
            call waitTimer
            
            dec firstCavesEx
            
            mov xPos, 00Dh
            mov yPos, 008h
            
            jmp cavesExend:
        
        notFirstCavesEx:    
        mov readStart, 93
        mov readLength, 1
        call drawProps
        
        cmp collectedCaveDown, 0
        jnz checkCollectedCaveUp:
            mov readStart, 94
            call drawProps
        
        checkCollectedCaveUp:    
        cmp collectedCaveUp, 0
        jnz movesCavesExUp:
            mov readStart, 92
            call drawProps
        
        movesCavesExUp:    
        cmp roomDirection, 1
        jnz moveCavesExDown:
            mov readStart, 97
            call drawProps 
            
            mov xPos, 013h
            mov yPos, 00Dh
            
            jmp checkKeyRoomActive:
       
        moveCavesExDown:    
        cmp roomDirection, 3
        jnz moveCavesExRight:
            mov readStart, 96
            call drawProps 
            
            mov xPos, 015h
            mov yPos, 003h
            
            jmp checkKeyRoomActive:
        
        moveCavesExRight:    
        mov readStart, 95
        
        mov xPos, 00Dh
        mov yPos, 008h
        
        call drawProps
        
        checkKeyRoomActive:
        cmp KeyRoomActive, 1
        jnz cavesExend:
            mov readStart, 98
            call drawProps
            
            mov numChar, 326
            mov renderYPos, 17
            mov background, 00Fh
            mov loadMap, 22899
            call mapRender
            
            call waitTimer
            
            mov loadMap, 23225
            call mapRender
            
            call waitTimer
        
        cavesExend:
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 21269
        call mapRender
        
        mov switchScene, 99
        mov sceneNum, 11
        call bufferWipe
        jmp gameLoop:
    
    switchScene12:
    cmp switchScene, 12
    jnz switchScene13:
        mov numChar, 695
        mov renderYPos, 0
        mov background, 007h
        mov loadMap, 8340
        call mapRender
        
        mov numChar, 13
        mov renderYPos, 5
        mov renderXPos, 13
        mov background, 061h                
        mov loadMap, 8558 
        call mapRender
        mov renderYPos, 6
        mov loadMap, 8599
        call mapRender
        mov renderYPos, 7
        mov loadMap, 8640
        call mapRender
        mov renderYPos, 8
        mov loadMap, 8681
        call mapRender
        mov renderYPos, 9
        mov loadMap, 8722
        call mapRender
        mov renderYPos, 10
        mov loadMap, 8763
        call mapRender
        mov renderYPos, 11
        mov loadMap, 8804
        call mapRender
        mov renderYPos, 12
        mov loadMap, 8845
        call mapRender
        mov renderYPos, 13
        mov loadMap, 8886
        call mapRender
        
        mov readStart, 99
        mov readLength, 3
        call drawProps
        
        mov readStart, 107
        mov readLength, 1
        call drawProps
        
        mov numChar, 326
        mov renderYPos, 17
        mov renderXPos, 0
        mov background, 00Fh
        mov loadMap, 21921
        call mapRender
        
        call waitTimer
        
        mov loadMap, 22247
        call mapRender
        
        mov playerColor, 06Eh
        mov playerBackground, 060h
        
        mov xPos, 013h
        mov yPos, 00Dh
    
        mov switchScene, 99
        mov sceneNum, 12
        call bufferWipe
        jmp gameLoop:
    
    switchScene13:
    cmp switchScene, 13
    jnz switchScene14:
        mov numChar, 695
        mov renderYPos, 0 
        mov background, 007h
        mov loadMap, 9035
        call mapRender
        
        mov readStart, 109
        mov readLength, 15
        call drawProps
        
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 22573
        call mapRender
        
        mov playerColor, 00Eh
        mov playerBackground, 000h
        
        mov xPos, 013h
        mov yPos, 002h
    
        mov switchScene, 99
        mov sceneNum, 13
        call bufferWipe
        jmp gameLoop:
    
    switchScene14:
    cmp switchScene, 14
    jnz switchScene15:
        mov numChar, 695
        mov renderYPos, 0
        mov background, 007h
        mov loadMap, 9730
        call mapRender
                             
        mov runScriptedEvent, 13
        call eventManager
                                    
        jmp gameLoop:
    
    switchScene15:
    cmp switchScene, 15
    jnz switchScene16:
        mov numChar, 695
        mov renderYPos, 0
        mov background, 068h
        mov loadMap, 10425
        call mapRender
        
        mov numChar, 14
        mov renderYPos, 5
        mov renderXPos, 12
        mov background, 060h
        mov loadMap, 10642
        call mapRender
        mov renderYPos, 6
        mov loadMap, 10683
        call mapRender
        mov renderYPos, 7
        mov loadMap, 10724
        call mapRender   
        mov renderYPos, 8
        mov loadMap, 10765
        call mapRender   
        mov renderYPos, 9
        mov loadMap, 10806
        call mapRender   
        mov renderYPos, 10
        mov loadMap, 10847
        call mapRender    
        mov renderYPos, 11
        mov loadMap, 10888
        call mapRender    
        mov renderYPos, 12
        mov loadMap, 10929
        call mapRender    
        mov renderYPos, 13
        mov loadMap, 10970
        call mapRender
        mov renderXPos, 0
        
        mov runScriptedEvent, 14
        call eventManager
    
        jmp gameLoop:
    
    switchScene16:
    mov numChar, 695
    mov renderYPos, 0
    mov background, 007h
    mov loadMap, 695
    call mapRender
    
    mov readStart, 0
    mov readLength, 14
    call drawProps
    
    mov runScriptedEvent, 15
    call eventManager    
    
    hlt
    
    ret
sceneManager Endp


left    equ 61h                                     
right   equ 64h
up      equ 77h
down    equ 73h
help    equ 69h

;Define player and goal start
xPos DB 013h
yPos DB 008h

playerColor DB 00Eh
playerBackground DB 020h
toggleColor DB 0

txPos DB ?
tyPos DB ?

playerMove Proc
    
    mov DH, yPos
    mov DL, xPos
    
    ;Checks for left input
    isLeft:
        cmp AL, left
        jnz isRight:
        dec DL
        jmp runMove:
    
    ;Checks for right input
    isRight:
        cmp AL, right
        jnz isUp:
        inc DL
        jmp runMove:
    
    ;Checks for up input    
    isUp:
        cmp AL, up
        jnz isDown:
        dec DH
        jmp runMove:
    
    ;Checks for down input
    isDown:
        cmp AL, down
        jnz isHelp:
        inc DH
        jmp runMove:
    
    ;Checks for help input    
    isHelp:
        cmp AL, help
        jnz endMove:
            mov runScriptedEvent, 1
            call eventManager
            jmp endMove:
    
    ;Moves the curosr and places character    
    runMove:
        mov txPos, DL
        mov tyPos, DH
        
        call checkHit
        cmp isWall, 1
        jz hitWall:
        cmp isWall, 2
        jnz innerRunMove:
            mov isWall, 0
            jmp endMove:      
        
        
        innerRunMove:
        mov DH, yPos
        mov DL, xPos
        mov AH, 2h
        int 10h ;Set cursor location
        
        mov AL, 32
        mov CX, 1
        mov BL, playerBackground
        mov AH, 9h
        int 10h ;Write null char to cursor location
        
        cmp toggleColor, 1
        jnz innerRunMove1:
            cmp tyPos, 5
            jnl colorMove:
                mov playerBackground, 020h
                mov playerColor, 02Eh
                jmp innerRunMove1:
            
            colorMove:    
            mov playerBackground, 060h
            mov playerColor, 06Eh
            
        
        innerRunMove1:
        mov DH, tyPos
        mov DL, txPos
        mov BL, playerColor 
        mov BH, 0
        mov AH, 2h
        int 10h ;Set cursor location
        
        mov AL, 1h
        mov AH, 9h
        int 10h ;Write player char to cursor location
        
        ;Update X,Y pos of player in memory
        mov xPos, DL
        mov yPos, DH
        jmp endMove:
    
    ;Beep if the player hit a wall                   
    hitWall:
    mov AL, 7
    putc AL
    dec isWall
    
    endMove:
    ret
playerMove Endp


isWall DB 0

HitChar DB ?

nullFlags DB 0
flagEnd DB 0
wallFlag DB 0

checkHit Proc
    
    mov BX, 0
    mov BL, txPos
    
    mov CX, BX
    mov AX, 8
    mul CX
    mov CX, AX
    inc CX
    
    mov BL, tyPos
    
    mov DX, BX
    mov AX, 8
    mul DX
    mov DX, AX
    inc DX
    
    mov AH, 0Dh
    int 10h
    
    call checkHitProc   
    cmp flagEnd, 0
    jnz checkHitend:
    cmp wallFlag, 1
    jz setIsWall:
    
    shiftCheck:
    inc CX
    add DX, 3
    mov AH, 0Dh
    int 10h
    
    call checkHitProc
    cmp flagEnd, 0
    jnz checkHitend:
    cmp wallFlag, 1
    jz setIsWall:
    
    shiftCheck1:    
    sub DX, 2
    add CX, 2
    mov AH, 0Dh
    int 10h
    
    call checkHitProc
    cmp flagEnd, 0
    jnz checkHitend:
    cmp wallFlag, 1
    jz setIsWall:
    
    checkNullFlags:
    cmp nullFlags, 3
    jnz setIsWall:
        mov nullFlags, 0
        jmp checkHitend:
        
    setIsWall:
    inc isWall
    mov wallFlag, 0
    
    checkHitend:
    mov flagEnd, 0
    mov nullFlags, 0
    mov wallFlag, 0
    ret
checkHit Endp 


checkHitProc Proc
    
    checkHitNull:
    cmp AL, 0  
    jnz nullFlagCheckGreen:
        inc nullFlags
        jmp endProc:
    nullFlagCheckGreen:    
    cmp AL, 2
    jnz nullFlagCheckBrown:
        inc nullFlags
        jmp endProc:
    nullFlagCheckBrown:
    cmp AL, 6
    jnz nullFlagCheckDarkGray:
        inc nullFlags
        jmp endProc:
    nullFlagCheckDarkGray:
    cmp AL, 8
    jnz checkHitDoor:
        inc nullFlags
        jmp endProc:
    
    checkHitDoor:
    cmp AL, 4
    jnz checkHitButton:
        mov HitChar, 0
        call interactions
        inc flagEnd
        jmp endProc:
    
    checkHitButton:
    cmp AL, 9
    jnz checkHitKey:
        mov HitChar, 1
        call interactions
        inc flagEnd
        jmp endProc:
    
    checkHitKey:
    cmp AL, 0Eh
    jnz mustBeWall:
        mov HitChar, 2
        call interactions
        inc flagEnd
        
    mustBeWall:
    inc wallFlag
    
    endProc:
    ret
checkHitProc Endp


interactions Proc
    
    charDoor:
    cmp HitChar, 0
    jnz charButton      
        
        CastleEx:
        cmp SceneNum, 2
        jnz Crossroads
            cmp tyPos, 8
            jnz castleExinner:
                mov isWall, 1
                jmp interactionsEnd:
            
            castleExinner:    
            mov switchScene, 3
            mov roomDirection, 3
            mov isWall, 2
            jmp interactionsEnd: 
        
        Crossroads:
        cmp SceneNum, 3
        jnz CityCenter
            cmp tyPos, 3
            jnz crossroadsinner1:
                mov isWall, 1
                jmp interactionsEnd:
            
            crossroadsinner1:
            cmp txPos, 13
            jnz crossroadsinner2:
                mov switchScene, 4
                mov roomDirection, 4
                mov isWall, 2
                jmp interactionsEnd:
            
            crossroadsinner2:
            cmp CavesActive, 1
            jnz crossroadsinner3:   
                mov switchScene, 11
                mov roomDirection, 2
                mov isWall, 2
                jmp interactionsEnd:
            
            crossroadsinner3:    
            mov isWall, 1
            jmp interactionsEnd:
        
        CityCenter:
        cmp SceneNum, 4
        jnz CityDungeonEx
            cmp tyPos, 2
            jnz cityCenterinner1:
                cmp CityDocksActive, 1
                jnz cityCenterinner1inner:
                    mov switchScene, 7
                    mov roomDirection, 1
                    mov isWall, 2
                    jmp interactionsEnd:
               
               cityCenterinner1inner:     
               mov isWall, 1
               jmp interactionsEnd:
            
            cityCenterinner1:   
            cmp tyPos, 8
            jnz cityCenterinner2:
                cmp txPos, 11
                jnz cityCenterinner2inner:
                    mov switchScene, 5
                    mov roomDirection, 4
                    mov isWall, 2
                    jmp interactionsEnd:
                
                cityCenterinner2inner:    
                mov switchScene, 3
                mov roomDirection, 2
                mov isWall, 2
                jmp interactionsEnd:
            
            cityCenterinner2:    
            cmp KeyRoomActive, 1
            jnz cityCenterinner3inner:
                mov switchScene, 14
                mov isWall, 2
                jmp interactionsEnd:
            
            cityCenterinner3inner:    
            mov isWall, 1
            jmp interactionsEnd:
        
        CityDungeonEx:
        cmp SceneNum, 5
        jnz CityDungeonIn
            cmp txPos, 13
            jnz cityDungeonExinner1:
                cmp collectedCityDungeon, 0
                jnz cityDungeonExinner1inner:
                    mov switchScene, 6
                    mov isWall, 2
                    jmp interactionsEnd:
                
                cityDungeonExinner1inner:    
                mov isWall, 1
                jmp interactionsEnd:
                
            cityDungeonExinner1:    
            mov switchScene, 4
            mov roomDirection, 2
            mov isWall, 2
            jmp interactionsEnd:
        
        CityDungeonIn:
        cmp SceneNum, 6
        jnz CityDocks
            cmp collectedCityDungeon, 1
            jnz cityDungeonIninner:
                mov switchScene, 5
                mov roomDirection, 2
                mov isWall, 2
                jmp interactionsEnd:
            
            cityDungeonIninner:    
            mov isWall, 1
            jmp interactionsEnd:
        
        CityDocks:
        cmp SceneNum, 7
        jnz IslandDocks
            cmp txPos, 17
            jnz cityDocksinner:
                mov switchScene, 8
                mov roomDirection, 1
                mov isWall, 2
                jmp interactionsEnd:
            
            cityDocksinner:    
            mov switchScene, 4
            mov roomDirection, 3
            mov isWall, 2
            jmp interactionsEnd:
        
        IslandDocks:
        cmp SceneNum, 8
        jnz TempleEx
            cmp txPos, 22
            jnz islandDocksinner:
                mov switchScene, 9
                mov roomDirection, 1
                mov isWall, 2
                jmp interactionsEnd:
            
            islandDocksinner:    
            mov switchScene, 7
            mov roomDirection, 3
            mov isWall, 2
            jmp interactionsEnd:
        
        TempleEx:
        cmp SceneNum, 9
        jnz TempleIn
            cmp txPos, 19
            jnz templeExinner1:
                cmp collectedTemple, 0
                jnz templeExinner1inner:
                    mov switchScene, 10
                    mov isWall, 2
                    jmp interactionsEnd:
                
                templeExinner1inner:    
                mov isWall, 1
                jmp interactionsEnd:
            
            templeExinner1:    
            mov switchScene, 8
            mov roomDirection, 3
            mov isWall, 2
            jmp interactionsEnd:
        
        TempleIn:
        cmp SceneNum, 10
        jnz CavesEx
            cmp tyPos, 15
            jnz templeIninner1:
                cmp collectedTemple, 1
                jnz templeIninner1inner:
                    mov switchScene, 9
                    mov roomDirection, 3
                    mov isWall, 2
                    jmp interactionsEnd:
                
                templeIninner1inner:    
                mov isWall, 1
                jmp interactionsEnd:
            
            templeIninner1:    
            cmp txPos, 33
            jnz templeIninner2:
                cmp tyPos, 6
                jnz templeIninner2inner:
                    mov isWall, 1
                    jmp interactionsEnd:
                
                templeIninner2inner:
                mov runScriptedEvent, 5    
                call eventManager
                jmp interactionsEnd:
            
            templeIninner2:    
            cmp tyPos, 6
            jnz templeIninner3:
                mov isWall, 1
                jmp interactionsEnd:
            
            templeIninner3:
            cmp txPos, 11
            jnz templeIninner4:        
                mov isWall, 1
                jmp interactionsEnd:
             
            templeIninner4: 
            cmp txPos, 18
            jnz templeIninner5:         
                mov isWall, 1
                jmp interactionsEnd:
            
            templeIninner5:
            cmp txPos, 21
            jnz templeIninner6:         
                mov isWall, 1
                jmp interactionsEnd:
            
            templeIninner6:
            cmp tyPos, 2
            jnz templeIninner7:                   
                mov isWall, 1
                jmp interactionsEnd:
            
            templeIninner7:
            mov runScriptedEvent, 5
            call eventManager
            jmp interactionsEnd:    
        
        CavesEx:
        cmp SceneNum, 11
        jnz CaveUp
            cmp tyPos, 8
            jnz caveExinner1:
                mov switchScene, 3
                mov roomDirection, 4
                mov isWall, 2
                jmp interactionsEnd:
            
            caveExinner1:
            cmp tyPos, 14
            jnz caveExinner2:
                cmp collectedCaveDown, 0
                jnz caveExinner2inner:
                    mov switchScene, 13
                    mov isWall, 2
                    jmp interactionsEnd:
                
                caveExinner2inner:    
                mov isWall, 1
                jmp interactionsEnd:
            
            caveExinner2:
            cmp collectedCaveUp, 0
            jnz caveExinner3:
                mov switchScene, 12
                mov isWall, 2
                jmp interactionsEnd:
            
            caveExinner3:    
            mov isWall, 1
            jmp interactionsEnd:
        
        CaveUp:
        cmp SceneNum, 12
        jnz CaveDown
            cmp collectedCaveUp, 1
            jnz caveUpinner:
                mov switchScene, 11
                mov roomDirection, 3
                mov isWall, 2
                jmp interactionsEnd:
            
            caveUpinner:    
            mov isWall, 1
            jmp interactionsEnd:
        
        CaveDown:
        cmp SceneNum, 13
        jnz interactionsEnd:
            cmp collectedCaveDown, 1
            jnz caveDowninner:
                mov switchScene, 11
                mov roomDirection, 1
                mov isWall, 2
                jmp interactionsEnd:
            
            caveDowninner:    
            mov isWall, 1
            jmp interactionsEnd:
        
    
    charButton:
    cmp HitChar, 1
    jnz charKey
    
        cmp txPos, 17
        jnz button4
            button1:
            cmp tyPos, 2
            jnz button2
                mov runScriptedEvent, 7
                call eventManager
                mov isWall, 2
                jmp interactionsEnd:    
            
            button2:
            cmp tyPos, 4
            jnz button3
                mov runScriptedEvent, 8
                call eventManager
                mov isWall, 2
                jmp interactionsEnd:
            
            button3:
            mov runScriptedEvent, 9
            call eventManager
            mov isWall, 2
            jmp interactionsEnd:
         
        button4:
        cmp tyPos, 2
        jnz button5
            mov runScriptedEvent, 10
            call eventManager
            mov isWall, 2
            jmp interactionsEnd:
        
        button5:
        cmp tyPos, 4
        jnz button6
            mov runScriptedEvent, 11
            call eventManager
            mov isWall, 2
            jmp interactionsEnd:
        
        button6:
        mov runScriptedEvent, 12
        call eventManager
        mov isWall, 2
        jmp interactionsEnd:
         
    
    charKey:        
        CityDungeon:
        cmp SceneNum, 6
        jnz IslandTemple
            cmp txPos, 4
            jnz notCityKey:
                inc collectedCityDungeon
                mov runScriptedEvent, 2
                call eventManager
                mov isWall, 0
                call activeCheck
                jmp interactionsEnd:
                
           notCityKey:
           mov isWall, 1
           jmp interactionsEnd: 
        
        IslandTemple:
        cmp SceneNum, 10
        jnz CaveDarkness
            cmp txPos, 33
            jnz notTempleKey:
                inc collectedTemple
                mov runScriptedEvent, 6
                call eventManager
                mov isWall, 0
                call activeCheck
                jmp interactionsEnd:
                
            notTempleKey:
            mov isWall, 1
            jmp interactionsEnd:
        
        CaveDarkness: 
        cmp SceneNum, 12
        jnz CaveGates
            cmp txPos, 19
            jnz notDarkKey:
                inc collectedCaveUp
                mov activeCaveDoors, 1
                mov runScriptedEvent, 3
                call eventManager
                mov isWall, 0
                call activeCheck
                jmp interactionsEnd:
           
           notDarkKey:
           mov isWall, 1
           jmp interactionsEnd:
        
        CaveGates:
        cmp txPos, 28
        jnz notGatesKey:
            inc collectedCaveDown
            mov activeCaveDoors, 2
            mov runScriptedEvent, 3
            call eventManager
            mov isWall, 0
            call activeCheck
            jmp interactionsEnd:
            
       notGatesKey:
       mov isWall, 1
       jmp interactionsEnd:
            
    
    interactionsEnd:
    ret
interactions Endp


activeCaveDoors DB 0
runScriptedEvent DB 0
storeMap DW 11815

eventManager Proc
    
    CastleIn:
    cmp runScriptedEvent, 0
    jnz HelpScript:
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 11815
        call mapRender
        
        call waitTimer
        
        mov loadMap, 12141
        call mapRender
        
        call waitTimer
        
        mov loadMap, 12467
        call mapRender
        
        call waitTimer
        
        mov loadMap, 12793
        call mapRender
        
        mov npcXPos, 013h
        mov npcYPos, 007h
        mov npcChar, 001h
        mov npcColor, 00Eh
        mov numMoves, 6
        call npcManager
        jmp eventManagerEnd:
        
    
    HelpScript:
    cmp runScriptedEvent, 1
    jnz CityDungeonInScript:
        cmp loadMap, 11815
        jl  HelpScriptinner:
            mov AX, loadMap
            mov storeMap, AX
            
            mov loadMap, 34635
            mov numChar, 326
            mov background, 00Fh
            mov renderYPos, 17
            call mapRender
            
            mov readStart, 102
            mov readLength, 4
            call drawProps
            
            call waitTimer
            
            mov AX, storeMap
            mov loadMap, AX
            call mapRender
            jmp HelpScriptend:
        
        HelpScriptinner:    
        mov loadMap, 34635
        mov numChar, 326
        mov background, 00Fh
        mov renderYPos, 17
        call mapRender
            
        mov readStart, 102
        mov readLength, 4
        call drawProps
            
        HelpScriptend:    
        jmp eventManagerEnd:
    
    CityDungeonInScript:
    cmp runScriptedEvent, 2
    jnz CavesScript:
        mov readStart, 47
        mov readLength, 4
        call drawProps
        
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 16053
        call mapRender
        
        jmp eventManagerEnd:
    
    CavesScript:
    cmp runScriptedEvent, 3
    jnz TempleDoors
        cmp activeCaveDoors, 2
        jnz cavesScriptinner:  
            mov readStart, 108
            mov readLength, 1
            call drawProps
            jmp cavesScriptend:
        
        cavesScriptinner:
        mov readStart, 106
        mov readLength, 1
        call drawProps
        
        cavesScriptend:
        mov activeCaveDoors, 0
        jmp eventManagerEnd:
    
    TempleDoors:
    cmp runScriptedEvent, 5
    jnz TempleExScript
        cmp yPos, 13
        jnz templeDoors12:
            cmp xPos, 13
            jnz templeDoors1206:
                mov readStart, 244
                mov readLength, 2
                call drawProps
                mov xPos, 21
                mov yPos, 11
                mov isWall, 2
                jmp eventManagerEnd:
            
            templeDoors1206:
            cmp xPos, 6
            jnz templeDoors1204:
                mov readStart, 232
                mov readLength, 2
                call drawProps
                mov xPos, 12
                mov yPos, 11
                mov isWall, 2
                jmp eventManagerEnd:
            
            templeDoors1204:
            cmp xPos, 4
            jnz templeDoors1202:
                mov readStart, 230
                mov readLength, 2
                call drawProps
                mov xPos, 17
                mov yPos, 3
                mov isWall, 2
                jmp eventManagerEnd:
            
            templeDoors1202:
            ;cmp xPos, 2
            mov readStart, 228
            mov readLength, 2
            call drawProps
            mov xPos, 6
            mov yPos, 5
            mov isWall, 2
            jmp eventManagerEnd:
        
        templeDoors12:
        cmp yPos, 12
        jnz templeDoors11:
            cmp xPos, 33
            jnz templeDoors1221:
                mov readStart, 252
                mov readLength, 2
                call drawProps
                mov xPos, 4
                mov yPos, 14
                mov isWall, 2
                jmp eventManagerEnd:
            
            templeDoors1221:
            cmp xPos, 22
            jnz templeDoors1219:
                mov readStart, 248
                mov readLength, 2
                call drawProps
                mov xPos, 4
                mov yPos, 14
                mov isWall, 2
                jmp eventManagerEnd:
            
            templeDoors1219:
            ;cmp xPos, 19
            mov readStart, 246
            mov readLength, 2
            call drawProps
            mov xPos, 33
            mov yPos, 7
            mov isWall, 2
            jmp eventManagerEnd:
        
        templeDoors11:
        cmp yPos, 11
        jnz templeDoors9:
            ;cmp xPos, 13
            mov readStart, 242
            mov readLength, 2
            call drawProps
            mov xPos, 17
            mov yPos, 3
            mov isWall, 2
            jmp eventManagerEnd:
        
        templeDoors9:
        cmp yPos, 9
        jnz templeDoors4:
            ;cmp xPos, 13
            mov readStart, 240
            mov readLength, 2
            call drawProps
            mov xPos, 17
            mov yPos, 3
            mov isWall, 2
            jmp eventManagerEnd:
        
        templeDoors4:
        cmp yPos, 4
        jnz templeDoors3:
            cmp xPos, 25
            jnz templeDoors0407:
                mov readStart, 250
                mov readLength, 2
                call drawProps
                mov xPos, 4
                mov yPos, 14
                mov isWall, 2
                jmp eventManagerEnd:
            
            templeDoors0407:
            cmp xPos, 7
            jnz templeDoors0405:
                mov readStart, 236
                mov readLength, 2
                call drawProps
                mov xPos, 25
                mov yPos, 3
                mov isWall, 2
                jmp eventManagerEnd:
            
            templeDoors0405:
            ;cmp xPos, 5
            mov readStart, 234
            mov readLength, 2
            call drawProps
            mov xPos, 4
            mov yPos, 14
            mov isWall, 2
            jmp eventManagerEnd:
        
        templeDoors3:
        ;cmp yPos, 3
        ;cmp xPos, 16
        mov readStart, 238
        mov readLength, 2
        call drawProps
        mov xPos, 4
        mov yPos, 14
        mov isWall, 2
        jmp eventManagerEnd:    
            
    TempleExScript:
    cmp runScriptedEvent, 6
    jnz CaveDown1
        mov readStart, 91
        mov readLength, 1
        call drawProps
        jmp eventManagerEnd:
    
    CaveDown1:
    cmp runScriptedEvent, 7
    jnz CaveDown2
        mov readStart, 124
        mov readLength, 1
        call drawProps
        mov readStart, 128
        call drawProps
        jmp eventManagerEnd:
    
    CaveDown2:
    cmp runScriptedEvent, 8
    jnz CaveDown3
        mov readStart, 126
        mov readLength, 1
        call drawProps
        mov readStart, 127
        call drawProps
        mov readStart, 116
        call drawProps
        jmp eventManagerEnd:
    
    CaveDown3:
    cmp runScriptedEvent, 9
    jnz CaveDown4
        mov readStart, 125
        mov readLength, 1
        call drawProps
        mov readStart, 127
        call drawProps
        mov readStart, 117
        call drawProps
        mov readStart, 119
        call drawProps
        jmp eventManagerEnd:
    
    CaveDown4:
    cmp runScriptedEvent, 10
    jnz CaveDown5
        mov readStart, 126
        mov readLength, 1
        call drawProps
        mov readStart, 128
        call drawProps
        mov readStart, 115
        call drawProps
        jmp eventManagerEnd:
    
    CaveDown5:
    cmp runScriptedEvent, 11
    jnz CaveDown6
        mov readStart, 124
        mov readLength, 1
        call drawProps
        mov readStart, 125
        call drawProps
        mov readStart, 117
        call drawProps
        jmp eventManagerEnd:
    
    CaveDown6:
    cmp runScriptedEvent, 12
    jnz KeyRoom
        mov readStart, 124
        mov readLength, 1
        call drawProps
        mov readStart, 116
        call drawProps
        mov readStart, 117
        call drawProps
        mov readStart, 118
        call drawProps
        jmp eventManagerEnd:
    
    KeyRoom:
    cmp runScriptedEvent, 13
    jnz GoldenPi
        mov readStart, 129
        mov readLength, 1
        call drawProps
        
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 23551
        call mapRender
        
        call waitTimer
        
        mov loadMap, 23877
        call mapRender
        
        mov readStart, 130
        mov readLength, 38
        call drawProps
        
        mov loadMap, 24203
        call mapRender
        
        call waitTimer
        
        mov loadMap, 24529
        call mapRender
        
        mov readStart, 168    
        mov readLength, 6
        call drawProps
        
        call waitTimer
        
        mov switchScene, 15
        
        jmp eventManagerEnd:
    
    GoldenPi:
    cmp runScriptedEvent, 14
    jnz Ending
        mov readStart, 174
        mov readLength, 6
        call drawProps
        
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        
        mov loadMap, 24855
        call mapRender
        call waitTimer
        mov loadMap, 25181
        call mapRender
        call waitTimer
        mov loadMap, 25507
        call mapRender
        
        mov readStart, 180
        mov readLength, 6
        call drawProps
        
        mov loadMap, 25833
        call mapRender
        call waitTimer
        mov loadMap, 26159
        call mapRender
        call waitTimer
        mov loadMap, 26485
        call mapRender
        call waitTimer
        mov loadMap, 26811
        call mapRender
        
        mov readStart, 186
        mov readLength, 7
        call drawProps
        
        mov loadMap, 27137
        call mapRender
        call waitTimer
        mov loadMap, 27463
        call mapRender
        call waitTimer
        mov loadMap, 27789
        call mapRender
        call waitTimer
        
        mov readStart, 193
        mov readLength, 1
        call drawProps
        
        mov loadMap, 28115
        call mapRender
        call waitTimer
        mov loadMap, 28441
        call mapRender
        call waitTimer
        mov loadMap, 28767
        call mapRender
        call waitTimer
        mov loadMap, 29093
        call mapRender
        
        mov readStart, 194
        mov readLength, 6
        call drawProps
        
        mov loadMap, 29419
        call mapRender
        
        mov readStart, 200
        mov readLength, 7
        call drawProps
        
        mov loadMap, 29745
        call mapRender
        call waitTimer
        mov loadMap, 30071
        call mapRender
        call waitTimer
        mov loadMap, 30397
        call mapRender
        
        mov readStart, 207
        mov readLength, 21
        call drawProps
        
        mov loadMap, 30723
        call mapRender
        call waitTimer
        
        mov switchScene, 16
        
        jmp eventManagerEnd:
             
    Ending:
    cmp runScriptedEvent, 15       
        mov npcXPos, 013h
        mov npcYPos, 00Ch
        mov npcChar, 001h
        mov npcColor, 00Eh
        mov pathingB, 6
        mov numMoves, 5
        call npcManager
        
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        mov loadMap, 31049
        call mapRender
        call waitTimer
        mov loadMap, 31375
        call mapRender
        call waitTimer
        mov loadMap, 31701
        call mapRender
        
        mov npcXPos, 013h
        mov npcYPos, 005h
        mov npcChar, 002h
        mov npcColor, 003h
        mov pathingB, 11
        mov numMoves, 1
        call npcManager
        
        mov loadMap, 32027
        call mapRender
        call waitTimer
        mov loadMap, 32353
        call mapRender
        call waitTimer
        mov loadMap, 32679
        call mapRender
        
        mov npcXPos, 013h
        mov npcYPos, 005h
        mov npcColor, 00Dh
        mov pathingB, 11
        mov numMoves, 1
        call npcManager
        
        mov loadMap, 33005
        call mapRender
        call waitTimer
        mov loadMap, 33331
        call mapRender
        call waitTimer
        mov loadMap, 33657
        call mapRender
        call waitTimer
        mov loadMap, 33983
        call mapRender
        call waitTimer
        
        mov loadMap, 34961
        mov numChar, 1023
        mov renderYPos, 0
        mov background, 000h
        call mapRender
        
        mov loadMap, 34309
        mov numChar, 326
        mov renderYPos, 17
        mov background, 00Fh
        call mapRender
        call waitTimer
        
        mov loadMap, 0
        mov numChar, 695
        mov renderYPos, 0
        mov background, 00Eh
        call mapRender
        call waitTimer
        
        mov loadMap, 11120
        mov background, 00Fh
        call mapRender
        
        mov AL, 7
        putc AL
        
        jmp eventManagerEnd:
          
    
    eventManagerEnd:
    ret
eventManager Endp


readLength DW ?
readStart DW ?

checkCount DW ?
holdB DW ?

drawProps Proc
    
    mov CX, readLength
    mov BX, readStart
    drawLoop:
        mov checkCount, CX
        mov holdB, BX
        
        mov DH, propY + BX
        mov DL, propX + BX
        mov BX, 0
        mov AH, 2h
        int 10h
        
        mov BX, holdB
        
        mov AL, propChar + BX
        mov BL, propColor + BX
        mov BH, 0
        mov CX, 1
        mov AH, 9h
        int 10h
        
        mov BX, holdB
        mov CX, checkCount
        
        inc BX
        
        loop drawLoop
    
    ret
drawProps Endp            
            
            
numChar DW ? ;695 ;326 ;1023
renderXPos DB 0 ;0
renderYPos DB 0 ;17

loadMap DW 0 ;11815 ;34961
background DB 00Fh ;0010_1111b

mapRender Proc
                
    mov AL, 1
    mov CX, numChar
    mov DL, renderXPos
    mov DH, renderYPos
    push CS
    pop ES
    lea BX, [maps]
    add BX, loadMap
    mov BP, BX
    mov BH, 0
    mov BL, background
    mov AH, 13h
    int 10h 
    
    ret               
mapRender Endp


numMoves DW ?

pathingB DW 0

npcYPos     DB ?
npcXPos     DB ?
npcChar     DB ?
npcColor    DB ?

npcManager Proc
    moveCursor:
    mov DH, npcYPos
    mov DL, npcXPos
    mov BH, 0
    mov AH, 2h
    int 10h
    
    mov CX, numMoves
    
    npcMovementLoop:
        mov checkCount, CX
        
        mov DH, npcYPos
        mov DL, npcXPos
        
        mov AL, 0
        mov BH, 0
        mov CX, 1
        mov AH, 9h
        int 10h
        
        mov BX, pathingB
        
        mov AL, npcMovement + BX            
        
        checkUp:
        cmp AL, 1
        jnz checkRight:
        dec DH
        jmp writeChar:
        
        checkRight:
        cmp AL, 2
        jnz checkDown:
        inc DL
        jmp writeChar:
        
        checkDown:
        cmp AL, 3
        jnz checkLeft:
        inc DH
        jmp writeChar:
        
        checkLeft:
        cmp AL, 4
        jnz EraseChar:
        dec DL
        
        writeChar:
        mov BH, 0
        mov AH, 2h
        int 10h
        
        mov npcYPos, DH
        mov npcXPos, DL
        
        mov AL, npcChar
        mov BL, npcColor
        mov CX, 1
        mov AH, 9h
        int 10h
        jmp loopInc:
        
        EraseChar:
        mov BH, 0
        mov AH, 2h
        int 10h
        
        mov AL, 0
        mov BL, 0
        mov CX, 1
        mov AH, 9h
        int 10h
        
        loopInc:
        mov AH, 86h
        mov CX, 07h
        mov DX, 4240h
        int 15h
        
        mov CX, checkCount
        inc pathingB
        
        loop npcMovementLoop
        
    ret
npcManager Endp


waitTimer Proc
     
    mov AH, 86h
    mov CX, 04Ch
    mov DX, 4840h
    int 15h 
     
    ret
waitTimer Endp


activeCheck Proc
    
    checkCavesActiveStatus:
    cmp CavesActive, 0
    jnz checkDocksActiveStatus:
        cmp collectedTemple, 1
        jnz checkDocksActiveStatus:
            inc CavesActive
    
    checkDocksActiveStatus:
    cmp CityDocksActive, 0
    jnz checkKeyRoomActiveStatus:
        cmp collectedCityDungeon, 1
        jnz checkKeyRoomActiveStatus:
            inc CityDocksActive
    
    checkKeyRoomActiveStatus:
    cmp collectedCaveUp, 1
    jnz activeCheckend:
        cmp collectedCaveDown, 1
        jnz activeCheckend:
            cmp collectedTemple, 1
            jnz activeCheckend:
                cmp collectedCityDungeon, 1
                jnz activeCheckend:
                    mov KeyRoomActive, 1
    
    activeCheckend:
    ret
activeCheck Endp


bufferWipe Proc
    
    mov AH, 0Ch
    mov AL, 0
    int 21h
    
    ret
bufferWipe Endp

maps DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0Ah,0Dh
     DB 219,0,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,219,0,0,0,219,0,219,0,219,219,0,0,0,0,0,0,219,0,0,0,219,0,219,219,0,0,220,219,219,0,0,219,0,0,219,0Ah,0Dh
     DB 219,0,0,0,219,0,0,0,219,0,219,0,219,0,0,0,0,0,0,0,219,219,219,0,0,0,219,0,219,0,219,0,0,0,223,219,223,0,219,0Ah,0Dh
     DB 219,0,0,0,219,0,0,0,219,223,219,0,219,219,0,0,0,0,0,0,219,0,0,0,219,0,219,219,220,0,223,219,220,0,0,219,0,0,219,0Ah,0Dh
     DB 219,0,0,0,219,0,0,0,219,0,219,0,219,0,0,0,0,0,0,0,219,0,0,0,219,0,219,0,219,0,0,0,219,0,0,219,0,0,219,0Ah,0Dh
     DB 219,0,0,0,219,0,0,0,219,0,219,0,219,219,0,0,0,0,0,0,219,0,0,0,219,0,219,0,219,0,219,219,223,0,0,219,0,0,219,0Ah,0Dh
     DB 219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,0,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,0,0,0,219,0,0,0,220,219,220,0,219,0,219,0,219,219,0,0,219,0,0,219,0,219,219,0,219,0,219,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,0,0,0,219,0,0,0,219,0,219,0,219,0,219,0,219,0,219,0,219,220,0,219,0,219,0,0,219,0,219,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,0,0,0,219,0,0,0,219,0,219,0,219,0,219,0,219,219,220,0,219,219,0,219,0,219,219,0,223,219,223,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,0,219,0,219,0,0,0,219,0,219,0,219,0,219,0,219,0,219,0,219,0,219,219,0,219,0,0,0,219,0,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,0,223,219,223,0,0,0,223,219,223,0,219,219,219,0,219,0,219,0,219,0,223,219,0,219,219,0,0,219,0,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219 ;Title Screen
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,0,0,0,0,0,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,219,0,0,0,0,0,219,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,219,0,0,0,0,0,219,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,0,0,0,0,0,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,15,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;Castle Interior
     DB 0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0Ah,0Dh
     DB 0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0Ah,0Dh
     DB 0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0Ah,0Dh
     DB 0,0,0,219,219,219,219,219,0,223,0,223,0,219,219,219,219,219,219,219,219,219,219,219,219,219,0,223,0,223,0,219,219,219,219,219,0,0,0,0Ah,0Dh
     DB 0,0,0,0,219,219,219,0,0,0,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,219,219,219,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,219,0,0,0,219,0,219,0,0,0,0,0,219,219,219,219,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,219,15,219,0,0,219,0,0,0,0,0,219,219,219,219,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,219,0,0,0,0,0,219,219,219,219,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,223,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,220,0,220,0,220,0,220,0,220,0,220,0,220,0,220,0,219,0,0,0,219,0,220,0,220,0,220,0,220,0,220,0,220,0,220,0,220,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,25,15,25,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219 ;Castle Exterior
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,24,15,24,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,27,0,0,0,0,0,0,0,0,0,0,0,26,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,27,0,0,0,0,0,0,0,0,0,0,0,26,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,27,0,0,0,0,0,0,0,0,0,0,0,26,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,27,0,0,0,0,0,0,0,0,0,0,0,26,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,35,0Ah,0Dh
     DB 176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,177,177,176,176,176,176,176,176,176,176,176,176,176,0Ah,0Dh
     DB 176,176,177,176,176,176,176,176,176,176,177,176,176,176,176,176,176,176,176,176,176,176,176,176,176,177,176,176,176,176,176,176,176,177,177,176,176,176,176,0Ah,0Dh
     DB 176,176,177,176,176,176,176,176,176,177,177,176,176,176,176,176,177,176,176,176,176,176,176,177,176,176,176,176,176,176,176,176,177,176,177,176,176,176,176,0Ah,0Dh
     DB 176,176,177,177,176,176,176,176,176,177,176,176,176,176,176,177,176,176,176,176,176,176,176,176,177,177,176,176,176,176,176,176,176,176,176,176,176,176,176,0Ah,0Dh
     DB 176,176,176,177,177,176,176,176,176,176,176,176,176,176,177,176,176,176,176,176,176,176,176,176,176,177,176,176,176,177,176,176,177,176,176,176,176,176,176,0Ah,0Dh
     DB 176,176,176,176,176,177,176,176,176,176,176,176,177,176,176,176,176,176,176,177,177,176,176,176,176,176,176,176,176,177,176,177,176,176,176,176,177,177,176,0Ah,0Dh
     DB 176,176,176,176,176,176,176,176,176,176,176,177,177,176,176,176,176,177,177,177,176,176,176,176,176,176,176,176,176,176,177,176,176,176,176,176,176,176,176 ;Castle Crossroad
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,186,0,0,0,186,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,0,0,186,0,0,0,186,0,201,205,205,205,205,205,205,187,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,205,205,188,24,15,24,200,205,185,0,0,0,0,0,0,186,0,0,220,220,220,220,0,0,0Ah,0Dh
     DB 0,0,219,219,219,219,219,0,0,219,219,219,219,219,219,0,0,0,0,0,0,0,0,186,0,220,0,0,0,0,186,0,0,219,219,219,219,0,0,0Ah,0Dh
     DB 0,0,219,219,219,219,219,0,0,219,219,219,219,219,219,0,0,0,0,0,0,0,0,219,219,219,219,0,0,0,186,0,0,219,219,219,219,0,0,0Ah,0Dh
     DB 0,0,219,219,219,219,219,0,0,219,219,219,0,223,0,0,0,0,0,0,0,0,0,219,219,219,219,0,0,0,186,0,0,219,223,219,0,0,0,0Ah,0Dh
     DB 0,0,223,223,223,0,0,0,0,219,219,219,0,0,0,0,0,0,0,0,0,0,0,223,223,223,223,205,205,205,188,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,27,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,26,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,27,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,26,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,219,220,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,0,0,0,219,219,219,0,0,0,0Ah,0Dh
     DB 0,0,219,219,0,219,219,0,0,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,35,0,0,219,219,219,0,0,0,0Ah,0Dh
     DB 0,0,219,219,220,219,219,0,0,219,219,219,201,205,205,205,219,220,220,15,220,220,219,205,205,205,187,219,219,219,0,0,0,219,219,219,0,0,0,0Ah,0Dh
     DB 0,0,219,219,219,219,219,0,0,219,219,219,186,0,234,0,219,219,219,219,219,219,219,0,0,0,186,219,219,219,35,0,0,219,219,219,0,0,0,0Ah,0Dh
     DB 0,0,219,219,219,219,219,0,0,219,219,219,186,0,0,0,219,219,219,219,219,219,219,0,0,234,186,219,219,219,35,0,0,0,223,0,0,0,0,0Ah,0Dh
     DB 0,0,186,0,0,0,186,0,0,219,219,219,186,0,0,234,219,219,219,219,219,219,219,0,234,0,186,223,223,223,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,186,0,0,0,186,0,0,219,219,219,186,0,0,0,219,219,219,219,219,219,219,0,0,0,186,0,0,0,0,0,0,0,0,0,0,0,0 ;City Center
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,223,223,223,219,219,219,219,219,219,219,219,0,0,0,0,0,0,186,0,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,220,0,0,0,219,219,219,219,219,219,0,0,0,0,0,0,186,0,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,219,219,219,219,0,219,219,219,219,219,219,0,0,0,0,0,0,186,0,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,219,219,223,219,0,0,219,219,219,219,219,219,0,0,0,0,0,219,219,0,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,219,0,0,0,0,0,223,0,219,219,219,219,0,0,0,219,219,219,219,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,219,219,219,219,205,205,205,219,219,219,219,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,219,219,0,0,0,0,0,219,219,0,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,26,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,15,0,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,26,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,201,205,205,205,205,205,187,0,0,220,219,219,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,219,220,219,220,219,0,0,0,186,0,0,0,176,0,186,0,0,219,219,219,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,219,219,219,219,219,220,220,220,186,0,176,0,0,0,186,0,0,219,219,219,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,219,219,219,219,219,219,219,219,219,0,0,0,176,0,186,0,0,223,223,223,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,219,219,219,219,219,219,219,219,219,0,0,176,0,0,186,0,0,0,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,219,219,219,219,219,219,219,219,219,0,0,0,176,0,186,0,0,0,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,186,0,0,0,0,0,0 ;City Dungeon Exterior
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,0,0,0,0,0,219,219,219,219,219,219,0,0,219,219,219,219,219,219,219,219,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,0,219,219,219,219,219,219,0,219,219,219,219,219,0,0,0,0,0,219,0,0,0,219,219,0,0,0,0,0,0,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,0,0,0,0,0,219,219,0,0,0,219,219,219,219,0,219,219,219,219,219,219,219,219,219,0,0,219,219,219,0,219,219,0,219,219,0Ah,0Dh
     DB 219,0,0,219,0,219,219,219,219,0,0,0,254,0,219,0,0,0,0,0,219,219,219,0,0,0,0,219,0,0,0,0,219,0,0,219,0,219,219,0Ah,0Dh
     DB 219,219,0,219,0,0,0,0,0,0,219,0,0,0,219,219,0,219,219,0,0,0,219,0,219,219,219,0,0,219,219,0,0,219,0,0,0,219,219,0Ah,0Dh
     DB 219,219,0,0,0,0,219,0,219,219,219,219,219,219,219,219,0,219,219,219,219,0,0,0,0,0,219,219,0,0,0,219,219,0,0,219,0,219,219,0Ah,0Dh
     DB 219,219,219,219,0,219,219,0,0,0,219,219,219,219,219,0,0,219,219,219,219,219,219,0,219,0,0,219,219,0,219,0,219,219,219,0,0,219,219,0Ah,0Dh
     DB 219,219,219,219,0,219,219,219,219,0,0,0,0,0,0,0,219,219,219,219,219,219,219,0,219,219,0,219,219,0,219,0,0,0,0,0,219,219,219,0Ah,0Dh
     DB 219,219,219,219,0,219,219,219,219,0,219,0,219,219,219,219,219,219,219,219,219,219,0,0,0,219,0,219,0,0,219,219,0,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,0,219,219,219,0,0,219,0,219,219,219,219,219,219,219,219,219,219,0,254,0,219,0,219,0,219,0,219,0,0,0,219,219,219,219,0Ah,0Dh
     DB 219,219,223,0,0,0,223,219,219,219,219,219,219,219,219,219,219,219,219,0,0,219,0,0,0,219,0,219,0,219,0,219,0,219,0,219,219,219,219,0Ah,0Dh
     DB 219,219,254,0,0,0,254,219,0,0,0,0,0,219,219,219,219,219,219,0,219,219,219,0,219,219,219,219,0,219,0,219,0,219,0,0,0,15,0,0Ah,0Dh
     DB 219,219,220,0,0,0,220,219,219,219,219,219,0,219,219,219,0,219,219,0,219,219,219,0,0,0,219,0,0,219,0,219,0,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,0,0,0,219,219,219,219,0,219,0,219,219,0,0,0,219,0,219,219,219,219,219,0,219,219,0,219,0,0,0,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,254,0,0,0,219,219,219,219,219,0,0,0,0,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219 ;City Dungeon
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,219,219,219,219,219,219,219,219,219,219,219,219,0,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,219,219,219,219,219,219,219,219,219,219,219,219,0,219,219,219,219,219,219,223,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,0,0,219,219,219,219,219,219,219,0,0,0,219,0,0,219,219,219,219,219,219,219,0,0,0,219,0,0,219,219,0,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,0,0,219,219,219,219,219,219,219,0,0,0,205,15,0,219,219,219,219,219,219,219,0,0,0,205,0,0,219,0,0,0,219,219,219,0Ah,0Dh
     DB 219,219,219,219,0,0,219,219,219,219,219,219,219,0,0,0,219,0,0,219,219,219,219,219,219,219,0,0,0,219,0,0,205,0,0,0,219,219,219,0Ah,0Dh
     DB 219,219,219,219,0,0,219,219,219,219,219,219,219,0,0,0,219,0,0,219,219,219,219,219,219,219,0,0,0,219,0,0,219,0,0,0,219,219,219,0Ah,0Dh
     DB 219,219,219,219,0,0,219,219,219,219,219,219,219,219,0,219,219,0,0,219,219,219,219,219,219,219,219,0,219,219,0,0,219,219,0,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,0,0,219,219,219,219,219,219,219,219,219,219,219,0,0,219,219,219,219,219,219,219,219,219,219,219,0,0,219,219,219,219,219,219,219,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,186,0,0,0,0,254,0,0,0,0,186,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,186,0,0,0,0,0,0,0,0,0,186,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,186,0,0,0,0,0,0,0,0,0,186,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,186,0,0,0,0,0,0,0,0,0,186,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,186,0,0,0,0,0,0,0,0,0,186,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,25,15,25,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;City Docks
     DB 219,219,219,219,219,219,219,219,219,0,186,0,0,0,0,0,219,219,219,0,186,0,0,0,186,0,0,0,219,219,219,219,0,0,0,0,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,0,186,0,220,220,220,0,219,219,219,0,186,0,0,0,186,0,0,0,219,219,219,219,0,0,0,0,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,186,0,219,219,219,205,219,219,219,0,186,0,0,0,186,0,0,0,219,219,219,219,0,0,0,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,200,205,219,219,219,0,0,223,200,205,188,24,15,24,200,205,205,205,188,0,223,0,0,0,0,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,0,0,223,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,219,219,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,219,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,219,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,205,15,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,219,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219 ;Island Docks
     DB 0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,219,219,219,0,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,219,219,219,0,0,0,0Ah,0Dh
     DB 0,0,219,219,219,219,219,0,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,219,219,219,219,219,0,0,0Ah,0Dh
     DB 0,0,219,219,219,219,219,0,0,0,0,219,219,219,219,219,219,219,223,15,223,219,219,219,219,219,219,219,0,0,0,0,219,219,219,219,219,0,0,0Ah,0Dh
     DB 0,0,219,219,219,219,219,0,0,0,0,219,219,219,219,219,219,0,0,0,0,0,219,219,219,219,219,219,0,0,0,0,219,219,219,219,219,0,0,0Ah,0Dh
     DB 0,0,0,219,223,219,0,0,0,0,0,219,219,219,219,219,219,0,0,0,0,0,219,219,219,219,219,219,0,0,0,0,0,219,223,219,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,219,219,0,0,219,219,0,0,0,0,0,219,219,0,0,219,219,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,201,205,205,205,205,187,0,0,0,0,0,0,0,0,0,0,201,205,205,205,205,187,0,0,0,0,0,0,35,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,219,219,219,0,0,0,0,186,0,0,0,0,0,0,0,0,0,0,186,0,0,0,0,186,0,0,0,0,0,35,0,0,0,0Ah,0Dh
     DB 0,0,0,219,223,223,219,219,219,0,176,176,0,186,0,0,0,0,0,0,0,0,0,0,186,0,0,234,0,186,0,0,0,0,35,35,0,0,0,0Ah,0Dh
     DB 0,0,201,219,219,219,219,219,219,0,0,0,0,186,0,0,0,0,0,0,0,0,0,0,186,0,234,0,0,219,219,219,0,0,0,35,35,0,0,0Ah,0Dh
     DB 0,0,186,220,220,220,220,220,220,0,176,0,0,186,0,0,220,0,0,0,0,0,0,0,186,0,0,0,0,219,219,219,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,186,0,0,0,0,0,0,0,176,0,0,186,219,219,219,219,205,205,187,0,0,0,186,0,0,0,0,219,219,219,220,220,219,0,0,0,0,0Ah,0Dh
     DB 0,0,186,0,176,0,0,176,0,176,0,0,0,186,219,219,219,219,0,0,186,25,15,25,186,0,0,0,234,219,219,219,219,219,219,0,0,0,0,0Ah,0Dh
     DB 0,0,186,0,0,0,176,0,0,0,0,0,176,186,219,219,219,219,205,205,188,0,0,0,186,0,234,0,0,219,219,219,219,219,219,0,0,0,0,0Ah,0Dh
     DB 0,0,200,205,205,205,205,205,205,205,205,205,205,188,0,0,0,0,0,0,0,0,0,0,186,0,0,0,0,186,0,0,0,0,0,0,0,0,0 ;Island Dungeon Exterior
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,219,219,219,219,219,0,0,0,0,0,219,219,219,219,219,219,0,0,0,0,219,15,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,219,15,219,15,219,0,0,0,0,0,219,15,0,0,15,219,0,0,0,0,219,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,219,0,0,0,219,0,0,0,0,0,219,219,219,219,219,219,0,0,0,0,219,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,219,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,15,219,0,0,0,0,0,219,219,219,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,219,219,15,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,0,0,219,219,219,219,15,219,219,219,219,0,0Ah,0Dh
     DB 0,0,0,0,0,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,219,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,254,0,0,0,254,0,219,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,219,0,0,15,219,0,0,0,0,219,219,219,0,0,0,0,0,0,219,0,0,0,0,0,0,0,219,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,219,219,0,0,219,219,0,0,0,219,219,15,219,219,0,0,0,0,0,219,0,254,0,0,0,254,0,219,0,0Ah,0Dh
     DB 0,219,219,219,219,219,219,219,0,0,219,15,0,0,15,219,0,0,0,219,0,0,0,219,0,0,0,0,0,219,0,0,0,0,0,0,0,219,0,0Ah,0Dh
     DB 0,219,15,219,15,219,15,219,0,0,219,219,0,0,219,219,0,0,0,219,0,0,0,219,0,0,0,0,0,219,220,220,0,0,0,220,220,219,0,0Ah,0Dh
     DB 0,219,0,0,0,0,0,219,0,0,0,219,0,0,15,219,0,0,0,219,15,219,15,219,0,0,0,0,0,219,219,219,219,15,219,219,219,219,0,0Ah,0Dh
     DB 0,219,0,0,0,0,0,219,0,0,0,219,219,219,219,219,0,0,0,219,219,219,219,219,0,0,0,0,0,0,0,0,219,219,219,0,0,0,0,0Ah,0Dh
     DB 0,219,219,219,15,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;Island Dungeon Interior
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,223,0,0,0,0,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,223,0,0,219,219,219,0,0,0,0,0,0,0,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,219,219,219,219,15,219,0,0,219,219,219,219,219,0,220,0,220,0,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,223,0,0,219,219,223,0,0,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,0,0,219,219,219,219,223,0,219,219,219,0,0,0,0,219,0,0,0,0,0,0,219,219,219,219,219,0,223,0,223,0,219,219,219,219,0Ah,0Dh
     DB 219,219,219,0,0,0,223,219,0,0,0,223,219,0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,0,0,0,0,0,234,0,219,219,219,0Ah,0Dh
     DB 223,219,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,234,0,0,0,234,0,219,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,27,0,0,0,0,0,0,0,0,0,0,0,0,0,0,186,0,0,0,0,0,0,0,0,0,219,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,186,0,0,0,0,234,0,0,0,0,219,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,27,0,0,0,0,0,0,0,0,0,0,0,0,0,0,186,0,0,0,0,0,0,234,0,0,219,0,0Ah,0Dh
     DB 219,219,0,0,0,0,0,0,219,219,0,0,219,220,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,234,0,0,0,0,0,0,219,0,0Ah,0Dh
     DB 219,219,219,0,219,219,0,0,219,219,220,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,219,219,219,0,0,0,0,0,0,0,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,0,219,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,0,220,0,220,0,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,220,0,0,0,0,0,0,219,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,220,15,219,219,219,220,0,219,219,219,219,219,0,223,0,223,0,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,220,219,219,219,219,219,219,219,219,0,219,219,219,0,0,0,0,0,0,0,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,219,219,219,219,219,219,220,0,0,0,0,0 ;Caves Exterior
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,220,219,219,219,219,219,219,219,220,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,0,0,40,0,41,0,0,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,0,0,0,0,0,0,0,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,0,0,0,0,0,0,0,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,223,219,219,220,0,220,219,219,223,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,223,219,0,219,223,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,219,0,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,219,15,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;Cave Up Dungeon
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,220,219,219,15,219,219,220,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,0,0,0,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,0,0,0,219,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,223,219,219,0,219,219,223,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,35,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,219,0,0,0,0,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,35,219,0,0,0,0,219,223,223,223,223,223,219,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,219,219,219,219,219,219,0,0,0,0,0,219,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,35,0,35,0,35,0,0,0,0,0,219,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,219,219,0,0,0,0,0,219,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,220,0,0,0,220,219,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,219,219,219,219,219,219,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;Cave Down Dungeon
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,220,0,220,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,220,219,15,219,220,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,220,219,223,0,223,219,220,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,220,219,219,219,219,219,219,219,223,0,0,0,223,219,219,219,219,219,219,219,220,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,220,219,223,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,223,219,220,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,220,219,223,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,223,219,220,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,219,223,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,223,219,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,219,254,0,0,0,254,0,0,0,254,0,0,220,0,0,254,0,0,0,254,0,0,0,254,219,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,220,219,219,219,220,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0,0,223,219,219,219,223,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,219,254,0,0,0,254,0,0,0,254,0,219,219,219,0,254,0,0,0,254,0,0,0,254,219,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,219,220,0,186,0,0,0,186,0,0,220,219,219,219,220,0,0,186,0,0,0,186,0,220,219,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,223,219,220,200,187,0,0,186,0,0,223,219,219,219,223,0,0,186,0,0,201,188,220,219,223,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,223,219,220,200,205,205,202,205,205,205,188,223,200,205,205,205,202,205,205,188,220,219,223,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,223,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,223,0,0,0,0,0,0,0,0,0 ;City Catacombs Key Room
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,223,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,240,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,15,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,254,0,254,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,254,0,254,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0,0,0,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,254,0,254,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219 ;Golden Pi Room
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,0Ah,0Dh
     DB 219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,220,219,219,220,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,219,0,0,219,0,220,0,220,0,0,219,0,0,219,219,0,0,220,219,220,0,219,0,0,0,219,0,220,219,219,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,219,0,0,0,0,219,0,219,0,219,0,219,0,219,0,219,0,219,0,219,0,219,0,219,0,219,0,219,0,0,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,223,219,219,220,0,219,220,219,0,219,220,219,0,219,0,219,0,219,0,219,0,219,0,219,0,219,0,223,219,220,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,0,0,0,219,0,219,0,219,0,219,0,219,0,219,0,219,0,219,0,219,0,219,0,219,0,219,0,0,0,219,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,219,0,0,219,0,219,0,219,0,219,0,219,0,219,219,0,0,223,219,223,0,0,219,0,219,0,0,219,219,223,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,223,219,219,223,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,220,219,219,220,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0,0,0,0,0,0,0,0,223,0,0,0,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,219,0,0,219,0,219,0,219,0,219,223,0,219,219,0,0,0,219,0,219,0,219,0,0,219,0,0,220,0,0,219,0,0,0,0,219,0Ah,0Dh
     DB 219,0,0,219,0,0,219,0,219,0,219,0,219,220,0,219,220,219,0,0,219,220,219,0,219,0,223,219,223,0,219,0,219,0,219,0,0,0,219,0Ah,0Dh
     DB 219,0,0,219,0,0,219,0,219,0,219,0,219,0,0,219,220,0,0,0,219,0,219,0,219,0,0,219,0,0,219,0,219,220,219,0,0,0,219,0Ah,0Dh
     DB 219,0,0,223,219,219,223,0,0,219,0,0,219,219,0,219,0,219,0,0,219,0,219,0,219,219,0,219,0,0,219,0,219,0,219,0,0,0,219,0Ah,0Dh
     DB 219,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,219,0Ah,0Dh
     DB 219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219,219 ;Ending Screen
     DB "===King================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  Young Adventure,                   |",0Ah,0Dh
     DB "|    I have asked for your help       |",0Ah,0Dh
     DB "|    in recovering a lost artifact    |",0Ah,0Dh
     DB "|    hidden somewhere in these        |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;King Intro Speech P1
     DB "===King================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    lands. This artifact is the      |",0Ah,0Dh
     DB "|    great Golden Pi of legend used   |",0Ah,0Dh
     DB "|    by the great sorcerer Adal       |",0Ah,0Dh
     DB "|    in the war of the fallen gods.   |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;King Intro Speech P2
     DB "===King================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    As a reward for finding this     |",0Ah,0Dh
     DB "|    I will give you the hand of my   |",0Ah,0Dh
     DB "|    daughter, Princess Clare.        |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;King Intro Speech P3
     DB "===King================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  Now go young adventurer and best   |",0Ah,0Dh
     DB "|    of luck in your quest.           |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|     *Gestures for you to leave*     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;King Intro Speech P4
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|              Crossroads             |",0Ah,0Dh
     DB "|                  ",179,"                  |",0Ah,0Dh
     DB "|                  ",179,"                  |",0Ah,0Dh
     DB "|                  ",31,"                  |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Map Direction 1
     DB "===Mutip===============================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  Hey Adventurer,                    |",0Ah,0Dh
     DB "|    I heard you are looking for the  |",0Ah,0Dh
     DB "|    lost Golden Pi, well I have a    |",0Ah,0Dh
     DB "|    hint for you. Head WEST to the   |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cultist Hint 1 P1
     DB "===Mutip===============================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    City and dive into its dungeon.  |",0Ah,0Dh
     DB "|    There you will find a key to     |",0Ah,0Dh
     DB "|    something greater than you or    |",0Ah,0Dh
     DB "|    me.                              |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cultist Hint 1 P2
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|               ",17,196,196,196,196,196,16,"               |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|           City       Caves          |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Map Direction 2
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  You enter the city's center and    |",0Ah,0Dh
     DB "|    around you are buildings made of |",0Ah,0Dh
     DB "|    stone and wood. The scent of the |",0Ah,0Dh
     DB "|    sea can be smelled in the air.   |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;City Discription
     DB "=======================================",0Ah,0Dh
     DB "|                Docks                |",0Ah,0Dh
     DB "|                  ",30,"                  |",0Ah,0Dh
     DB "|  City Dungeon    ",179,"    Crossroads    |",0Ah,0Dh
     DB "|                ",17,196,197,196,16,"                |",0Ah,0Dh
     DB "|                  ",31,"                  |",0Ah,0Dh
     DB "|           City Catacombs            |",0Ah,0Dh 
     DB "=======================================" ;Map Direction 3
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|               ",17,196,196,196,196,196,16,"               |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|   City Dungeon       City           |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Map Direction 4
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  You enter the dungeon and around   |",0Ah,0Dh
     DB "|    you is nothing but featureless   |",0Ah,0Dh
     DB "|    stone walls. The faint sound of  |",0Ah,0Dh
     DB "|    grinding stone can be heard      |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Dunegon Discription 1
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    coming from somewhere deeper     |",0Ah,0Dh
     DB "|    in the dungeon.                  |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Dungeon Discription 2
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  As you pickup the key a loud crash |",0Ah,0Dh
     DB "|    can be heard from a nearby wall. |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  *A new passage has been revealed*  |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Dungeon Discription 3
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|       *Dungeon key recovered*       |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "| 'Continue the adventure to discover |",0Ah,0Dh
     DB "|     the remaining dungeon keys'     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Player Hint 1
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  As you arrive at the docks the     |",0Ah,0Dh
     DB "|    smell of the salty sea air hits  |",0Ah,0Dh
     DB "|    you, as you catch yourself you   |",0Ah,0Dh
     DB "|    notice a familiar face.          |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Dock Discription
     DB "===Mutip===============================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  Ah, the Adventurer,                |",0Ah,0Dh
     DB "|    I heard you managed to recover a |",0Ah,0Dh
     DB "|    key from the City's dungeon.     |",0Ah,0Dh
     DB "|    I guess I should tell you then.  |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cultist Hint 2 P1 V1
     DB "===Mutip===============================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    There is a temple on the island  |",0Ah,0Dh
     DB "|    which is rumored to be home to   |",0Ah,0Dh
     DB "|    another dungeon key. Best of     |",0Ah,0Dh
     DB "|    luck recovering it.              |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cultist Hint 2 P2 V1
     DB "=======================================",0Ah,0Dh
     DB "|               Island                |",0Ah,0Dh
     DB "|                  ",30,"                  |",0Ah,0Dh
     DB "|                  ",179,"                  |",0Ah,0Dh
     DB "|                  ",179,"                  |",0Ah,0Dh
     DB "|                  ",31,"                  |",0Ah,0Dh
     DB "|                City                 |",0Ah,0Dh 
     DB "=======================================" ;Map Direction 5
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  You step off the boat and you see  |",0Ah,0Dh
     DB "|    that the Island is covered by a  |",0Ah,0Dh
     DB "|    lush forest of jungle trees and  |",0Ah,0Dh
     DB "|    deep in the middle of the forest |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Island Discription 1
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    you see the top of what looks    |",0Ah,0Dh
     DB "|    like a grand stone temple.       |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Island Discription 2
     DB "=======================================",0Ah,0Dh
     DB "|            Island Temple            |",0Ah,0Dh
     DB "|                  ",30,"                  |",0Ah,0Dh
     DB "|                  ",179,"                  |",0Ah,0Dh
     DB "|                  ",179,"                  |",0Ah,0Dh
     DB "|                  ",31,"                  |",0Ah,0Dh
     DB "|                Docks                |",0Ah,0Dh 
     DB "=======================================" ;Map Direction 6
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  Pushing through the thick brush    |",0Ah,0Dh
     DB "|    you lay your eyes on your        |",0Ah,0Dh
     DB "|    destination, the grand stone     |",0Ah,0Dh
     DB "|    temple in the rumor you heard.   |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Island Temple Exterior Discription
     DB "=======================================",0Ah,0Dh
     DB "|                Temple               |",0Ah,0Dh
     DB "|                  ",30,"                  |",0Ah,0Dh
     DB "|                  ",179,"                  |",0Ah,0Dh
     DB "|                  ",179,"                  |",0Ah,0Dh
     DB "|                  ",31,"                  |",0Ah,0Dh
     DB "|             Island Docks            |",0Ah,0Dh 
     DB "=======================================" ;Map Direction 7
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  You enter the temple and see 3     |",0Ah,0Dh
     DB "|    shimmering doorways and on the   |",0Ah,0Dh
     DB "|    floor you see a piece of paper   |",0Ah,0Dh
     DB "|    that reads:                      |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Island Temple Interior Discription 1
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    'He who stays on the right path  |",0Ah,0Dh
     DB "|    will find the dungeon's key and  |",0Ah,0Dh
     DB "|    be able to escape with it.'      |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Island Temple Interior Discription 2
     DB "===Mutip===============================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  Hello Adventurer,                  |",0Ah,0Dh
     DB "|    I was right sending you here,    |",0Ah,0Dh
     DB "|    not only did you solve the       |",0Ah,0Dh
     DB "|    dungeon's puzzle but you also    |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cultist Hint 3 P1
     DB "===Mutip===============================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    recovered the dungeon key.       |",0Ah,0Dh
     DB "|    This means you are ready for     |",0Ah,0Dh
     DB "|    the next rumored location of 2   |",0Ah,0Dh
     DB "|    dungeon keys. Return to where we |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cultist Hint 3 P2
     DB "===Mutip===============================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    first met and head EAST, there   |",0Ah,0Dh
     DB "|    you will find 2 caves. One is    |",0Ah,0Dh
     DB "|    abandoned alone and the other in |",0Ah,0Dh
     DB "|    constant lockdown. Now go.       |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cultist Hint 3 P3
     DB "=======================================",0Ah,0Dh
     DB "|                Cave 1               |",0Ah,0Dh
     DB "|                  ",30,"                  |",0Ah,0Dh
     DB "|     Crossroads   ",179,"                  |",0Ah,0Dh
     DB "|                ",17,196,197,"                  |",0Ah,0Dh
     DB "|                  ",31,"                  |",0Ah,0Dh
     DB "|                Cave 2               |",0Ah,0Dh 
     DB "=======================================" ;Map Direction 8
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  After walking for what seemed like |",0Ah,0Dh
     DB "|    days you finally enter an        |",0Ah,0Dh
     DB "|    opening. To your north and south |",0Ah,0Dh
     DB "|    are 2 cave enterences.           |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Caves Exterior Discription
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  You enter the cave and see an      |",0Ah,0Dh
     DB "|    empty room with the key sitting  |",0Ah,0Dh
     DB "|    on a pedastole with a torn note  |",0Ah,0Dh
     DB "|    on it, the note reads:           |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cave 1 Discription 1
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    'To who reads this leave now     |",0Ah,0Dh
     DB "|    trust not the man you see for    |",0Ah,0Dh
     DB "|    he is a Fallen who wis...'       |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cave 1 Discription 2
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  You enter the cave and see an iron |",0Ah,0Dh
     DB "|    gate across the room from you    |",0Ah,0Dh
     DB "|    along with with 6 buttons placed |",0Ah,0Dh
     DB "|    along the walls.                 |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cave 2 Discription
     DB "===Mutip===============================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  There you are Adventurer,          |",0Ah,0Dh
     DB "|    I see You have found all the     |",0Ah,0Dh
     DB "|    dungeon keys now it is time to   |",0Ah,0Dh
     DB "|    go and retrieve that which you   |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cultist Hint 4 P1
     DB "===Mutip===============================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    are looking for. The Golden Pi.  |",0Ah,0Dh
     DB "|    Goto the City and enter its      |",0Ah,0Dh
     DB "|    catacombs, there you will find   |",0Ah,0Dh
     DB "|    it.                              |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cultist Hint 4 P2
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  Entering the catacombs you are     |",0Ah,0Dh
     DB "|    greeted by a large room with     |",0Ah,0Dh
     DB "|    some ancient device in its       |",0Ah,0Dh
     DB "|    center. 4 key slots run along    |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;City Catacombs Discription 1
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    its back wall and as you place   |",0Ah,0Dh
     DB "|    the keys tubes which you did not |",0Ah,0Dh
     DB "|    notice before begin to fill with |",0Ah,0Dh
     DB "|    a liquid the color of gold.      |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;City Catacombs Discription 2
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    You watch as the liquid flows    |",0Ah,0Dh
     DB "|    into the ancient device and      |",0Ah,0Dh
     DB "|    after the last key is placed the |",0Ah,0Dh
     DB "|    sound of grinding stone can be   |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;City Catacombs Discription 3
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    heard coming from the front of   |",0Ah,0Dh
     DB "|    the device. Moving around to it  |",0Ah,0Dh
     DB "|    you see a stair case has been    |",0Ah,0Dh
     DB "|    revealed.                        |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;City Catacombs Discription 4
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  You cautiously make your way down  |",0Ah,0Dh
     DB "|    the stair case and at the bottom |",0Ah,0Dh
     DB "|    you are faced with a wooden      |",0Ah,0Dh
     DB "|    platform extending out over what |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 1
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    looks to be a bottomless pit.    |",0Ah,0Dh
     DB "|    As you look over the plateform   |",0Ah,0Dh
     DB "|    you notice something glimmering  |",0Ah,0Dh
     DB "|    from its other end. Focusing     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 2
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    your eyes you see it, the Golden |",0Ah,0Dh
     DB "|    Pi. Seeing your goal ahead of    |",0Ah,0Dh
     DB "|    you you begin to carfully make   |",0Ah,0Dh
     DB "|    your way out onto the platform.  |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 3
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    You only make it half way across |",0Ah,0Dh
     DB "|    the platform when you hear a     |",0Ah,0Dh
     DB "|    familiar voice call out from     |",0Ah,0Dh
     DB "|    behind you. Turning to see who   |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 4
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    it is you are struck by a sword, |",0Ah,0Dh
     DB "|    the pain suddenly rushes over    |",0Ah,0Dh
     DB "|    you as you look down and see     |",0Ah,0Dh
     DB "|    your right hand is missing.      |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 5
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    You fall to your knees holding   |",0Ah,0Dh
     DB "|    bloody wrist and look up to see  |",0Ah,0Dh
     DB "|    Mutip holding the bloody sword.  |",0Ah,0Dh
     DB "|    He turns away from you and       |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 6
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    begins to walk towards the       |",0Ah,0Dh
     DB "|    Golden Pi.                       |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 7
     DB "===Mutip===============================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  There it is, the key to all that   |",0Ah,0Dh
     DB "|    I seek. The Golden Pi, the key   |",0Ah,0Dh
     DB "|    to the great gates of the old    |",0Ah,0Dh
     DB "|    world.                           |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cultist P1
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  Mutip reaches the pedestal and     |",0Ah,0Dh
     DB "|    begins to pickup the Golden Pi.  |",0Ah,0Dh
     DB "|    The moment it leaves the         |",0Ah,0Dh
     DB "|    pedestal the entire room begins  |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 8
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    to shake. A stone then falls     |",0Ah,0Dh
     DB "|    from the roof and lands only     |",0Ah,0Dh
     DB "|    feet from you breaking the       |",0Ah,0Dh
     DB "|    platform into splitters. This    |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 9
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    causes Mutip to begins to run    |",0Ah,0Dh
     DB "|    back to the stairs. Seeing that  |",0Ah,0Dh
     DB "|    he must run past you to reach    |",0Ah,0Dh
     DB "|    safty you take this chance to    |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 10
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    get him back for taking your     |",0Ah,0Dh
     DB "|    hand. So just as he passes you   |",0Ah,0Dh
     DB "|    you stick out your leg and cause |",0Ah,0Dh
     DB "|    him to trip. Mutip not noticing  |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 11
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    your leg, trips and sends the    |",0Ah,0Dh
     DB "|    Golden Pi flying towards the     |",0Ah,0Dh
     DB "|    stairs. As he hits the platform  |",0Ah,0Dh
     DB "|    the Golden Pi lands on the       |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 12
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    steps. But unlike the Golden Pi  |",0Ah,0Dh
     DB "|    Mutip did not land safely,       |",0Ah,0Dh
     DB "|    hitting the platform next to the |",0Ah,0Dh
     DB "|    splittered hole. Without         |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 13
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    thinking he attempts to stand    |",0Ah,0Dh
     DB "|    causing the platform beneath him |",0Ah,0Dh
     DB "|    to break and send him falling    |",0Ah,0Dh
     DB "|    into the endless void below.     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 14
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    Noticing that you are still in   |",0Ah,0Dh
     DB "|    danger as the room collapeses    |",0Ah,0Dh
     DB "|    you spring to your feet and      |",0Ah,0Dh
     DB "|    begin to run towards the stairs. |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 15
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    As you run the platform behind   |",0Ah,0Dh
     DB "|    you begins to collapes into the  |",0Ah,0Dh
     DB "|    void below but you manage to     |",0Ah,0Dh
     DB "|    keep ahead of it and reach the   |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 16
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    stairs just as the rest of the   |",0Ah,0Dh
     DB "|    platform falls into the void.    |",0Ah,0Dh
     DB "|    Catching your breath you grab    |",0Ah,0Dh
     DB "|    the Golden Pi and begin to make  |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 17
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    your way back to the castle. On  |",0Ah,0Dh
     DB "|    your journey back you meet with  |",0Ah,0Dh
     DB "|    a traveling doctor and he treats |",0Ah,0Dh
     DB "|    your wound.                      |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Golden Pi Room Discription 18
     DB "===King================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  Young Adventure,                   |",0Ah,0Dh
     DB "|    so you have returned and with    |",0Ah,0Dh
     DB "|    what seems like one less hand.   |",0Ah,0Dh
     DB "|    I hate to ask but what did you   |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;King Ending Speech P1
     DB "===King================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    lose it to? ... *Silence*        |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    No response? Well, I will not    |",0Ah,0Dh
     DB "|    inquire further then. Now did    |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;King Ending Speech P2
     DB "===King================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    you manage to find the artifact? |",0Ah,0Dh
     DB "|    You did?! Great! Then hand it to |",0Ah,0Dh
     DB "|    me.                              |",0Ah,0Dh
     DB "|       *The King approaches you*     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;King Ending Speech P3
     DB "===King================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  Truely you have brought the real   |",0Ah,0Dh
     DB "|    thing. Now for your reward.      |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    *The King turns away from you*   |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;King Ending Speech P4
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  Suddenly the king turns back       |",0Ah,0Dh
     DB "|    around and stabs a sword into    |",0Ah,0Dh
     DB "|    your chest. As he removes the    |",0Ah,0Dh
     DB "|    sword you fall to your knees.    |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Ending Discription 1
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    Looking up you see the man       |",0Ah,0Dh
     DB "|    who stabbed you was not the King |",0Ah,0Dh
     DB "|    but Mutip.                       |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Ending Discription 2
     DB "===Mutip===============================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|  You are too trusting, to think all |",0Ah,0Dh
     DB "|    I needed to do to get past the   |",0Ah,0Dh
     DB "|    anti-magic barrier protecting    |",0Ah,0Dh
     DB "|    the Golden Pi was some stupid    |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cultist Ending P1
     DB "===Mutip===============================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    Kid with a want for adventure.   |",0Ah,0Dh
     DB "|    But I have to thank you for all  |",0Ah,0Dh
     DB "|    your work, as I would have never |",0Ah,0Dh
     DB "|    been able to get the key to      |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cultist Ending P2
     DB "===Mutip===============================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    controlling reality without you. |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "| *Mutip looks down at the Golden Pi* |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Cultist Ending P3
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|    As the Golden Pi begins to glow, |",0Ah,0Dh
     DB "|    its brightness ever more intense |",0Ah,0Dh
     DB "|    your world begins to go dark and |",0Ah,0Dh
     DB "|    distant. Then you feel nothing.  |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Ending Discription 3
     DB "=======================================",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|           *You have died*           |",0Ah,0Dh
     DB "|             *GAME OVER*             |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Ending Message
     DB "===Hit 'i' to bring up the Help menu===",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh
     DB "|     - Door (Locked)                 |",0Ah,0Dh
     DB "|     - Door (Unlocked)               |",0Ah,0Dh
     DB "|     - Button                        |",0Ah,0Dh
     DB "|     - Dungeon Key                   |",0Ah,0Dh
     DB "|                                     |",0Ah,0Dh 
     DB "=======================================" ;Help Message
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0Ah,0Dh
     DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;Screen Wipe    
     
propY       DB 004h,004h,004h,004h,005h,005h,005h,00Bh,00Bh,00Ch,00Ch,00Dh,00Dh,00Dh,007h                                                                                                                                                                                                       ;Castle Interior (15)
            DB 006h,006h,007h,007h,010h,008h                                                                                                                                                                                                                                                    ;Castle Exterior (6)
            DB 006h,003h,005h,006h,006h,006h                                                                                                                                                                                                                                                    ;Crossroads (6)               
            DB 008h,008h,002h,00Ch,008h,008h,003h                                                                                                                                                                                                                                               ;City Center (7)
            DB 008h,008h,00Bh,00Ch,00Dh,00Eh,00Fh,008h,008h                                                                                                                                                                                                                                     ;City Dungeon Ex (9)
            DB 00Eh,00Eh,00Eh,00Ch,00Ch,00Ch,00Ch,00Bh                                                                                                                                                                                                                                          ;City Dungeon In (8)
            DB 004h,00Eh,009h,00Dh,005h                                                                                                                                                                                                                                                         ;City Docks (5)
            DB 003h,004h,004h,004h,00Bh,00Ah,004h                                                                                                                                                                                                                                               ;Island Docks (7)
            DB 004h,00Eh,008h,00Dh,005h                                                                                                                                                                                                                                                         ;Temple Exterior (5)
            DB 002h,003h,003h,003h,003h,005h,006h,006h,009h,00Ah,00Bh,00Bh,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Dh,00Dh,00Dh,00Dh,00Eh,00Fh                                                                                                                                                          ;Temple Interior (24)
            DB 002h,008h,00Eh,008h,003h,00Dh,006h                                                                                                                                                                                                                                               ;Caves Exterior (7)
            DB 008h,008h,008h,013h,014h,015h,016h,00Eh,00Dh                                                                                                                                                                                                                                     ;Caves Up (9)
            DB 001h,002h,002h,004h,004h,006h,006h,008h,00Ah,00Ch,00Ch,00Ch,00Eh,00Eh,00Eh,002h,008h,00Ah,00Ch,00Ch,00Ch                                                                                                                                                                         ;Cave Down (21)
            DB 004h,004h,00Bh,00Ch,00Dh,00Eh,00Eh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Bh,00Bh,00Ch,00Dh,00Eh,00Bh,00Bh,00Ch,00Dh,00Eh,00Eh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Bh,00Bh,00Ch,00Dh,00Eh,009h,009h,00Ah,00Bh,00Bh,009h                                                 ;Key Room (45)
            DB 009h,00Ah,00Ah,00Ah,00Bh,004h,004h,005h,005h,006h,006h,007h,007h,007h,007h,008h,008h,009h,00Ah,006h,009h,008h,008h,007h,007h,006h,006h,00Bh,00Bh,00Bh,00Ah,00Ah,00Ah,007h,006h,009h,009h,009h,008h,008h,008h,006h,005h,007h,007h,007h,005h,004h,006h,006h,006h,005h,005h,005h    ;Golden Pi (54)
            DB 00Dh,005h,00Dh,003h,00Dh,00Bh,004h,00Eh,004h,003h,003h,00Eh,009h,003h,00Bh,003h,00Dh,00Bh,00Ch,007h,00Ch,00Eh,004h,00Eh,00Ch,00Eh                                                                                                                                                ;DoorData (26)
              ;  0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33   34   35   36   37   38   39   40   41   42   43   44   45   46   47   48   49   50   51   52   53
                                                                                                                                                          
propX       DB 012h,013h,014h,017h,012h,013h,014h,010h,016h,011h,015h,012h,013h,014h,013h
            DB 011h,015h,012h,014h,013h,013h                               
            DB 00Dh,013h,00Eh,019h,00Eh,018h                                                             
            DB 00Bh,01Bh,013h,013h,01Ah,00Ch,013h
            DB 00Dh,01Ah,01Eh,01Ch,01Eh,01Dh,01Eh,019h,00Eh 
            DB 003h,004h,005h,024h,025h,006h,007h,015h
            DB 011h,013h,011h,013h,011h 
            DB 016h,00Ah,01Eh,01Fh,014h,014h,016h 
            DB 013h,016h,016h,016h,013h  
            DB 019h,005h,007h,00Fh,012h,019h,006h,021h,00Eh,015h,00Bh,00Eh,002h,004h,006h,020h,021h,022h,00Eh,014h,016h,021h,004h,004h
            DB 015h,00Ch,013h,00Dh,015h,013h,00Dh                                                  
            DB 012h,013h,014h,005h,005h,005h,005h,013h,013h
            DB 013h,011h,015h,011h,015h,011h,015h,013h,013h,015h,017h,019h,01Bh,01Ch,01Dh,013h,013h,013h,015h,017h,019h 
            DB 013h,013h,00Ah,00Ah,00Ah,00Ah,00Bh,00Bh,00Ch,00Dh,00Eh,00Fh,010h,011h,012h,00Ah,00Eh,00Eh,00Eh,00Eh,00Eh,01Ch,01Ch,01Ch,01Ch,01Bh,01Bh,01Ah,019h,018h,017h,016h,015h,014h,01Ch,018h,018h,018h,018h,012h,013h,013h,013h,018h,013h
            DB 013h,012h,013h,014h,013h,013h,013h,013h,013h,013h,013h,013h,013h,014h,013h,013h,013h,013h,013h,012h,013h,013h,013h,013h,013h,013h,013h,012h,013h,014h,012h,013h,014h,014h,014h,012h,013h,014h,012h,013h,014h,014h,013h,012h,013h,014h,013h,013h,012h,013h,014h,012h,013h,014h
            DB 002h,006h,004h,011h,006h,00Ch,005h,004h,007h,019h,010h,004h,00Dh,011h,00Dh,011h,00Dh,015h,014h,021h,016h,004h,019h,004h,021h,004h
              ;  0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33   34   35   36   37   38   39   40   41   42   43   44   45   46   47   48   49   50   51   52   53

propChar    DB 0C9h,0CDh,0BBh,0DBh,0BAh,002h,0BAh,0DBh,0DBh,0DBh,0DBh,0DBh,00Fh,0DBh,001h
            DB 0DBh,0DBh,0DBh,0DBh,00Fh,001h                             
            DB 00Fh,001h,002h,00Fh,001h,001h                                                                  
            DB 00Fh,00Fh,00Fh,00Fh,001h,001h,001h
            DB 00Fh,00Fh,0B0h,0B0h,0B0h,0B0h,0B0h,001h,001h
            DB 028h,00Eh,029h,001h,00Fh,000h,000h,000h
            DB 00Fh,00Fh,002h,001h,001h
            DB 00Fh,0DBh,0DBh,0DBh,00Fh,001h,001h
            DB 00Fh,00Fh,002h,001h,001h   
            DB 00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,028h,00Eh,029h,00Fh,00Fh,00Fh,00Fh,001h,00Fh
            DB 00Fh,00Fh,00Fh,001h,001h,001h,002h                                                
            DB 028h,00Eh,029h,00Fh,00Fh,004h,00Eh,00Fh,001h  
            DB 00Fh,004h,004h,004h,004h,004h,004h,023h,023h,023h,023h,023h,028h,00Eh,029h,001h,000h,000h,000h,000h,000h
            DB 001h,000h,001h,00Eh,0BAh,0C8h,0BBh,0C8h,0CDh,0CDh,0CAh,0CDh,0CDh,0CDh,0BCh,000h,001h,00Eh,0BAh,0BAh,000h,001h,00Eh,0BAh,0BCh,0C9h,0BCh,0CDh,0CDh,0CAh,0CDh,0CDh,0CDh,0C8h,000h,001h,00Eh,0BAh,0BAh,0DCh,000h,000h,00Fh,000h,001h
            DB 05Fh,028h,0BAh,029h,01Fh,001h,000h,001h,000h,001h,000h,001h,002h,001h,000h,002h,000h,002h,000h,000h,000h,002h,000h,002h,000h,002h,000h,000h,000h,000h,000h,000h,000h,000h,001h,000h,000h,000h,000h,000h,000h,000h,001h,000h,000h,000h,000h,001h,000h,000h,000h,000h,000h,000h
            DB 000h,001h,000h,001h,000h,001h,000h,001h,000h,001h,000h,001h,000h,001h,000h,001h,000h,001h,000h,001h,000h,001h,000h,001h,000h,001h
              ;  0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33   34   35   36   37   38   39   40   41   42   43   44   45   46   47   48   49   50   51   52   53

propColor   DB 00Eh,00Eh,00Eh,006h,00Eh,003h,00Eh,00Fh,00Fh,00Fh,00Fh,00Fh,004h,00Fh,00Eh
            DB 00Fh,00Fh,00Fh,00Fh,024h,02Eh                        
            DB 024h,02Eh,02Dh,024h,02Eh,02Eh                                                            
            DB 084h,084h,084h,084h,08Eh,08Eh,08Eh
            DB 064h,064h,06Eh,06Eh,06Eh,06Eh,06Eh,06Eh,06Eh
            DB 00Eh,00Eh,00Eh,00Eh,004h,000h,000h,000h
            DB 064h,024h,06Dh,06Eh,06Eh
            DB 024h,001h,001h,001h,064h,06Eh,02Eh
            DB 024h,024h,02Dh,02Eh,02Eh   
            DB 007h,004h,004h,004h,007h,004h,007h,007h,004h,007h,007h,004h,004h,004h,004h,00Eh,00Eh,00Eh,004h,004h,004h,004h,00Eh,004h
            DB 064h,064h,064h,06Eh,06Eh,06Eh,06Dh                                               
            DB 06Eh,06Eh,06Eh,007h,004h,009h,00Eh,064h,06Eh       
            DB 004h,009h,009h,009h,009h,009h,009h,00Fh,00Fh,00Fh,00Fh,00Fh,00Eh,00Eh,00Eh,00Eh,000h,000h,000h,000h,000h
            DB 00Eh,000h,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,000h,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,00Eh,000h,00Eh,00Eh,00Eh,00Eh,000h,007h,000h,004h,000h,00Eh
            DB 06Eh,06Eh,06Eh,06Eh,06Eh,06Eh,060h,06Eh,060h,06Eh,060h,06Eh,06Dh,04Eh,060h,06Dh,060h,06Dh,060h,000h,060h,06Dh,060h,06Dh,060h,00Dh,000h,000h,000h,000h,000h,000h,000h,060h,06Eh,000h,000h,000h,000h,000h,000h,060h,06Eh,000h,000h,000h,060h,06Eh,000h,000h,000h,000h,000h,000h
            DB 000h,00Eh,000h,00Eh,000h,00Eh,000h,00Eh,000h,00Eh,000h,00Eh,000h,00Eh,000h,00Eh,000h,00Eh,000h,00Eh,000h,00Eh,000h,00Eh,000h,00Eh    
              ;  0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33   34   35   36   37   38   39   40   41   42   43   44   45   46   47   48   49   50   51   52   53

npcMovement DB 3,3,3,3,3,0,1,1,1,1,1,3