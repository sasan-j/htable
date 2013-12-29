AVR 8-bit Microcontroller Implementation
======
This code is developed for AVR-GCC C compiler for AVR. It is tested on ATMEGA128 and at the moment because of memory requirements it is only supports 3 shares for anti-DPA countermeasure.

What is implemented
-------------------

[x] AES without countermeasure

[ ] DES without countermeasure

[x] AES with Rivain-Prouff countermeasure

[ ] DES with Carlet et al. countermeasure, with the Parity-Split method for Sbox computation (requiring 10 non-linear multiplications), and the improved method from Roy-Vivek (requiring only 7 non-linear multiplications). The latter is used by default.

[x] AES with the new anti-DPA countermeasure based on table recomputation.

[ ] DES with the new anti-DPA countermeasure based on table recomputation.

Notes
----
* We have not protected the key-schedule. Therefore we assume that the block-cipher initially receives the shares of the subkeys, instead of the shares of the key. Moreover we have not implemented the refresh of the key between executions; therefore the implementation would be secure only in a restricted model in which always the same intermediate variables are probed. To get security in the full model one would need to refresh the subkeys between executions. 

* We do not claim that in practice the implementation would be secure against a t-th order attack. Namely the implementation is only provided for illustrative purpose, and timing comparisons. Obtaining a secure implementation would require to carefully examine the assembly code. In particular one should make sure that no two shares of the same variable are stored in the same register.


Outputs w/o optimization:
Shares=3
Htable method
in=3243f6a8885a308d313198a2e0370734
key=2b7e151628aed2a6abf7158809cf4f3c
out=3925841d02dc09fbdc118597196a0b32
n=3
  With randomized table : Checkpoint - ReportTime
out=3925841d02dc09fbdc118597196a0b32
SystemClock::Endless stopped
number of cpu cycles simulated: 110600469


After writing part of a function in assembly! :)
number of cpu cycles simulated: 110593589

After writing void share(byte x,byte a[],uint8_t n) from share.c in assembly
number of cpu cycles simulated: 110223221

After writing byte xorop(byte a[],uint8_t n) from share.c in assembly
number of cpu cycles simulated: 110223173

Fixed a bug in Xorshift random number generators variable size declaration which caused a huge performance issue
number of cpu cycles simulated: 34656381




