#include "aes_htable.h"

#include <avr/pgmspace.h>
#include <stdint.h>
#include <avr/io.h> 
#include <string.h>
#include <stdlib.h>


#define K 256
//a divider for dividing process to smaller part though using lower memory
#define DIV 4



typedef uint32_t word;


void subbyte_htable(byte *a_array,uint8_t n)
{
  byte T[K][n];
  byte Tp[K][n];
  byte b[n];
  //b=(byte*) malloc(n*sizeof(byte));
  uint16_t arrayAddresses[4];

  arrayAddresses[0]=a_array;
  arrayAddresses[1]=&T;
  arrayAddresses[2]=&Tp;
  arrayAddresses[3]=&b;

  uint8_t i,j;
  uint16_t k;
  for(k=0;k<K;k++){
    //share(sbox[k],T[k],n);
    share(pgm_read_byte(&(sbox[k])),T[k],n);
  }
  
  for(i=0;i<(n-1);i++)
  {
    for(k=0;k<K;k++)
      for(j=0;j<n;j++)
         Tp[k][j]=T[k ^ a_array[i]][j];

    for(k=0;k<K;k++)
    {
      for(j=0;j<n;j++) 
  T[k][j]=Tp[k][j];
      refresh(T[k],n);
    }
  }

/*
  asm volatile("END1: " "\n\t");
  for(j=0;j<n;j++)
    b[j]=T[a_array[n-1]][j];
*/

__asm__(

    "mov r17, %[n]" "\n\t" ///*Loads n into one register*/
    "dec r17" "\n\t" ////Loads n-1 into r17*/
    "eor r16, r16" "\n\t" ///*sets r16 to 0 to act as j*/
    "ld r26, Z" "\n\t"
    "ldd r27, Z+1" "\n\t"
    //"add %A[asm_array],r17" "\n\t" ///*next two lines should put address of a_array[n-1] into z register r30,r31 */
    //"adc %B[asm_array],r16" "\n\t" //because im sure that r16 is zero 
    "add r26,r17" "\n\t" ///*next two lines should put address of a_array[n-1] into z register r30,r31 */
    "adc r27,r16" "\n\t" //because im sure that r16 is zero 
    "ld r17,X" "\n\t" // /* Loads a_array[n-1] into r17 */
    ///* now %a[asm_array] is free */


    //"ldd %A[asm_array], Y+1" "\n\t"
    //"ldd %B[asm_array], Y+2" "\n\t" 
    //load T[] base address into x
    "ldd r26, Z+2" "\n\t"
    "ldd r27, Z+3" "\n\t"

    //load b[] base address into z
    "ldd r18, Z+6" "\n\t"
    "ldd r19, Z+7" "\n\t"

    //copy address array address! into a safe place!
    "movw r4,r30" "\n\t"

    "movw r30,r18" "\n\t"

    ///*now b is ready to roll inside %a[asm_array]*/
    //"mov r18, r17" "\n\t" /*moves r17 to a temp register*/
    "mul r17, %[n]" "\n\t" ///* multiply indexes to handle 2d array address - array offset*/
    //"movw %A[t_array], r0" "\n\t" /* add array offset*/
    "add r26, r0" "\n\t"
    "adc r27, r1" "\n\t"
    "eor r1,r1" "\n\t" // to turn it back to zero

    "L_dl1: " "\n\t"  ///*Just for loop label*/

    "ld r18, X+" "\n\t" ///* load the thing from array into r18*/
    "st Z+, r18" "\n\t"  ///*put the thing into b array*/


    "inc r16" "\n\t" ///*  decreases loop index - j*/
    "cp r16,%[n]" "\n\t" ///*  checks loop index with n*/    
    "brne L_dl1" "\n\t" ///*  checks for condiftion */


    //prepare arguments for calling refresh(b,n)
    "movw r30,r4" "\n\t"

    "ldd r24, Z+6" "\n\t"
    "ldd r25, Z+7" "\n\t"
    "eor r23, r23" "\n\t"
    "mov r22, %[n]" "\n\t"

    "push r30" "\n\t"
    "push r31" "\n\t"
    "push %[n]" "\n\t"
    "call refresh" "\n\t"
    "pop %[n]" "\n\t"
    "pop r31" "\n\t"
    "pop r30" "\n\t"


    //"movw r30,r4" "\n\t"
    //load b[] base address into x
    "ldd r26, Z+6" "\n\t"
    "ldd r27, Z+7" "\n\t"

    //load a_array base address into z
    "ld r18, Z" "\n\t"
    "ldd r19, Z+1" "\n\t"

    //copy 
    "movw r30,r18" "\n\t"
    
    "mov r19,%[n]" "\n\t"

    //"dec r19" "\n\t"

    "For_Loop_b2a_array:" "\n\t"
    // load the thing from array into r18
    "ld r18, X+" "\n\t" 
    // put the thing into b array
    "st Z+, r18" "\n\t"  

    "dec r19" "\n\t"
    "brne For_Loop_b2a_array" "\n\t"


    : : [n] "r" (n), [add_array] "z" (arrayAddresses)
    : "r4", "r5","r16", "r17","r18","r19"
  );



  //refresh(b,n);

  //for(j=0;j<n;j++) a_array[j]=b[j];
}

void subbyte_htable_low_mem(byte *a,uint8_t n)
{
  
  byte T[K/DIV][n];
  byte Tp[K/DIV][n];
  byte b[n];

  uint8_t i,j,k,l,kk;

  for(l=0;l<DIV;l++){
  
  for(k=(l*K)/DIV,kk=0;kk<K/DIV;k++,kk++){
    share(pgm_read_byte(&(sbox[k])),T[kk],n);
  }

  /*
    Tp = (byte**) malloc(K*sizeof(byte*));
    for (i = 0; i < K; i++)
    {
	Tp[i] = (byte*) malloc(n*sizeof(byte));
    }
  */
  
  for(i=0;i<(n-1);i++)
  {
    for(k=0;k<K/DIV;k++)
      for(j=0;j<n;j++)
	Tp[k][j]=T[k ^ a[i]][j];

    for(k=0;k<K/DIV;k++)
    {
      for(j=0;j<n;j++) 
	T[k][j]=Tp[k][j];
      refresh(T[k],n);
    }
  }
  
  for(j=0;j<n;j++)
    b[j]=T[a[n-1]][j];
  
  refresh(b,n);
  for(j=0;j<n;j++) a[j]=b[j];
  
  }

}


void refreshword(word a[],uint8_t n)
{
  uint8_t i;
  word tmp;
  for(i=1;i<n;i++)
  {
    tmp=(word)xorshf96(); //rand();
    a[0]=a[0] ^ tmp;
    a[i]=a[i] ^ tmp;
  }
}

void subbyte_htable_word(byte *a,uint8_t n)
{
  uint8_t w=sizeof(word); // number of bytes to store in a word
  word T[K/w][n];
  word Tp[K/w][n];
  uint8_t i,k2,j;
  uint16_t k;
  word r;
  word b[n];
  byte x;
  byte c[n];
  
  for(k=0;k<K/w;k++)
  {
    r=0;
    for(j=w-1;j>=0;j--)
    {
      r=r << 8;
      //r^=sbox[k*w+j];
      r^=pgm_read_byte(&(sbox[k*w+j]));

    }
    T[k][0]=r;
    for(i=1;i<n;i++)
      T[k][i]=0;
  }

  for(i=0;i<(n-1);i++)
  {
    k2=a[i]/w;
    for(k=0;k<K/w;k++)
      memcpy(Tp[k],T[k ^ k2],n*sizeof(word));
    for(k=0;k<K/w;k++)
    {
      memcpy(T[k],Tp[k],n*sizeof(word));
      refreshword(T[k],n);
    }
  }

  memcpy(b,T[a[n-1]/w],n*sizeof(word));

  byte Ts[w][n];
  byte Tsp[w][n];

  for(k=0;k<w;k++)
    for(i=0;i<n;i++)
      Ts[k][i]=b[i] >> (k*8);
  
  for(i=0;i<(n-1);i++)
  {
    for(k=0;k<w;k++)
      memcpy(Tsp[k],Ts[k ^ (a[i] & (w-1))],n);
    for(k=0;k<w;k++)
    {
      memcpy(Ts[k],Tsp[k],n);
      refresh(Ts[k],n);
    }
  }
  memcpy(a,Ts[a[n-1] & (w-1)],n);
  refresh(a,n);
}
