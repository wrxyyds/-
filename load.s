%include "boot.inc"
section load vstart = LOAD_BASE_ADDR
LOAD_STACK_TOP equ LOAD_BASE_ADDR
jmp load_start

;构建gdt及其内部描述符  dd是一个伪指令从前向后开辟4字节
GDT_BASE: dd 0x00000000
          dd 0x00000000  ;全局段描述符表的第一个描述符，因为第一个描述符不可用所以全置为0

CODE_DESC: dd 0x0000FFFF ;段基址在高4字节关于段基址的位都置为0，段界限相关的位都置为1，在这里第4字节中的第16位置为1设置最大段界限值，高16位置为0设置段基址位0
           dd DESC_CODE_HIGH4 ; dpl为0

DATA_STACK_DESC: dd 0x0000FFFF
                 dd DESC_DATA_HIGH4 ; 这个数据栈段段基址为0x0，向上扩展的不可执行，可写入，dpl为0,且已访问位a已经清0

VIDEO_DESC: dd 0xb8000007 ;电脑显存文本段的内存空间位0xb800--0xbfff,因为此段粒度为4k，界限值为(0xbfff-0xb800)/4k=7
            dd DESC_VIDEO_HIGH4 ;设置高四位

GDT_SIZE equ $ - GDT_BASE ;计算表的大小
GDT_LIMIT equ GDT_SIZE - 1 ;界限值是从0开始的，及0代表1有一个粒度大小的空间
times 60 dq 0  ;预留60个8字节描述符

SELECTOR_CODE equ (0x0001 << 3) + TI_GDT + RPL0 ;选择子放在段寄存器上是16位的，高13位表示描述符在GDT中的索引值，最后两位代表段的权限级，第三位表示是在GDT中还是在LDT中
SELECTOR_DATA equ (0x0002 << 3) + TI_GDT + RPL0
SELECTOR_VIDEO equ (0x003 << 3) + TI_GDT + RPL0

gdt_ptr dw GDT_LIMIT
        dd GDT_BASE

loadmsg db '2 loader in real'


;----------------------初始化工作完成,代码开始执行-----------------------
[bits 16]
load_start:

;----------------------用int 0x10号中断实现向屏幕输出---------------------------
;输入:
;AH 子功能号 = 13H
;BH = 页码
;BL = 属性（）
;cx = 字符串长度
;(DH, DL) = 坐标（行列）
;es:ip = 字符串地址
;AL = 显示输出方式
; 0 ——————— 字符串中只含显示字符，其显示属性在BL中
            ;显示后，光标位置不变
  1 ——————— 字符串中只含显示字符，其显示属性在BL中
            ;显示后，光标位置改变
; 2 ——————— 字符串中含显示字符和显示属性。显示后，光标位置不变
; 3 ——————— 字符串中含显示字符和显示属性。显示后，光标位置改变
;无返回值

mov sp, LOAD_BASE_ADDR
mov bp, loadmsg
mov cx, 17
mov ax, 0x1301
mov bx, 0x001f
mov dx, 0x1800
int 0x10

;-----------------打开A20地址线---------------------
in al, 0x92
or al, 0000_0010b
out 0x92, al

;----------------加载 GDT-------------------------
lgdt [gdt_ptr] ;lgdt 48位空间，前16位是界限值，后32位为段基址地址

;--------------cr0寄存器 0位置为1------------------
mov eax, cr0
or eax, 0x00000001
mov cr0, eax

jmp dword SELECTOR_CODE:p_mode_start   ;刷新流水线


[bits 32]
p_mode_start:
mov ax, SELECTOR_DATA
mov ds, ax
mov es, ax
mov ss, ax
mov esp, LOAD_STACK_TOP
mov ax, SELECTOR_VIDEO
mov gs, ax
mov byte [gs:160], 'p'

jmp $
