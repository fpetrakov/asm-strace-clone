default rel
global find_executable

%define sys_access 21
%define x_ok 1

; find_executable
;   in:  rdi = pointer to path string
;        rsi = num of paths
;        rdx = pointer to buffer with executable string
;   out: rax = pointer to the path with executable (0 if PATH not found)
section .text
find_executable:
    mov r8, rsi
    mov rsi, rdi

    .next:
        test r8, r8
        jz .not_found

        mov rdi, rcx

    .copy_dir:
        cmp byte [rsi], 0
        je .dir_done
        movsb
        jmp .copy_dir

    .dir_done:
        inc rsi
        cmp rdi, rcx
        je .name
        mov al, '/'
        stosb

    .name:
        mov r9, rsi
        mov rsi, rdx

    .copy_name:
        movsd
        cmp byte[rdi-1], 0
        jne .copy_name

    push rcx
    mov eax, sys_access
    mov rdi, rcx
    mov esi, x_ok
    syscall
    pop rcx
    mov rsi, r9
    test rax, rax
    jz .found

    dec r8
    jmp .next

    .found:
        mov rax, rcx
        ret

    .not_found:
        xor eax, eax
        ret
