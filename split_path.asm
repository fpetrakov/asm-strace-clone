default rel
global split_path

; split_path
;   in:  rdi = pointer to envp array (array of char* terminated by NULL)
;   out: rax = pointer to the first path component (0 if PATH not found)
;        rcx = number of components
;        rdx = pointer to the final NUL terminator of the PATH value
;   clobbers: rdi, rsi, dl
section .text
split_path:
    .next_env:
        mov rsi, [rdi]              ; rsi = envp[i]
        test rsi, rsi
        jz .not_found

        cmp dword [rsi], 'PATH'
        jne .advance
        cmp byte [rsi + 4], '='
        jne .advance

        add rsi, 5                  ; rsi = start of the PATH value
        mov rax, rsi                ; return value: first component
        mov rcx, 1                  ; at least one component

    .scan:
        mov dl, [rsi]
        test dl, dl
        jz .done
        cmp dl, ':'
        jne .next_char
        mov byte [rsi], 0
        inc rcx

    .next_char:
        inc rsi
        jmp .scan

    .done:
        mov rdx, rsi                ; rdx = end of the PATH value
        ret

    .advance:
        add rdi, 8
        jmp .next_env

    .not_found:
        xor eax, eax
        xor ecx, ecx
        xor edx, edx
        ret
