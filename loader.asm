%include 'pe.inc'

PE32

; Data declarations here

BYTE Dll, "MSOWC-patched.DLL",0
; this will cause the exe to be as large as 1MB
; BYTE Empty_class[0x100000]

START
; instructions

	push ecx
	push edx

	; mov ecx, VA(Empty_class)

	; the following code is equivalent to this x64dbg command:
	; eip = 3c7dc946; push 7fa87860; push 0; push 3c6d0000; push 0; alloc 0x100000; ecx = $result; go;

	; PAGE_READWRITE
	push 0x4
	; MEM_COMMIT
	push 0x1000
	; size
	push 0x100000
	push 0
	call [VA(VirtualAlloc)]
	mov edx, eax

	; zero the allocated page
	mov edi, eax
	xor eax, eax
	mov ecx, 0x40000
	stosd

	mov ecx, edx

	push VA(Dll)
	call [VA(LoadLibraryA)]

	; this is a magic constant
	; change it can give your car a different color
	push 0x7fa87860
	push 0	
	push eax

	add eax, 0x10c946
	call eax

	pop edx
	pop ecx
	ret

; data directories here
IMPORT
	LIB kernel32.dll
		FUNC LoadLibraryA
		FUNC VirtualAlloc 
	ENDLIB
ENDIMPORT

END

; Compile
; nasm -f bin -o loader.exe loader.asm