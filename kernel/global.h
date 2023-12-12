#ifndef __KERNEL_GLOBAL_H
#define __KERNEL_GLOBAL_H
#include "../stdint.h"

//选择子的RPL字段
#define RPL0 0
#define RPL1 1
#define RPL2 2
#define RPL3 3

//选择子的TI字段
#define TI_GDT 0
#define TI_LDT 1

//定义内核段描述符选择子
#define SELECT_K_CODE ((1 << 3) + (TI_GDT << 2) + RPL0)
#define SELECT_K_DATA ((2 << 3) + (TI_GDT << 2) + RPL0)
#define SELECT_K_STACK SELECT_K_DATA
#define SELECT_K_GS ((3 << 3) + (TI_GDT << 2) + RPL0)

//定义中断门描述符attr字段，attr字段指的是中断门描述符高32位的第八位到15位

#define IDT_DESC_P 1
#define IDT_DESC_DPL0 0     //只有内核才能调用的中断
#define IDT_DESC_DPL3 3     //用户进程可以调用的中断
#define IDT_DESC_32_TYPE 0xE  //32位门
#define IDT_DESC_16_TYPE 0x6

//中断描述符高32位中的8位到15位
#define IDT_DESC_ATTR_DPL0 ((IDT_DESC_P << 7) + (IDT_DESC_DPL0 << 5) + IDT_DESC_32_TYPE)
#define IDT_DESC_ATTR_DPL3 ((IDT_DESC_P << 7) + (IDT_DESC_DPL3 << 5) + IDT_DESC_32_TYPE)
#endif