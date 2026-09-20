default rel

extern split_path

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
%define ptrace_traceme 0
%define ptrace_syscall 24
%define ptrace_getregs 12
%define ptrawce_setoptions 0x4200

%macro ERRMSG 2
    %1 db %2, 10
    %1_len equ $ - %1
%endmacro

section .bss
    path resb 4096

section .robata
    ERRMSG err_path_not_found, "Error: PATH env not found"
    ERRMSG err_no_arg, "Error: must have PROG [ARGS] or -p PID"
    ERRMSG err_ptrace, "Error: ptrace"
    ERRMSG err_execve, "Error: execve"

section .text
global main

main:
    lea rdi, [rel path]
    mov rcx, [rsp]
    lea rsi, [rsp + rcx*8 + 16] ; rsi = &envp[0]
    call split_path

    mov rcx, [rsp]
    cmp rcx, 2
    jl .no_argument

    mov rsi, [rsp+16]

    .find_arg_end:
        mov cl, byte [rsi+rdx]
        test cl, cl
        jz .parent_work
        inc rdx
        jmp .find_arg_end

    .parent_work:
        mov rax, sys_fork
        syscall


        test rax, rax
        jz .child_work
        call find_command
        call exit_ok

    .child_work:
        mov rdi, ptrace_traceme
        xor rsi, rsi
        xor rdx, rdx
        xor rcx, rcx
        mov rax, sys_ptrace
        syscall

        test rax, rax
        jnz .ptrace_err

        call find_command

        mov rdi, [rsp+16]
        lea rsi, [rel command]
        xor rdx, rdx
        mov rax, sys_execve
        syscall

        test rax, rax
        jnz .execve_err

        call exit_ok

        .ptrace_err:
            mov rsi, err_ptrace
            mov rdx, err_ptrace_len
            call write_err
            call exit_err

        .execve_err:
            mov rsi, err_execve
            mov rdx, err_execve_len
            call write_err
            call exit_err

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
