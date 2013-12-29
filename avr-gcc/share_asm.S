//#include "share.h"

#include <avr/io.h>       //required for register definitions
/*
static uint64_t x=123456789, y=362436069, z=521288629;

uint64_t xorshf96(void) {   
  uint64_t t;
  x ^= x << 16;
  x ^= x >> 5;
  x ^= x << 1;

  t = x;
  x = y;
  y = z;
  z = t ^ x ^ y;
  return z;
}

void refresh(byte a[],uint8_t n)
{
  uint8_t i;
  for(i=1;i<n;i++)
  {
    byte tmp=(byte)xorshf96(); //rand();
    a[0]=a[0] ^ tmp;
    a[i]=a[i] ^ tmp;
  }
}
*/

.extern x_byte 
.extern a_array 
.extern n 


.global share
share: ;r24,r25 - r22,r23 - r20,r21
    movw  r30, r22 
    st  Z+, r24  ; a[0]=x;
    eor r1,r1
    dec r20
L_share_asm:    
    st  Z+, r1
    dec r20
    brne L_share_asm
  ret

/*
void share(byte x,byte a[],uint8_t n)
{
  uint8_t i;
  a[0]=x;
  for(i=1;i<n;i++)
    a[i]=0;
}
*/


.global xorop
xorop:
  movw  r30, r24 ; this will a[] address into Z
  eor   r24, r24 ; to make r24 which is our (r) zero
                 ; r24 should be output because it will be returned
For_Loop:
  ld    r21, Z+  ; loads a[r21] r21 is a temporal variable representing loop index
  eor   r24, r21
  dec   r22      ; r22 is (n) 
  brne For_Loop
  ret 


/*
byte xorop(byte a[],uint8_t n)
{
  uint8_t i;
  byte r=0;
  for(i=0;i<n;i++)
    r^=a[i];
  return r;
}

byte decode(byte a[],uint8_t n)
{
  uint8_t i;
  for(i=0;i<n;i++)
    refresh(a,n);
  return xorop(a,n);
}

*/