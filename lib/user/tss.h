#ifndef __LIB_TSS_H
#define __LIB_TSS_H
#include "../thread/thread.h"
void tss_init(void);
void update_tss_esp(struct task_struct*pthread);
#endif