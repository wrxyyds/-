;--------  loder 和 kernel  ------------
LOAD_BASE_ADDR equ 0x900 ;汇编的宏定义
LOAD_START_SECTION equ 0x02

;------------------------------------------gdt描述符属性-----------------------------------------------------
DESC_G_4K  equ  1_00000000000000000000000b  ;4k的粒度在段描述符中为高第23位
DESC_D_32  equ  1_0000000000000000000000b   ;D为1表示操作数为32为，他在段描述符中是高22位
DESC_L     equ  0_000000000000000000000b    ;L位表示是64位还是32位
DECS_AVL   equ  0_00000000000000000000b     ;保留字段

;----------------表示段界限字段---------------
DESC_LIMIT_CODE2 equ 1111_0000000000000000b ;全部设置位1 
DESC_LIMIT_DATA2 equ DESC_LIMIT_CODE2 
DESC_LIMIT_VIDEO2 equ 0000_000000000000000b

DESC_P  equ  1_000000000000000b             ;第15位，表示该段基值是否存在
DESC_DPL_0  equ  00_0000000000000b          ;DPL0级权限14——13位表示  0级表示系统权限
DESC_DPL_1  equ  01_0000000000000b
DESC_DPL_2  equ  10_0000000000000b   
DESC_DPL_3  equ  11_0000000000000b

;---------------设置是否为系统段----------------
DESC_S_CODE  equ  1_000000000000b           ;第12位表示是否位系统段，0表示系统段，1表示非系统段
DESC_S_DATA  equ  DESC_S_CODE
DESC_S_sys   equ  0_000000000000b

;----------------设置段属性--------------------
DESC_TYPE_CODE  equ  1000_00000000b          ;x=1,c=0,r=0,a=0 代码段是可执行的，非一致性，不可读，已访问位 a 清 0,从第11位到8位表示
DESC_TYPE_DATA equ 0010_00000000b            ;x=0,e=0,w=1,a=0 数据段是不可执行的，向上扩展的，可写，已访问位 a 清 0

;----------------组合形成高4字节---------------
DESC_CODE_HIGH4  equ  (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DECS_AVL + DESC_LIMIT_CODE2 + DESC_P + DESC_DPL_0 + DESC_S_CODE + DESC_TYPE_CODE + 0x00
DESC_DATA_HIGH4  equ  (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DECS_AVL + DESC_LIMIT_DATA2 + DESC_P + DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x00
DESC_VIDEO_HIGH4  equ  (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DECS_AVL + DESC_LIMIT_VIDEO2 + DESC_P + DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x00

;------------------选择子属性------------------
RPL0  equ  00b
RPL1  equ  01b
RPL2  equ  10b 
RPL3  equ  11b 
TI_GDT  equ  000b 
TI_LDT  equ  100b 