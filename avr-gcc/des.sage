# Generation of the lagrange interpolation polynomials, and the Roy-Vivek polynomials for DES

S=[14,0,4,15,13,7,1,4,2,14,15,2,11,13,8,1,3,10,10,6,6,12,12,11,5,9,9,5,0,3,7,8,4,15,1,12,14,8,8,2,13,4,6,9,2,1,11,7,15,5,12,11,9,3,7,14,3,10,10,0,5,6,0,13,
15,3,1,13,8,4,14,7,6,15,11,2,3,8,4,14,9,12,7,0,2,1,13,10,12,6,0,9,5,11,10,5,0,13,14,8,7,10,11,1,10,3,4,15,13,4,1,2,5,11,8,6,12,7,6,12,9,0,3,5,2,14,15,9,
10,13,0,7,9,0,14,9,6,3,3,4,15,6,5,10,1,2,13,8,12,5,7,14,11,12,4,11,2,15,8,1,13,1,6,10,4,13,9,0,8,6,15,9,3,8,0,7,11,4,1,15,2,14,12,3,5,11,10,5,14,2,7,12,
7,13,13,8,14,11,3,5,0,6,6,15,9,0,10,3,1,4,2,7,8,2,5,12,11,1,12,10,4,14,15,9,10,3,6,15,9,0,0,6,12,10,11,1,7,13,13,8,15,9,1,4,3,5,14,11,5,12,2,7,8,2,4,14,
2,14,12,11,4,2,1,12,7,4,10,7,11,13,6,1,8,5,5,0,3,15,15,10,13,3,0,9,14,8,9,6,4,11,2,8,1,12,11,7,10,1,13,14,7,2,8,13,15,6,9,15,12,0,5,9,6,10,3,4,0,5,14,3,
12,10,1,15,10,4,15,2,9,7,2,12,6,9,8,5,0,6,13,1,3,13,4,14,14,0,7,11,5,3,11,8,9,4,14,3,15,2,5,12,2,9,8,5,12,15,3,10,7,11,0,14,4,1,10,7,1,6,13,0,11,8,6,13,
4,13,11,0,2,11,14,7,15,4,0,9,8,1,13,10,3,14,12,3,9,5,7,12,5,2,10,15,6,8,1,6,1,6,4,11,11,13,13,8,12,1,3,4,7,10,14,7,10,9,15,5,6,0,8,15,0,14,5,2,9,3,2,12,
13,1,2,15,8,13,4,8,6,10,15,3,11,7,1,4,10,12,9,5,3,6,14,11,5,0,0,14,12,9,7,2,7,2,11,1,4,14,1,7,9,4,12,10,14,8,2,13,0,15,6,12,10,9,13,0,15,3,3,5,5,6,8,11]


def toGF64(x,t):
  r=0
  for i in range(6):
    if mod(x,2)==1: 
      r=r+t^i
    x=x >> 1
  return r

def fromGF64(x):
  v=x._vector_()
  return sum([2^i for i in range(6) if v[i]==1])

def listCoef(p,n):
  li=[fromGF64(u) for u in p.list()]
  if len(li)<n:
    li=li+[0 for j in range(n-len(li))]
  return li

def test():
  F=GF(2^6,'t')
  print "Modulus=",F.modulus()

  li=[]
  for isbox in range(8):
    R.<x>=PolynomialRing(F,'x')
    t=list(enumerate(F))[1][1]
    f=R.lagrange_polynomial([(toGF64(i,t),toGF64(S[i],t)) for i in range(isbox*64,isbox*64+64)])
    #print ",".join([str(fromGF64(x)) for x in f.list()])+","
    q,R=f.quo_rem(x^36)
    c,s=(R-x^27).quo_rem(q)
    q1,R1=q.quo_rem(x^18)
    c1,s1=(R1-x^9).quo_rem(q1)
    q2,R2=(x^27+s).quo_rem(x^18)
    c2,s2=(R2-x^9).quo_rem(q2)

    s1=s1+x^9
    s2=s2+x^9

    print f==(x^36+c)*((x^18+c1)*q1+s1)+(x^18+c2)*q2+s2
    
    for p in c,c1,q1,s1,c2,q2,s2:
      li.extend(listCoef(p,10))
    print [fromGF64(u(0)) for u in c,c1,q1,s1,c2,q2,s2]
    print fromGF64(f(0))
    print fromGF64(c1(0),q1(0))
    return
  print li
  print len(li)
  