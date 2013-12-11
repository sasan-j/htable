#include "aes_htable.h"

#include <avr/pgmspace.h>
#include <stdint.h>

#include <string.h>

#define K 256
//a divider for dividing process to smaller part though using lower memory
#define DIV 4


typedef uint32_t word;

void subbyte_htable(byte *a,uint8_t n)
{
  byte T[K][n];
  byte Tp[K][n];
  byte b[n];

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
	Tp[k][j]=T[k ^ a[i]][j];

    for(k=0;k<K;k++)
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
