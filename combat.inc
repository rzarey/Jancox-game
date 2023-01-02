include C:\masm32\include\windows.inc
include C:\masm32\include\masm32.inc
include C:\masm32\include\gdi32.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\Comctl32.inc
include C:\masm32\include\comdlg32.inc
include C:\masm32\include\shell32.inc
include C:\masm32\include\msimg32.inc

includelib C:\masm32\lib\masm32.lib
includelib C:\masm32\lib\gdi32.lib
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\Comctl32.lib
includelib C:\masm32\lib\comdlg32.lib
includelib C:\masm32\lib\shell32.lib
includelib C:\masm32\lib\msimg32.lib

;=================
; structs
;=================
pair struct ; Pasangan terurut (<a, b>): 
    x  db ?
    y  db ?
pair ends

gameObj struct ;Objek utama (<x, y, <Vx, Vy>>):
	x  dw ?
    y  dw ?
    
	speed pair <>
gameObj ends

player struct 
;Data pemain (<Hidup, <x, y, <Vx, Vy>>>):
    life db ?
    direc db ?

    playerObj gameObj <>
player ends

node struct ;Simpul dari daftar tertaut
    next dd ?
    value gameObj <>
node ends

;=================
; consts
;=================
.const
	WIN_HT equ 700 ;Tinggi jendela
    WIN_WD equ 1200 ;Lebar jendela

    OFFSETX equ WIN_WD - HALF_SIZE
    OFFSETY equ WIN_HT - HALF_SIZE

    IMG_SIZE equ 32 ;Tinggi dan lebar img pemain
    IMG_SIZE2 equ IMG_SIZE * IMG_SIZE ;Kuadrat IMG_SIZE
    HALF_SIZE equ IMG_SIZE / 2 

    SHOT_RADIUS equ 3

    D2_SHOT equ (HALF_SIZE + SHOT_RADIUS) * (HALF_SIZE + SHOT_RADIUS) ;Kotak
                                    ; jarak minimum antara tembakan dan pemain

    SCORE_SPACING equ 10 ; Ruang pemisahan digit permainan

    SPEED equ 4 ; Kecepatan pemain
    MAX_SCORE equ 5 ;Skor maksimum untuk akhir permainan
    MAX_LIFE equ 100 ;Memulai kesehatan pemain
    SHOTS_DELAY equ 3 ;Jumlah siklus menunggu untuk diaktifkan
    TRACKED_SHOTS equ 255 ;Jumlah bidikan maksimum di layar,
    ; sebelum menghilang (untuk setiap pemain)

    SHOT_SPEED equ 3 ;Pengganda kecepatan tembakan 

    NODE_SIZE equ SIZEOF node ;Ukuran dalam byte dari struktur node

;=================
; data
;=================
.data      
AppName db "Jancox", 0 ;Judul jendela
ClassName db "JancoxClass", 0 ; Kelas jendela

won1 db "Pemain 1 menang!!! Tekan (r) untuk mengatur ulang.", 0
len_won1 equ $ - won1

won2 db "Pemain 2 menang!!! Tekan (r) untuk mengatur ulang.", 0
len_won2 equ $ - won2

draw db "Dengarkan dasi!!! Tekan (r) untuk mengatur ulang.", 0
len_draw equ $ - draw

;Pemain 1 bitmap:
h100 dd 0
h101 dd 0
h102 dd 0
h103 dd 0
h104 dd 0
h105 dd 0
h106 dd 0
h107 dd 0

;Pemain 2 bitmap:
h110 dd 0
h111 dd 0
h112 dd 0
h113 dd 0
h114 dd 0
h115 dd 0
h116 dd 0
h117 dd 0

.data?                
hWnd HWND ?
threadID DWORD ?
hInstance HINSTANCE ?  

;=================
; prototypes
;=================
WinMain proto :DWORD, :DWORD   

loadBitmaps proto ; Memuat bitmap game

gameHandler proto :DWORD ;Utas utama permainan
updateScreen proto ;Menggambar semua objek di layar
printShots proto :HDC ;Menarik semua tembakan
printScores proto :HDC ;Gambarlah papan skor para pemain
printShot proto :gameObj, :HDC ;Menarik tembakan terakhir
printPlyr proto :player, :HDC, :HDC, :BYTE ;Gambar pemain terakhir

movShots proto ;Pindahkan semua tembakan
movObj proto :DWORD ;Memperbarui posisi gameObj yang diteruskan

updateDirec proto :DWORD ;Memperbarui arah pemain

canMov proto :gameObj, :gameObj ;Memperbarui apakah setiap pemain dapat bergerak

mult proto :WORD, :WORD ;Kalikan dua angka (16b) dan masukkan ke dalam eax

incScore proto :DWORD ;Meningkatkan skor pemain terakhir
checkCrashs proto ;Incrementa o score quando um jogador acerta um tiro;Meningkatkan skor saat pemain melakukan pukulan
checkShot proto :gameObj, :gameObj ;Memeriksa apakah tembakan mengenai pemain

resetAll proto ;Mereset posisi pemain ke posisi awal

;Metode daftar tertaut:

addShot proto :player, :DWORD, :DWORD, :DWORD ;Menambahkan bidikan ke daftar
                                            ;(data pemain yang menembak, ptr
                                            ;untuk ptr dari node pertama, ptr untuk
                                            ; ptr dari node terakhir, ptr untuk
                                            ; ukuran daftar)

;Menambahkan node di akhir daftar (ptr untuk ptr dari node pertama,
;ptr untuk ptr dari simpul terakhir, ptr untuk panjang daftar, data baru):
addNode proto :DWORD, :DWORD, :DWORD, :gameObj 

removeFNode proto :DWORD, :DWORD, :DWORD ;Hapus node dari awal daftar
                                        ;(ptr untuk ptr dari node pertama, ptr
                                        ;untuk ptr dari node terakhir, ptr untuk
                                        ; ukuran daftar)

clearAllShots proto ;Hapus daftar bidikan
