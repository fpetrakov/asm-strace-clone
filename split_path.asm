section .text
    default rel
    global _start

split_path:
    ; rdi - pointer to a buffer
    ; rsi - pointer to a stack

    .next_env:
        mov rsi, [rbx] ; rsi = envp[i] pointer to a string
        test rsi, rsi
        jz .not_found

        cmp dword [rsi], 'PATH'
        jne .advance
        cmp byte [rsi + 4], '='
        jne .advance

        add rsi, 5
        xor rdx, rdx ; rdx = length

    .len:
        cmp byte [rsi+rdx], 0
        je .print
        inc rdx
        jmp .len

    .print:
        call write_out
        call exit_ok

    .advance:
        add rbx, 8
        jmp .next_env

    .not_found:
        mov rax, -1
        ret
