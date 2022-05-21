#include<stdio.h>
#include<stdlib.h>
struct b{
    int c;
};
struct a{
    int e;
    struct b d;
};
void main(){
    struct a a1;
    a1.e=0;
    a1.d.c=0;
    printf("&a1:%x\n",&a1);
    printf("&d:%x\n",(int*)&a1+1);
    printf("%x\n",&(a1.d));
    printf("%d\n",*(int*)(&(a1.d)));
    //return 0;
}