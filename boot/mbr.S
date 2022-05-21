%include "boot.inc" ;预处理
SECTION MBR vstart=0x7c00 ;设置段基址

	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov fs,ax
	mov sp,0x7c00
	mov ax,0xb800
	mov gs,ax
	
	mov ax,0x600
	mov bx,0x700
	mov cx,0
	mov dx,0x184f
	
	int 0x10
    ;以下都是显存的设置 gs=0xb800 就是可以显示字符的内存地址
	mov byte [gs:0x00],'1'
	mov byte [gs:0x01],0xA4
	
	mov byte [gs:0x02],' '
	mov byte [gs:0x03],0xA4
	
	mov byte [gs:0x04],'M'
	mov byte [gs:0x05],0xA4
	
	mov byte [gs:0x06],'B'
	mov byte [gs:0x07],0xA4
	
	mov byte [gs:0x08],'R'
	mov byte [gs:0x09],0xA4
	
	mov eax,LOADER_START_SECTOR ;起始扇区Lba地址
    mov bx,LOADER_BASE_ADDR    ;写入的地址
    mov cx,4                  ;待读入的扇区!!!需要改为4
    call rd_disk_m_16          ;以下读程序的起始部分
    
    jmp LOADER_BASE_ADDR+0x300      ;将数据加载到内存中后就会转而执行这个，其实也就是loader.bin
    
    ;----功能：读取硬盘第n个扇区----
    ;eax LBA扇区号
    ;bx=将内存写入的地址
    ;cx=读入的扇区数
rd_disk_m_16:

    mov esi,eax ;用来备份eax,di
    mov di,cx   ;di=1

    mov dx,0x1f2 ;设置扇区的数量的端口
    mov al,cl    ;al=1,只需要8位
    out dx,al    ;将al写入dx寄存器中，dx寄存器就是端口

    mov eax,esi  ;将eax复位

    mov dx,0x1f3 ;设置LBA的端口
    out dx,al    ;将LBA的7-0位读入端口去

    mov cl,8     ;
    shr eax,cl   ;右移8位
    mov dx,0x1f4
    out dx,al    ;将LBA的15-8位存入端口中去

    shr eax,cl   ;右移8位
    mov dx,0x1f5 
    out dx,al    ;将LBA的23-16位存入端口中去

    shr eax,cl   ;再次右移8位
    and al,0x0f  ;让低4位不变，因为低4位需要保存LBA的28-24位（LBA总共28位）
    or al,0xe0   ;将前四位与1110取或,也就是前三位直接固定，保证寻址模式一定是LBA
    mov dx,0x1f6 ;进入device端口
    out dx,al    ;将信息读给端口

    mov dx,0x1f7 ;命令端口
    mov al,0x20  ;读入扇区的命令
    out dx,al    ;将命令读入端口

    .not_ready:
        nop
        in al,dx ;将端口中的信息读到al中，注意此时dx=0x1f7不变，此时是status寄存器，也就是状态端口
        and al,0x88 ;通过第7位（从0开始），也就是第8位（从1开始），判断硬盘是不是忙碌的，也就是是否被占了，1代表被占
        cmp al,0x08  ;
        jnz .not_ready ;如果被占取了，就循环  jnz=jmp not equal

        mov ax,di  ;di=1
        mov dx,256 
        mul dx     ;dx=ax*dx 每次读取1个字，也就是两字节，一共512字节，所以需要256次
        mov cx,ax  ;cx指定循环的次数
        mov dx,0x1f0 ;数据端口，终于开始读取数据了
        
    .go_on_read:     
        in ax,dx      ;将端口中指定的数据，也就是指定的扇区的数据读入到ax中
        mov [bx],ax   ;bx寄存器存储的就是0x900也就是loader的内存地址
        add bx,2      ;每次读两字节
        loop .go_on_read

        ret            ;返回后就会执行jmp跳转到0x900去了，此时机会执行loader.bin
	
	times 510-($-$$) db 0 ;剩下的数据填充为0
	db 0x55,0xaa        ;魔数,判断是否为mbr
