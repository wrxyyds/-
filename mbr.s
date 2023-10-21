%include "boot.inc"
SECTION MBR vstart=0x7c00 
mov ax,cs 
mov ds,ax 
mov es,ax 
mov ss,ax 
mov fs,ax 
mov sp,0x7c00 
mov ax,0xb800 
mov gs,ax 
 
mov ax, 0600h 
mov bx, 0700h 
mov cx, 0  
mov dx, 184fh

int 0x10

mov byte [gs:0x00],'1' 
mov byte [gs:0x01],0xA4    ;A 表示绿色背景闪烁，4 表示前景色为红色
 
mov byte [gs:0x02],' ' 
mov byte [gs:0x03],0xA4 
 
mov byte [gs:0x04],'M' 
mov byte [gs:0x05],0xA4 

mov byte [gs:0x06],'B' 
mov byte [gs:0x07],0xA4 
 
mov byte [gs:0x08],'R' 
mov byte [gs:0x09],0xA4 

;设置参数
mov eax,LOADER_START_SECTION ;由寄存器传递参数eax中放入LBA中的扇区编号
mov bx,LOADER_BASE_ADDR      ;bx寄存器中存放内存地址
mov cx,2                   ;cx存放读取扇区数

;函数调用
call rd_disk_m_16

jmp LOADER_BASE_ADDR         ;跳转指令，由load代码拥有cpu使用权

;从磁盘中读取n个扇区的数据到指定内存位置
rd_disk_m_16:
mov esi,eax                ;备份eax
mov di,cx                  ;备份cx

;第一步：向0x1F2端口写入读取扇区的数量
mov dx,0x1F2               ;dx寄存器指定端口号
mov al,cl
out dx,al                  ;写入0x1F2端口

;第二步：
;分别向0x1F3,0x1F4,0x1F5,0x1F6端口写入所要读取的磁盘位置,并设置成LBA模式
;0x1F3存放0——7位，0x1F4存放8——15位，0x1F5存放16——23位，24——27位存放到0x1F6端口中，并在其端口设置LBA模式
mov eax,esi                ;恢复eax的值
mov dx,0x1F3               ;确定端口号
out dx,al                  ;写入低8位

mov cl,8
shr eax,cl
mov dx,0x1f4
out dx,al

shr eax,cl
mov dx,0x1F5
out dx,al

shr eax,cl
and al,0x0F                ;保留4位
or al,0xe0                 ;设置7——4位位1110
mov dx,0x1F6
out dx,al

;第三步：向0x1F7端口写入命令，0x20表示从磁盘读取数据
mov dx,0x1F7
mov al,0x20
out dx,al

;第四不：检查读取是否完成，检查0x1F7端口
.not_ready:
nop                        ;cpu不执行任何指令，相当于等待一会
in al,dx                   ;此时dx仍为0x1F7
and al,0x88                ;第四位为1表示硬盘控制器已经读取完成，第八位位1表示硬盘忙0x88 10001000
cmp al,0x08
jnz .not_ready             ;上一个指令结果不为0表示磁盘数据没有完全读取到磁盘控制器的缓冲区中，进行循环直到读取完成跳出循环继续执行

;第五步：将数据从缓冲区读入到指定内存中，从端口0x1f0读取数据，读取一次是2字节（0x1F0寄存器是16位，其他的端口都是8位）
mov ax,di                  ;di表示要读取的扇区数
mov dx,256
mul dx                     ;ax存放低16位结果
mov cx,ax                  ;表示读取的次数

mov dx,0x1F0
.go_on_read:
in ax,dx                   ;从0x1F0端口读取数据
mov [bx],ax                ;bx为0x900是LOAD_BASE_ADDR
add bx,2                   ;bx向后移动2字节
loop .go_on_read

ret                        ;函数返回

times 510-($-$$) db 0      ;保障mbr有512字节
db 0x55,0xaa               ;结束标志