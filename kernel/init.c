#include "init.h"
#include "print.h"
#include "interrupt.h"
#include "../device/timer.h"		  // 用相对路径演示头文件包含
#include "../lib/kernel/memory.h"
#include "../thread/thread.h"
#include "../device/console.h"
#include "../device/keyboard.h"
#include "../lib/user/tss.h"
#include "../lib/user/syscall_init.h"
/*负责初始化所有模块 */
void init_all() {
   put_str("init_all start\n");
   idt_init();    // 初始化中断
   mem_init();	  // 初始化内存管理系统
   thread_init(); // 初始化线程相关结构
   timer_init();  // 初始化PIT
   console_init();
   keyboard_init();
   tss_init();
   syscall_init();
   put_str("init_all end\n");
}

