#include "../lib/kernel/print.h"
#include "init.h"
void main(void)
{
    put_str("\nThis is Kernel!\n");
    init_all();
    asm volatile
    (
        "sti"   //为了演示中断，这里先临时开启中断
    );
    while(1);
    
}