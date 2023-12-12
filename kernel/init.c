#include "init.h"
#include "interrupt.h"

extern put_str;

/*负责初始化所有模块 */
void init_all() {
   put_str("init_all\n");
   idt_init();   //初始化中断
}