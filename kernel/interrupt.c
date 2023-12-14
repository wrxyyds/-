//构建中断门描述符表(idt)

#include "interrupt.h"
#include "global.h"

#define IDT_DESC_CNT 0x21    //支持中断描述符个数为33

extern put_str;
extern intr_handler intr_entry_table[IDT_DESC_CNT];  //记录每一个中断处理程序的offset


//中断门描述符
struct gate_desc {
    uint16_t func_offset_low_word; //函数地址低16位地址
    uint16_t selector;             //选择子字段
    uint8_t dcount;                //此项为双字计数字段，是门描述符中的第4字节。这个字段无用
    uint8_t attribute;             //属性字段
    uint16_t func_offset_high_word; //函数偏移高16位地址
};

static struct gate_desc idt[IDT_DESC_CNT]; //idt表

static void make_idt_desc(struct gate_desc* p_gdesc, uint8_t attr, intr_handler function)
{
    p_gdesc->func_offset_low_word = (uint32_t)function & 0x0000FFFF;
    p_gdesc->selector = SELECT_K_CODE;
    p_gdesc->dcount = 0;
    p_gdesc->attribute = attr;
    p_gdesc->func_offset_high_word = ((uint32_t)function & 0xFFFF0000) >> 16;
}

static void idt_desc_init()
{
    for(int i = 0; i < IDT_DESC_CNT; i++)
    {
        make_idt_desc(&idt[i], IDT_DESC_ATTR_DPL0, intr_entry_table[i]);
    }
    put_str("   idt_desc_init finished\n");
}


//初始化中断控制器8259A

#include "../lib/kernel/io.h"

#define PIC_M_CTRL 0x20    //8259A主片控制端口(PIC Master control)
#define PIC_M_DATA 0x21    //主片的数据端口(PIC Master data)
#define PIC_S_CTRL 0xa0    //从片的控制端口(PIC servant control)
#define PIC_S_DATA 0xa1    //从片的数据端口(PIC servant control)

static void pic_init(void)
{
    //初始化主片
    outb(PIC_M_CTRL, 0x11);  //ICW1：边沿触发，级联8259，需要ICW4。ICW(interrupt control word)
    outb(PIC_M_DATA, 0x20);  //ICW2：起始中断向量号0x20，也就是IR[0-7]为0x20 ~ 0x27
    outb(PIC_M_DATA, 0x04);  //ICW3: IR2接从片
    outb(PIC_M_DATA, 0x01);  //ICW4：8086模式，正常EOI（需要手动提交中断处理完成）

    //初始化从片
    outb(PIC_S_CTRL, 0x11);  //ICW1：边沿触发，需要设置ICW4
    outb(PIC_S_DATA, 0x28);  //ICW2：起始中断向量号为0x28
    outb(PIC_S_DATA, 0x02);  //ICW3：设置从片链接主片的IR2引脚
    outb(PIC_S_DATA, 0x01);  //ICW4：8086模式，正常EOI

    /* 打开主片上IR0,也就是目前只接受时钟产生的中断 */
    outb(PIC_M_DATA, 0xfe);
    outb(PIC_S_DATA, 0xff);

    put_str("  pic_init finished\n");
}

//完成中断所以相关的初始化

void idt_init()
{
    put_str("idt_init start\n");
    idt_desc_init(); //初始化中断门描述符表
    pic_init();  //初始化中断控制器

    //将idt相关内容加载到idtr
    uint64_t idtr = (((uint64_t)idt << 16) | sizeof(idt) - 1);
    asm volatile("lidt %0" : : "m"(idtr));
    put_str("idt_init finished\n");
}