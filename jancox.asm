.386
.model flat, stdcall
option casemap :none

include combat.inc

.data
    player1 player <MAX_LIFE, 7, <IMG_SIZE, WIN_HT / 2, <0, 0>>>
    player2 player <MAX_LIFE, 3, <WIN_WD - IMG_SIZE, WIN_HT / 2, <0, 0>>>

    isShooting pair <0, 0> ;Menandakan apakah setiap pemain sedang menembak
    canPlyrsMov pair <0, 0> 

    scoreP1 pair <48 + 0, 48 + 0> ;Skor pemain pertama
    scoreP2 pair <48 + 0, 48 + 0> ;Skor pemain kedua

    maxScore pair <48 + 0, 48 + 5> ;Skor maksimum

    hit db FALSE ;Menandakan apakah salah satu pemain mencetak skor

    ;Senarai terkait peluru:
    ;Player1:
    fShot1 dword 0 ;Node pertama
    lShot1 dword 0 ;Node terakhir
    numShots1 byte 0 ;Jumlah node

    ;Player2:
    fShot2 dword 0 ;Node pertama
    lShot2 dword 0 ;Node terakhir
    numShots2 byte 0 ;Jumlah node

    shotsDelays pair <0, 0> ;Delay peluru

    over byte 0 ;Menandakan apakah game sudah selesai

.code 
start:

invoke GetModuleHandle, NULL
mov hInstance, eax

invoke WinMain, hInstance, SW_SHOWDEFAULT
invoke ExitProcess, eax

loadBitmaps proc ;Muat bitmap game:
;Gambar dari pemain pertama:
    invoke LoadBitmap, hInstance, 100
    mov h100, eax

    invoke LoadBitmap, hInstance, 101
    mov h101, eax

    invoke LoadBitmap, hInstance, 102
    mov h102, eax

    invoke LoadBitmap, hInstance, 103
    mov h103, eax

    invoke LoadBitmap, hInstance, 104
    mov h104, eax

    invoke LoadBitmap, hInstance, 105
    mov h105, eax

    invoke LoadBitmap, hInstance, 106
    mov h106, eax

    invoke LoadBitmap, hInstance, 107
    mov h107, eax	

    invoke LoadBitmap, hInstance, 110
    mov h110, eax

    invoke LoadBitmap, hInstance, 111
    mov h111, eax

    invoke LoadBitmap, hInstance, 112
    mov h112, eax

    invoke LoadBitmap, hInstance, 113
    mov h113, eax

    invoke LoadBitmap, hInstance, 114
    mov h114, eax

    invoke LoadBitmap, hInstance, 115
    mov h115, eax

    invoke LoadBitmap, hInstance, 116
    mov h116, eax

    invoke LoadBitmap, hInstance, 117
    mov h117, eax	

    ret
loadBitmaps endp

WinMain proc hInst:HINSTANCE, CmdShow:dword
    local clientRect:RECT
    local wc:WNDCLASSEX                                            
    local msg:MSG 

    mov wc.cbSize, SIZEOF WNDCLASSEX  
    mov wc.style, CS_BYTEALIGNWINDOW or CS_BYTEALIGNCLIENT
    mov wc.lpfnWndProc, OFFSET WndProc 
    mov wc.cbClsExtra, NULL 
    mov wc.cbWndExtra, NULL 

    push hInstance 
    pop wc.hInstance 

    mov wc.hbrBackground, COLOR_WINDOW + 1 
    mov wc.lpszMenuName, NULL 
    mov wc.lpszClassName, OFFSET ClassName 

    invoke LoadIcon, hInstance, 500 
    mov wc.hIcon, eax 
    mov wc.hIconSm, eax

    invoke LoadCursor, NULL, IDC_ARROW 
    mov wc.hCursor, eax 

    invoke RegisterClassEx, addr wc

    mov clientRect.left, 0
    mov clientRect.top, 0
    mov clientRect.right, WIN_WD
    mov clientRect.bottom, WIN_HT

    invoke AdjustWindowRect, addr clientRect, WS_CAPTION, FALSE

    mov eax, clientRect.right
    sub eax, clientRect.left
    mov ebx, clientRect.bottom
    sub ebx, clientRect.top

    invoke CreateWindowEx, NULL, addr ClassName, addr AppName,\ 
        WS_OVERLAPPED or WS_SYSMENU or WS_MINIMIZEBOX,\ 
        CW_USEDEFAULT, CW_USEDEFAULT,\
        eax, ebx, NULL, NULL, hInst, NULL 

    mov hWnd, eax 
    invoke ShowWindow, hWnd, CmdShow ;tampilkan jendela
    invoke UpdateWindow, hWnd 

  
    .while TRUE  
        invoke GetMessage, addr msg, NULL, 0, 0 
        .break .if (!eax)       

        invoke TranslateMessage, addr msg 
        invoke DispatchMessage, addr msg
    .endw 

    mov eax, msg.wParam

    ret 
WinMain endp

WndProc proc _hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    .if uMsg == WM_CREATE 
;________________________________________________________________________________

        invoke loadBitmaps

        mov eax, offset gameHandler 
        invoke CreateThread, NULL, NULL, eax, 0, 0, addr threadID 

        invoke CloseHandle, eax 
;________________________________________________________________________________

    .elseif uMsg == WM_DESTROY 
        invoke PostQuitMessage, NULL 
    .elseif uMsg == WM_CHAR
;________________________________________________________________________________

            ;Tombol gerakan player1:
    .if (wParam == 77h || wParam == 57h) ;w
        mov player1.playerObj.speed.y, -SPEED 
    .elseif (wParam == 61h || wParam == 41h) ;a
        mov player1.playerObj.speed.x, -SPEED
    .elseif (wParam == 73h || wParam == 53h) ;s
        mov player1.playerObj.speed.y, SPEED
    .elseif (wParam == 64h || wParam == 44h) ;d
        mov player1.playerObj.speed.x, SPEED

;________________________________________________________________________________

            .elseif (wParam == 79h || wParam == 59h) ;y - Tembakan player1:
        mov isShooting.x, TRUE
    .elseif (wParam == 75h || wParam == 55h) ;u - Khusus player1:

;________________________________________________________________________________

           .elseif (wParam == 32h) ;2 - Tembakan player2:
        mov isShooting.y, TRUE      
    .elseif (wParam == 33h) ;3 - Khusus player2:
    .elseif (wParam == 72h) ;r - Mulai ulang game
        .if over
            mov over, FALSE 

            ;Set skor ke nol:
			mov scoreP1.x, 48 + 0
            mov scoreP1.y, 48 + 0

            mov scoreP2.x, 48 + 0
            mov scoreP2.y, 48 + 0

            mov eax, offset gameHandler 
            invoke CreateThread, NULL, NULL, eax, 0, 0, addr threadID 

            invoke CloseHandle, eax
        .endif
    .endif

;________________________________________________________________________________
        
    .elseif uMsg == WM_KEYDOWN ;Tekan tombol non-printable:-----------------------

;________________________________________________________________________________

          ;Tombol gerakan player2:
    .if (wParam == VK_UP) ;panah atas
        mov player2.playerObj.speed.y, -SPEED
    .elseif (wParam == VK_DOWN) ;panah bawah
        mov player2.playerObj.speed.y, SPEED
    .elseif (wParam == VK_LEFT) ;panah kiri
        mov player2.playerObj.speed.x, -SPEED
    .elseif (wParam == VK_RIGHT) ;panah kanan
        mov player2.playerObj.speed.x, SPEED
    .endif

;________________________________________________________________________________

    .elseif uMsg == WM_KEYUP ;Tekan tombol:---------------------------------------

;________________________________________________________________________________

                ;;Tombol gerakan player1:
        .if (wParam == 77h || wParam == 57h) ;w
        .if (player1.playerObj.speed.y > 7fh) ;Jika bernilai negatif:
        mov player1.playerObj.speed.y, 0
        .endif
        .elseif (wParam == 61h || wParam == 41h) ;a
        .if (player1.playerObj.speed.x > 7fh) ;Jika bernilai negatif:
        mov player1.playerObj.speed.x, 0
        .endif
        .elseif (wParam == 73h || wParam == 53h) ;s
        .if (player1.playerObj.speed.y < 80h) ;Jika bernilai positif:
        mov player1.playerObj.speed.y, 0
        .endif
        .elseif (wParam == 64h || wParam == 44h) ;d
        .if (player1.playerObj.speed.x < 80h) ;Jika bernilai positif:
        mov player1.playerObj.speed.x, 0
        .endif
;________________________________________________________________________________

            .elseif (wParam == 59h) ;y - Tembakan player1:
        mov isShooting.x, FALSE
        mov shotsDelays.x, 0
    .elseif (wParam == 55h) ;u - Khusus player1:

;________________________________________________________________________________

            .elseif (wParam == 62h) ;2 - Tembakan player2:
        mov isShooting.y, FALSE
        mov shotsDelays.y, 0
            .elseif (wParam == 63h) ;3 - Khusus player2:

;________________________________________________________________________________
            
            ;Tombol gerakan player2:
        .elseif (wParam == VK_UP) ;panah atas
            .if (player2.playerObj.speed.y > 7fh) ;Jika bernilai negatif:
                mov player2.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == VK_DOWN) ;panah bawah
            .if (player2.playerObj.speed.y < 80h) ;Jika bernilai positif:
                mov player2.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == VK_LEFT) ;panah kiri
            .if (player2.playerObj.speed.x > 7fh) ;Jika bernilai negatif:
                mov player2.playerObj.speed.x, 0 
            .endif
        .elseif (wParam == VK_RIGHT) ;panah kanan
            .if (player2.playerObj.speed.x < 80h) ;Jika bernilai positif:
                mov player2.playerObj.speed.x, 0 
            .endif
        .endif

;________________________________________________________________________________

    .elseif uMsg == WM_PAINT
        invoke updateScreen
    .else ;Default:
        invoke DefWindowProc, _hWnd, uMsg, wParam, lParam 
        ret 
    .endif 

    xor eax, eax 

    ret 
WndProc endp

mult proc uses ebx edx n1:word, n2:word 
    xor eax, eax 
    xor edx, edx

    mov ax, n1
    mov bx, n2

    imul bx

    shl edx, 16

    add eax, edx

    ret
mult endp

movObj proc uses eax addrObj:dword 
    assume ecx:ptr gameObj
    mov ecx, addrObj
;________________________________________________________________________________

    mov ax, [ecx].x
    movzx bx, [ecx].speed.x

    .if bx > 7fh
        or bx, 65280
    .endif

    add ax, bx
    mov [ecx].x, ax


;________________________________________________________________________________

    mov ax, [ecx].y
    movzx bx, [ecx].speed.y

    .if bx > 7fh:
        or bx, 65280
    .endif

    add ax, bx
    mov [ecx].y, ax
;________________________________________________________________________________
    
    assume ecx:nothing

    ret
movObj endp

movShots proc uses eax
    assume eax:ptr node

    mov eax, fShot1

    xor dl, dl
    mov dh, numShots1 
    .while dl < dh
        mov ecx, eax
        add ecx, 4
        invoke movObj, ecx

        mov eax, [eax].next

        inc dl
    .endw

    mov eax, fShot2

    xor dl, dl
    mov dh, numShots2 
    .while dl < dh
        mov ecx, eax
        add ecx, 4
        invoke movObj, ecx

        mov eax, [eax].next

        inc dl
    .endw

    assume eax:nothing

    ret
movShots endp

canMov proc p1:gameObj, p2:gameObj 
    local d2:dword 
;________________________________________________________________________________

    invoke movObj, addr p1 
    invoke movObj, addr p2   

    
;________________________________________________________________________________

    mov ax, p2.x 
    sub ax, p1.x
    invoke mult, ax, ax
    mov d2, eax


    mov ax, p2.y 
    sub ax, p1.y
    invoke mult, ax, ax
    add d2, eax

;________________________________________________________________________________   

    .if d2 < IMG_SIZE2
        mov canPlyrsMov.x, FALSE
        mov canPlyrsMov.y, FALSE
        ret
    .endif

;________________________________________________________________________________

    ;Player1:
    mov canPlyrsMov.x, FALSE
    .if p1.x <= OFFSETX && p1.x >= HALF_SIZE &&\
        p1.y <= OFFSETY && p1.y >= HALF_SIZE
        mov canPlyrsMov.x, TRUE    
    .endif

    ;Player2:
    mov canPlyrsMov.y, FALSE
    .if p2.x <= OFFSETX && p2.x >= HALF_SIZE &&\
        p2.y <= OFFSETY && p2.y >= HALF_SIZE
        mov canPlyrsMov.y, TRUE    
    .endif

    ret
canMov endp

checkCrashs proc uses ebx edx
    assume ebx:ptr node

 ;Periksa apakah pemain 1 terkena tembakan:
    mov ebx, fShot1

    xor dl, dl
    mov dh, numShots1
    .while dl < dh
        invoke checkShot, player2.playerObj, [ebx].value

        .if eax
			invoke checkShot, player2.playerObj, [ebx].value

            invoke incScore, addr scoreP1

            mov hit, TRUE

            .break .if (TRUE)
        .endif

        mov ebx, [ebx].next
        inc dl
    .endw

;Memeriksa apakah pemain 1 terkena:
    mov ebx, fShot2

    xor dl, dl
    mov dh, numShots2
    .while dl < dh
        invoke checkShot, player1.playerObj, [ebx].value

        .if eax
            invoke incScore, addr scoreP2

            mov hit, TRUE

            .break .if (TRUE)
        .endif

        mov ebx, [ebx].next
        inc dl
    .endw

    assume ebx:nothing

    ret
checkCrashs endp

checkShot proc plyr:gameObj, shot:gameObj
    local d2:dword ;Kuadrat jarak antara peluru dan pemain
;d ^ 2 = (xp - xs) ^ 2 + (yp - ys) ^ 2

;Menghitung d2:---------------------------------------------------------------
;________________________________________________________________________________

    mov ax, plyr.x 
    sub ax, shot.x
    invoke mult, ax, ax
    mov d2, eax


    mov ax, plyr.y 
    sub ax, shot.y
    invoke mult, ax, ax
    add d2, eax


;________________________________________________________________________________   

    .if d2 < D2_SHOT
        mov eax, TRUE
	.else 
		mov eax, FALSE
    .endif
    
    ret
checkShot endp

printPlyr proc plyr:player, _hdc:HDC, _hMemDC:HDC, whichImg:byte ;Mendesain pada layar seorang pemain:
;Memilih gambar yang akan digunakan:
;________________________________________________________________________________
 
	.if whichImg
	    .if plyr.direc == 0
	        invoke SelectObject, _hMemDC, h100
	    .elseif plyr.direc == 1
	        invoke SelectObject, _hMemDC, h101
	    .elseif plyr.direc == 2
	        invoke SelectObject, _hMemDC, h102
	    .elseif plyr.direc == 3
	        invoke SelectObject, _hMemDC, h103
	    .elseif plyr.direc == 4
	        invoke SelectObject, _hMemDC, h104
	    .elseif plyr.direc == 5
	        invoke SelectObject, _hMemDC, h105
	    .elseif plyr.direc == 6
	        invoke SelectObject, _hMemDC, h106
	    .else
	        invoke SelectObject, _hMemDC, h107
	    .endif
	.else

		.if plyr.direc == 0
	        invoke SelectObject, _hMemDC, h110
	    .elseif plyr.direc == 1
	        invoke SelectObject, _hMemDC, h111
	    .elseif plyr.direc == 2
	        invoke SelectObject, _hMemDC, h112
	    .elseif plyr.direc == 3
	        invoke SelectObject, _hMemDC, h113
	    .elseif plyr.direc == 4
	        invoke SelectObject, _hMemDC, h114
	    .elseif plyr.direc == 5
	        invoke SelectObject, _hMemDC, h115
	    .elseif plyr.direc == 6
	        invoke SelectObject, _hMemDC, h116
	    .else
	        invoke SelectObject, _hMemDC, h117
	    .endif
	.endif
;Menghitung koordinat poin atas kiri:
;________________________________________________________________________________

    movzx eax, plyr.playerObj.x
    movzx ebx, plyr.playerObj.y
    sub eax, HALF_SIZE
    sub ebx, HALF_SIZE

;________________________________________________________________________________

    invoke TransparentBlt, _hdc, eax, ebx,\
        IMG_SIZE, IMG_SIZE, _hMemDC,\    
        0, 0, IMG_SIZE, IMG_SIZE, 16777215

    ret
printPlyr endp

printShots proc uses eax edx _hdc:HDC ;menggambar semua peluru di layar:
    local currShot:gameObj

    assume eax:ptr node

   ;Menggambar tembakan dari pemain 1
    mov eax, fShot1

    xor dl, dl
    mov dh, numShots1 
    .while dl < dh
        mov bx, [eax].value.x
        mov currShot.x, bx
        mov bx, [eax].value.y
        mov currShot.y, bx

        mov bx, [eax].value.speed
        mov currShot.speed, bx

        invoke printShot, currShot, _hdc 

        mov eax, [eax].next

        inc dl
    .endw

    ;Menggambar tembakan dari pemain 2
    mov eax, fShot2

    xor dl, dl
    mov dh, numShots2 
    .while dl < dh
        mov bx, [eax].value.x
        mov currShot.x, bx
        mov bx, [eax].value.y
        mov currShot.y, bx

        mov bx, [eax].value.speed
        mov currShot.speed, bx

        invoke printShot, currShot, _hdc 

        mov eax, [eax].next

        inc dl
    .endw

    assume eax:nothing

    ret
printShots endp

printShot proc uses eax edx shot:gameObj, _hdc:HDC ;Menggambar peluru di layar:
    local upperLX:dword
    local upperLY:dword

    ;Menghitung koordinat titik kiri atas:
;________________________________________________________________________________

    movzx eax, shot.x
    movzx ebx, shot.y
    sub eax, SHOT_RADIUS
    sub ebx, SHOT_RADIUS

    mov upperLX, eax  
    mov upperLY, ebx
;________________________________________________________________________________

    movzx eax, shot.x
    movzx ebx, shot.y
    add eax, SHOT_RADIUS
    add ebx, SHOT_RADIUS

    invoke Ellipse, _hdc, upperLX, upperLY,\
        eax, ebx

    ret
printShot endp
    
printScores proc _hdc:HDC
    ;Menghitung koordinat poin atas kiri:
    invoke SetTextAlign, _hdc, TA_LEFT
    invoke TextOut, _hdc, SCORE_SPACING, SCORE_SPACING, addr scoreP1, 2

    ;Menghitung koordinat poin atas kanan:
    invoke SetTextAlign, _hdc, TA_RIGHT
    invoke TextOut, _hdc, WIN_WD - SCORE_SPACING, SCORE_SPACING, addr scoreP2, 2

    ret
printScores endp

incScore proc addrScore:dword ;Menambah satu pada skor yang diberikan:
    assume eax:ptr pair
    mov eax, addrScore

    .if [eax].y == 48 + 9
        mov [eax].y, 48 + 0

        .if [eax].x == 48 + 9
            mov [eax].x, 48 + 0
            mov [eax].y, 48 + 0
        .else
            inc [eax].x
        .endif
    .else
        inc [eax].y
    .endif


    assume eax:nothing

    ret
incScore endp

updateScreen proc 
    locaL ps:PAINTSTRUCT
    locaL hMemDC:HDC 
    locaL hdc:HDC 

    invoke BeginPaint, hWnd, addr ps 
    mov hdc, eax 

    invoke CreateCompatibleDC, hdc 
    mov hMemDC, eax 
    
    .if !over
        ;Gambar para pemain:
        invoke printPlyr, player1, hdc, hMemDC, TRUE
        invoke printPlyr, player2, hdc, hMemDC, FALSE

        ;Menggambar tembakan:
        invoke printShots, hdc 

        ;Menggambar skor:
        invoke printScores, hdc
    .else ;Jika permainan berakhir:
        invoke SetTextAlign, hdc, TA_CENTER

        .if over == 3 
;Jika seri:
            invoke TextOut, hdc, WIN_WD / 2, WIN_HT / 2, addr draw, len_draw
        .elseif over == 1 ;Jika yang pertama menang:
            invoke TextOut, hdc, WIN_WD / 2, WIN_HT / 2, addr won1, len_won1
        .elseif over == 2 ;Jika yang kedua menang:
            invoke TextOut, hdc, WIN_WD / 2, WIN_HT / 2, addr won2, len_won2
        .endif
    .endif

    invoke DeleteDC, hMemDC 
    invoke EndPaint, hWnd, addr ps 
    
    ret
updateScreen endp

gameHandler proc p:dword
    .while !over
        invoke  Sleep, 60

        invoke movShots ;Memindahkan semua bidikan di layar

        invoke canMov, player1.playerObj, player2.playerObj 
;________________________________________________________________________________

        .if canPlyrsMov.x 
            invoke movObj, addr player1.playerObj
        .endif

        .if canPlyrsMov.y
            invoke movObj, addr player2.playerObj
        .endif
;________________________________________________________________________________

        ;;Memperbarui arah pemain berdasarkan kecepatan kapak mereka:
        invoke updateDirec, addr player1
        invoke updateDirec, addr player2

        .if isShooting.x
            ;Menambahkan bidikan jika waktu tunda telah tercapai:
        	.if shotsDelays.x == SHOTS_DELAY
            	invoke addShot, player1, addr fShot1, addr lShot1,\
                    addr numShots1 

            	mov shotsDelays.x, 0
            .else
            	inc shotsDelays.x
            .endif
        .endif

        .if isShooting.y
            ;Menambahkan bidikan jika waktu tunda telah tercapai:
        	.if shotsDelays.y == SHOTS_DELAY
				invoke addShot, player2, addr fShot2, addr lShot2,\
                    addr numShots2

				mov shotsDelays.y, 0
            .else
            	inc shotsDelays.y
            .endif
        .endif

		invoke checkCrashs ;Memeriksa apakah pemain terkena tembakan

        .if hit ;Jika dipukul, pemain kembali ke posisi awal:
            mov hit, FALSE
            invoke clearAllShots

            invoke resetAll
        .endif

        ;Memeriksa apakah permainan sudah berakhir:
;________________________________________________________________________________

        mov dl, maxScore.x
        mov dh, maxScore.y
        .if scoreP1.x == dl && scoreP1.y == dh
            invoke clearAllShots
            mov over, 1
        .endif
            
        .if scoreP2.x == dl && scoreP2.y == dh
            invoke clearAllShots
            or over, 2
        .endif
;________________________________________________________________________________


        invoke InvalidateRect, hWnd, NULL, TRUE
    .endw

    ret
gameHandler endp

updateDirec proc addrPlyr:dword ;Memperbarui arah pemain berdasarkan
                                ; kecepatan sumbu:
    assume eax:ptr player
    mov eax, addrPlyr

    mov bh, [eax].playerObj.speed.x
    mov bl, [eax].playerObj.speed.y

    .if bh != 0 || bl != 0
        .if bh == 0 ;Jika bernilai nol:
            .if bl > 7fh ;Jika bernilai negatif:
                mov [eax].direc, 1   
            .else ;Jika bernilai positif:
                mov [eax].direc, 5  
            .endif 
        .elseif bh > 7fh;Jika bernilai negatif:
            .if bl == 0 ;Jika bernilai nol:
                mov [eax].direc, 7  
            .elseif bl > 7fh ;;Jika bernilai negatif:
                mov [eax].direc, 0   
            .else ;Jika bernilai positif:
                mov [eax].direc, 6  
            .endif    
        .else ;Jika bernilai positif:
            .if bl == 0 ;Jika bernilai nol:
                mov [eax].direc, 3  
            .elseif bl > 7fh ;Jika bernilai negatif:
                mov [eax].direc, 2   
            .else ;Jika bernilai positif:
                mov [eax].direc, 4  
            .endif 
        .endif
    .endif

    assume eax:nothing

    ret
updateDirec endp

addShot proc plyr:player, fNodePtrPtr:dword, lNodePtrPtr:dword, sizePtr:dword 
                                                ;Menambahkan bidikan ke daftar:
    local newShot: gameObj

    mov eax, sizePtr
    mov al, [eax]

    .if al == TRACKED_SHOTS ;Periksa apakah daftar sudah penuh, jika benar tembakan pertama
                            ;dari daftar dihapus:
        invoke removeFNode, fNodePtrPtr, lNodePtrPtr, sizePtr
    .endif 
    
    ; Buat tembakan baru di posisi pemain:
    mov ax, plyr.playerObj.x
    mov newShot.x, ax
    mov ax, plyr.playerObj.y
    mov newShot.y, ax

    ;Memindahkan tembakan ke depan laras tangki:
;________________________________________________________________________________

    mov al, plyr.direc

    .if al == 0 || al == 1 || al == 2
        mov newShot.speed.y, SHOT_SPEED * -SPEED
        sub newShot.y, HALF_SIZE
    .elseif al == 6 || al == 5 || al == 4
        mov newShot.speed.y, SHOT_SPEED * SPEED
        add newShot.y, HALF_SIZE
    .else ; Jika 3 atau 7
        mov newShot.speed.y, 0
    .endif 

    .if al == 0 || al == 7 || al == 6
        mov newShot.speed.x, SHOT_SPEED * -SPEED
        sub newShot.x, HALF_SIZE
    .elseif al == 2 || al == 3 || al == 4
        mov newShot.speed.x, SHOT_SPEED * SPEED
        add newShot.x, HALF_SIZE
    .else ; Jika 1 atau 5
        mov newShot.speed.x, 0
    .endif 
;________________________________________________________________________________

    invoke addNode, fNodePtrPtr, lNodePtrPtr, sizePtr, newShot ;Menambahkan bidikan ke daftar

    ret
addShot endp

addNode proc fNodePtrPtr:dword, lNodePtrPtr:dword, sizePtr:dword, 
    newValue:gameObj ;Menambahkan simpul di akhir daftar:
    assume eax:ptr node

    invoke GlobalAlloc, GMEM_FIXED, NODE_SIZE ;Alokasikan memori untuk node baru

   ;Menyalin data ke dalam struktur yang dialokasikan baru:----------------------------------
;________________________________________________________________________________

    mov bx, newValue.x
    mov [eax].value.x, bx
    mov bx, newValue.y
    mov [eax].value.y, bx

    mov bx, newValue.speed
    mov [eax].value.speed, bx
    
    mov [eax].next, 0

    assume eax:nothing
;________________________________________________________________________________

    mov ecx, sizePtr
    mov bh, [ecx]

    inc bh 
    mov [ecx], bh

    .if bh == 1 ;Jika daftar kosong:
        mov ecx, fNodePtrPtr  
        mov [ecx], eax ;Buat pointer awal menunjuk ke node baru
    .else
        mov ecx, lNodePtrPtr
        mov ecx, [ecx]

        mov (node ptr [ecx]).next, eax ;Membuat node terakhir menunjuk ke
                                    ; struktur baru
    .endif

    mov ecx, lNodePtrPtr
    mov [ecx], eax ;Membuat penunjuk akhir menunjuk ke yang baru
    ret
addNode endp

removeFNode proc uses edx fNodePtrPtr:dword, lNodePtrPtr:dword, sizePtr:dword
    local nodeSize:byte ;Hapus node dari awal daftar:
    
    ;Berpindah ke semua ukuran daftar:
    mov ebx, sizePtr
    mov al, [ebx]
    
    .if al == 0 ;Jika daftar kosong, metode untuk:
        ret
    .endif

    mov nodeSize, al ;Simpan ukuran daftar untuk digunakan nanti

    assume eax:ptr node

    ;Hapus node dari daftar:
;________________________________________________________________________________

    mov ecx, fNodePtrPtr 
;Memindahkan lokasi tempat alamat node pertama disimpan
    mov eax, [ecx] ; Pindahkan alamat node pertama
    .if nodeSize > 1 ;Jika daftar memiliki lebih dari satu node, yang pertama akan dihapus dan
                    ;start pointer menunjuk ke node kedua:
        mov edx, [eax].next ;Memindahkan alamat node kedua  

        mov [ecx], edx ;Arahkan pointer awal ke node kedua
    .else ;Jika daftar memiliki satu simpul, simpul ini dihapus dan penunjuknya
        ;dinolkan:
        xor edx, edx

        mov [ecx], edx ;Nol penunjuk awal

        mov ecx, lNodePtrPtr
        mov [ecx], edx ;Nol pointer akhir
    .endif

    invoke GlobalFree, eax 
;Menghapus node pertama dari memori
;________________________________________________________________________________

    assume eax:nothing

    ;Mengurangi satu dari ukuran dan menyimpan nilainya:
    dec nodeSize 
    mov al, nodeSize
    mov [ebx], al

    ret
removeFNode endp

clearAllShots proc uses edx 
;Menghapus semua daftar bidikan:
    ;Menghapus tembakan pemain pertama
    xor dl, dl
    mov dh, numShots1
    .while dl < dh
        invoke removeFNode, addr fShot1, addr lShot1, addr numShots1

        inc dl
    .endw

   ;Menghapus tembakan pemain kedua
    xor dl, dl
    mov dh, numShots2
    .while dl < dh
        invoke removeFNode, addr fShot2, addr lShot2, addr numShots2

        inc dl
    .endw

    ret
clearAllShots endp

resetAll proc ;Mereset posisi pemain, menghapus daftar pukulan dan me-reset
            ; kecepatan pemain:

    ;Mereset arah pemain:
	mov player1.direc, 7
	mov player2.direc, 3

    ;Mereset posisi pemain:
;________________________________________________________________________________

	mov player1.playerObj.x, IMG_SIZE
	mov player1.playerObj.y, WIN_HT / 2

	mov player2.playerObj.x, WIN_WD - IMG_SIZE
	mov player2.playerObj.y, WIN_HT / 2
;________________________________________________________________________________

    ;Mereset kecepatan pemain:
;________________________________________________________________________________

	mov player1.playerObj.speed.x, 0
	mov player1.playerObj.speed.y, 0

	mov player2.playerObj.speed.x, 0
	mov player2.playerObj.speed.y, 0
;________________________________________________________________________________

	ret
resetAll endp

end start