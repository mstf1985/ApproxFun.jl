using ApproxFun, Base.Test


x=Fun(identity);
@test sqrt(cos(π/2*x))(.1) ≈ sqrt(cos(.1π/2))


x=Fun(identity,-2..2)
u=sqrt(4-x^2)/(2π)


@test u(.1) ≈ sqrt(4-0.1^2)/(2π)
@test sum(u) ≈ 1

#this call threw an error, which we check
@test length(values(u))==1


f=Fun(x->x*cot(π*x/2))
x=Fun(identity)
u=Fun(JacobiWeight(1.,1.,Interval()),(f/(1-x^2)).coefficients)
@test 1/(0.1*cot(π*.1/2)) ≈ (1/u)(.1)

@test (x/u)(.1) ≈ tan(π*.1/2)


f=Fun(x->exp(-x^2),Line(0.,0.,-.5,-.5),400)
@test sum(f) ≈ sqrt(π)

f=Fun(x->exp(x)/sqrt(1-x.^2),JacobiWeight(-.5,-.5))
@test f(.1) ≈ (x->exp(x)/sqrt(1-x.^2))(.1)



S=JacobiWeight(-1.,-1.,Chebyshev(0..1))

# Checks bug in Derivative(S)
@test typeof(ConstantSpace(Domain(0..1))) <: Space{Segment{Float64},Float64}

D=Derivative(S)
f=Fun(S,Fun(exp,0..1).coefficients)
x=0.1
@test f(x) ≈ exp(x)*x^(-1)*(1-x)^(-1)/4
@test (D*f)(x) ≈ -exp(x)*(1+(x-3)*x)/(4*(x-1)^2*x^2)


S=JacobiWeight(-1.,0.,Chebyshev(0..1))
D=Derivative(S)

f=Fun(S,Fun(exp,0..1).coefficients)
x=.1
@test f(x) ≈ exp(x)*x^(-1)/2
@test (D*f)(x) ≈ exp(x)*(x-1)/(2x^2)



## ODEs

## f/g bugs

println("    Jacobi singularity tests")

x = Fun(identity)
f = exp(x)/(1-x.^2)

@test f(.1) ≈ exp(.1)/(1-.1^2)
f = exp(x)/(1-x.^2).^1
@test f(.1) ≈ exp(.1)/(1-.1^2)
f = exp(x)/(1-x.^2).^1.0
@test f(.1) ≈ exp(.1)/(1-.1^2)



## 1/f with poles

x=Fun(identity)
f=sin(10x)
g=1/f

@test g(.123) ≈ csc(10*.123)


println("    Ray tests")

## Ray

@test Inf in Ray()   # this was a bug

f=Fun(x->exp(-x),0..Inf)
@test f'(.1) ≈ -f(.1)

x=Fun(identity,Ray())
f=exp(-x)
u=integrate(f)
@test (u(1.)-u(0)-1) ≈ -f(1)

x=Fun(identity,Ray())
f=x^(-0.123)*exp(-x)
@test integrate(f)'(1.) ≈ f(1.)


@test ≈(sum(Fun(sech,0..Inf)),sum(Fun(sech,0..40));atol=1000000eps())


#Ei (Exp Integral)

y=Fun(Ray())
q=integrate(exp(-y)/y)
@test (q-last(q))(2.) ≈ (-0.04890051070806113)



## Line

f=Fun(x->exp(-x^2),Line())

@test f'(0.1) ≈ -2*0.1exp(-0.1^2)
@test (Derivative()*f)(0.1) ≈ -2*0.1exp(-0.1^2)




## PeriodicLine

d=PeriodicLine()
D=Derivative(d)
f=Fun(x->sech(x-.1),d)


@test ≈((D*f)(.2),-0.0991717226583897;atol=100000eps())
@test ≈((D^2*f)(.2),-0.9752522555114987;atol=1000000eps())



## LogWeight

x=Fun(identity,-1..1)
f=exp(x+1)-1
@test log(f)(0.1) ≈ log(f(0.1))


x=Fun(identity,0..1)
f=exp(x)-1
@test log(f)(0.1) ≈ log(f(0.1))


## Test divide sing

x=Fun(identity,0..1)
@test Fun(exp(x)/x-1/x,Chebyshev)(0.1) ≈ (exp(0.1)-1)/0.1

x=Fun(identity,0..1)
f=1/x
p=integrate(f)
@test (p-p(1.))(0.5) ≈ log(0.5)

f=1/(1-x)
p=integrate(f)
@test (p-p(0.))(0.5) ≈ -log(1-0.5)



y=Fun(Ray())
@test (y^2)(10.) ≈ y(10.)^2
@test 1/y(10.) ≈ (1/y)(10.)
@test (1/y^2)(10.) ≈ 1/y(10.)^2
@test (-1/y^2)'(10.) ≈ 2/(y(10.)^3)
@test exp(-1/y^2)(5.) ≈ exp(-1/y(5.)^2)



# catch bug from SIE

a=1+10*im;b=2-6*im
d=Curve(Fun(x->1+a*x+b*x^2))


x=Fun(d)
w=sqrt(abs(first(d)-x))*sqrt(abs(last(d)-x))

@test sum(w/(x-2.))/(2π*im) ≈ (-4.722196879007759+2.347910413861846im)
@test linesum(w*log(abs(x-2.)))/π ≈ (88.5579588360686)



## Dirac Space

a,b=DiracDelta(0.),DiracDelta(1.)
f=Fun(exp)
g=a+0.2b+f
@test components(g)[2](0.) ≈ 1.
@test g(.1) ≈ exp(.1)
@test sum(g) ≈ (sum(f)+1.2)


#Checks prevoius bug
δ=DiracDelta()
x=Fun()
w=sqrt(1-x^2)
w+δ


## PointSpace

f=Fun(x->(x-0.1),ApproxFun.PointSpace([0,0.1,1]))
@test roots(f) == [0.1]

a=Fun(exp,space(f))
@test f/a == Fun(x->(x-0.1)*exp(-x),space(f))

f = Fun(space(f),[1.,2.,3.])

g = f + Fun(2..3)
@test f(0.0) ≈ g(0.0) ≈ 1.0
@test f(0.1) ≈ g(0.1) ≈ 2.0
@test f(1.0) ≈ g(1.0) ≈ 3.0

@test g(2.3) ≈ 2.3


h = a + Fun(2..3)

# for some reason this test is broken only on Travis
@test_skip g/h ≈ f/a + Fun(1,2..3)







## multiplicities
x=Fun(identity,-1..1)
@test (1/x^2)(0.1) ≈ 100.
@test (1/x^2)(-0.1) ≈ 100.

fc=x*(1+x)^2
@test (1/fc)(0.1) ≈ 1/fc(0.1)

fc=x*(1-x)^2
@test (1/fc)(0.1) ≈ 1/fc(0.1)

## erf(sqrt(x))

x=Fun(0..1)
@test erf(sqrt(x))(0.1) ≈ erf(sqrt(0.1))
@test erfc(sqrt(x))(0.1) ≈ erfc(sqrt(0.1))


## norm(u-x)

@test norm(Fun(exp,Legendre(0..1))+sqrt(x)) ≈ 2.491141949903508



## Test Jacobi special conversions



S1,S2=JacobiWeight(3.,1.,Jacobi(1.,1.)),JacobiWeight(1.,1.,Jacobi(0.,1.))
f=Fun(S1,[1,2,3.])
C=Conversion(S1,S2)
Cf=C*f
@test Cf(0.1) ≈ f(0.1)


S1,S2=JacobiWeight(3.,2.,Jacobi(1.,1.)),JacobiWeight(1.,1.,Jacobi(0.,0.))
f=Fun(S1,[1,2,3.])
C=Conversion(S1,S2)
Cf=C*f
@test Cf(0.1) ≈ f(0.1)



## roots of log(abs(x-y))

x=Fun(-2..(-1))
@test roots(abs(x+1.2)) ≈ [-1.2]

f=abs(x+1.2)

@test norm(abs(f)-f)<10eps()
@test norm(sign(f)-Fun(1,space(f)))<10eps()


@test log(f)(-1.3) ≈ log(abs(-1.3+1.2))
@test log(f)(-1.1) ≈ log(abs(-1.1+1.2))


#393

x=Fun(0..1)
f = exp(x)*sqrt(x)*log(1-x)
@test f(0.1) ≈ exp(0.1)*sqrt(0.1)*log(1-0.1)
