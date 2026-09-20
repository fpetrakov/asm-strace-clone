%define sys_fork 57
%define sys_ptrace 101
%define sys_wait4 61
%define sys_execve 59
%define sys_write 1
%define sys_exit 60
%define sys_process_vm_readv 310
%define stdout 1
%define stderr 2
%define exit_success 0
%define exit_failure 1

%macro ERRMSG 2
    %1 db %2, 10
    %1_len equ $ - %1
%endmacro

section .robata
    ERRMSG err_no_arg, "Error: must have PROG [ARGS] or -p PID"


section .text
    default rel
    global _start

_start:
    mov rcx, [rsp]
    cmp rcx, 2
    jl .no_argument

    mov rsi, [rsp+16]

    .find_arg_end:
        mov cl, byte [rsi+rdx]
        test cl, cl
        jz .end
        inc rdx
        jmp .find_arg_end

    .end:
    call write_out
    call exit_ok

    .no_argument:
        mov rsi, err_no_arg
        mov rdx, err_no_arg_len
        call write_err
        call exit_err

write_out:
    mov rdi, stdout
    mov rax, sys_write
    syscall
    ret

write_err:
    mov rdi, stderr
    mov rax, sys_write
    syscall
    ret

exit_err:
    mov rdi, exit_failure
    mov rax, sys_exit
    syscall

exit_ok:
    mov rdi, exit_success
    mov rax, sys_exit
    syscall
