//#include "share.h"

#include <avr/io.h>       //required for register definitions


/*
x=0x075BCD15
y=0x159A55E5
z=0x1F123BB5
static uint64_t x=123456789, y=362436069, z=521288629;

uint64_t xorshf96(void) {   
  uint64_t t;
  x ^= x << 16; #
  x ^= x >> 5; #
  x ^= x << 1; #

  t = x;
  x = y;
  y = z;
  z = t ^ x ^ y;
  return z;
}
*/

.data
xyz: 
.BYTE 0x16,0xCD, 0x5E, 0x07 ;x
.BYTE 0xE5, 0x55, 0x9A, 0x15 ;y
.BYTE 0xB5, 0x3B, 0x12, 0x15 ;z

.text


/**
* it uses
*
**/
.global xorshf96
xorshf96:


  lds r22, (xyz);
  lds r23,(xyz+1);
  lds r24,(xyz+2); r11 <- X2
  lds r25,(xyz+3); r12 <- X3
  eor r24,r22;
  eor r25,r23;

  movw r18,r22; take a copy of x
  movw r20,r24

  //now 5 shift to right
  ldi r26, 0x04
RepeatRotate:
  lsr r21
  ror r20
  ror r19
  ror r18
  dec r26
  brne RepeatRotate

  //xor shifted and not shifted and store in initial registers
  eor r22,  r18
  eor r23,  r19
  eor r24,  r20
  eor r25,  r21 

  movw r18,r22; take a copy of x
  movw r20,r24
  
  //shifting one to left by multiplying by 2

  add r18, r18
  adc r19, r19
  adc r20, r20
  adc r21, r20

  //xor shifted and not shifted and store in initial registers
  eor r22,  r18
  eor r23,  r19
  eor r24,  r20
  eor r25,  r21 

  //we load y into r19-21
  lds r18, (xyz+4)
  lds r19, (xyz+5)
  lds r20, (xyz+6)
  lds r21, (xyz+7)

  //then we assign it to x
  sts  (xyz),  r18
  sts  (xyz+1),r19
  sts  (xyz+2),r20
  sts  (xyz+3),r21
  
  //now old y is new x so we do x^t
  //now we do final xor t^x
  eor r22, r18
  eor r23, r19
  eor r24, r20
  eor r25, r21 

  //load z into r16-19
  lds r18, (xyz+8)
  lds r19, (xyz+9)
  lds r20, (xyz+10) 
  lds r21, (xyz+11)

  //then we assign it to y
  sts  (xyz+4), r18
  sts  (xyz+5), r19
  sts  (xyz+6), r20
  sts  (xyz+7), r21

  //now we do final xor (t^x)^y
  eor r22, r18
  eor r23, r19
  eor r24, r20
  eor r25, r21

  //then we assign it back to z
  sts  (xyz+8),  r22
  sts  (xyz+9),  r23
  sts  (xyz+10), r24
  sts  (xyz+11), r25

  ret



.global refresh
refresh:
/*
    push  r18
    push  r19
    push  r20
    push  r21
    ;push  r22
    ;push  r23
    ;push  r24
    ;push  r25
    push  r26
    push  r27
    push  r30
    push  r31
*/
    movw  r30, r24  ;copy a address into Z
    movw  r26, r24  ;copy a address into X
    mov r18,r22
    adiw r30,1
    ;n is in r18
    subi r18, 0x2 ; n-2   too run the loop from 1 to x<n
    ;load a[0] into r19
    ld r19, X; or Z
refresh_for:

    ;calling function xorsh96
    
    
    push  r18
    push  r19
    ;push  r20
    ;push  r21
    ;push  r22
    ;push  r23
    ;push  r24
    ;push  r25
    push  r26
    push  r27
    push  r30
    push  r31

    rcall xorshf96
    
    pop   r31
    pop   r30
    pop   r27
    pop   r26
    ;pop   r25
    ;pop   r24    
    ;pop   r23
    ;pop   r22
    ;pop   r21
    ;pop   r20
    pop   r19
    pop   r18
    



    ;a[0]=a[0] ^ tmp;
    eor r19, r22 ;assume r22 is tmp 
    ; next 3 are
    ; a[i]=a[i] ^ tmp;

    ld  r23, Z
    eor r23, r22
    st  Z+,   r23

    dec r18
    brne refresh_for

    ;save r21 into its place (a[0])
    st X, r19
/*
    pop   r31
    pop   r30
    pop   r27
    pop   r26
    ;pop   r25
    ;pop   r24    
    ;pop   r23
    ;pop   r22
    pop   r21
    pop   r20
    pop   r19
    pop   r18
*/
  ret


/*
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
*/
.global decode
decode:

    push  r16
    push  r17
    push  r28
    push  r29
    ;put address of a[] into Y
    movw  r28, r24
    ;put n into r16
    mov r16, r22
    ;put another copy of n into r17
    mov r17, r22
    dec r17
Decode_For_Loop:
    ;prepare input parameters for xorop
    ; moves n into r22
    mov r22, r16
    ; moves address of a[] into r24
    movw  r24, r28

    rcall  refresh  ; 0x45c0 <refresh>

    dec   r17      ; r17 is (n) 
    brne Decode_For_Loop
   
    ;prepare input parameters for xorop
    ; moves n into r22
    mov r22, r16
    ; moves address of a[] into r24
    movw  r24, r28

    pop r29
    pop r28
    pop r17
    pop r16

    rjmp xorop

/*
byte decode(byte a[],uint8_t n)
{
  uint8_t i;
  for(i=0;i<n;i++)
    refresh(a,n);
  return xorop(a,n);
}

*/