[bits 32]
%define ERROR_CODE nop
%define ZERO push 0
extern put_str

section .data 
intr_str db "interrupt occur!", 0xa, 0

%macro VECTOR 2
section .text 
intr%1entry:
    %2
    push intr_str   ;将字符串地址压栈
    call put_str    ;打印函数
    add esp, 4      ;将参数弹出

    mov al, 0x20    ;中断结束命令EOI
    out 0xa0, al    ;8259A主片发送结束命令
    out 0x20, al    ;8259A从片发送结束命令

    add esp, 4      ;将中断错误码弹出
    iret            ;中断返回

section .data
    dd intr%1entry 
%endmacro

global intr_entry_table
intr_entry_table:

VECTOR 0x00,ZERO                            ;调用之前写好的宏来批量生成中断处理函数，传入参数是中断号码与上面中断宏的%2步骤，这个步骤是什么都不做，还是压入0看p303
VECTOR 0x01,ZERO
VECTOR 0x02,ZERO
VECTOR 0x03,ZERO 
VECTOR 0x04,ZERO
VECTOR 0x05,ZERO
VECTOR 0x06,ZERO
VECTOR 0x07,ZERO 
VECTOR 0x08,ERROR_CODE
VECTOR 0x09,ZERO
VECTOR 0x0a,ERROR_CODE
VECTOR 0x0b,ERROR_CODE 
VECTOR 0x0c,ZERO
VECTOR 0x0d,ERROR_CODE
VECTOR 0x0e,ERROR_CODE
VECTOR 0x0f,ZERO 
VECTOR 0x10,ZERO
VECTOR 0x11,ERROR_CODE
VECTOR 0x12,ZERO
VECTOR 0x13,ZERO 
VECTOR 0x14,ZERO
VECTOR 0x15,ZERO
VECTOR 0x16,ZERO
VECTOR 0x17,ZERO 
VECTOR 0x18,ERROR_CODE
VECTOR 0x19,ZERO
VECTOR 0x1a,ERROR_CODE
VECTOR 0x1b,ERROR_CODE 
VECTOR 0x1c,ZERO
VECTOR 0x1d,ERROR_CODE
VECTOR 0x1e,ERROR_CODE
VECTOR 0x1f,ZERO 
VECTOR 0x20,ZERO

