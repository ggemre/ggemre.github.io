#import "template.typ": *

#show: project.with(
  title: "Primality Test",
  authors: (
    "Gage Moore",
  ),
  date: "September 16, 2023",
)

= Analysis
This program calculates if a given number is prime or composite using two algorithms: Fermat's test and Miller-Rabin's test. It accepts N, the number to test for primality, and K, the number of rounds to use when testing. It returns N's classification, and if N is classified as prime the probability that this is accurate.

#image("Screen Shot 2023-09-16 at 12.21.18 PM.png")

== Modular Exponentiation
The following function is used to calculate modular exponentiation, ($x^y mod N$):

```py
def mod_exp(x, y, N):
    if y == 0:
        return 1
    z = mod_exp(x, y//2, N) 
    if y % 2 == 0:
        return (z**2) % N
    else:
        return (x * (z**2)) % N
```

The time complexity of `mod_exp()` is $O(log y)$.

The function uses a recursive approach for the calculation, with each nested call y is split in half with floor division, which is a single bit shift right, while x and N remain the same. The conditionals within the function return solely based on the value of y, so the time complexity only depends on the number of times that y can be bit shifted.

== Fermat's Test
The following function uses Fermat's theorem to determine if N is prime after k rounds:

```py
def run_fermat(N,k):
    for _ in range(k):
        a = random.randint(2,N-1)
        if mod_exp(a,N-1,N) != 1:
            return 'composite'
    return 'prime'
```

The loop is bounded by `k` and runs in $O(k)$ time. Each iteration generates a random number, ($O(1)$), calls `mod_exp()`, ($O(log N-1)$), and returns based on what that returns, ($O(1)$). Therefore, the time complexity of the entire function is $O(k log N)$.

== Miller-Rabin's Test
The following function uses the Miller-Rabin Theorem to determine if N is prime after k rounds:

```py
def run_miller_rabin(N,k):
    if N <= 1:
        return 'composite'
    if N <= 3:
        return 'prime'
    
    r, d = 0, N - 1
    while d % 2 == 0:
        r += 1
        d //= 2
    
    for _ in range(k):
        a = random.randint(2, N - 2)
        x = mod_exp(a, d, N)
        
        if x == 1 or x == N - 1:
            continue
        
        for _ in range(r - 1):
            x = mod_exp(x, 2, N)
            if x == N - 1:
                break
        else:
            return 'composite'
    
    return 'prime'
```

To calculate `r` and `d`, the function uses a loop that breaks when d becomes odd. The maximum number of iterations it can take is $O(log N)$ because `d`, (which is set to `N-1`), can split in half by floor division that number of times.

The next segment follows sequentially with a loop bounded by `k` containing a call to `mod_exp()` which runs in $O(log d)$. It enters into an inner loop bounded by `r-1`. That loop calls `mod_exp()` which runs in $O(1)$ due to the constant 2. As a result, because of the relation between `N` and `d` and the sequence of loops, the functions runs in $O(k (log N)^2)$.

== Probability Calculations

The probability that Fermat's Theorem resulted in a false positive is $(1/2)^k$. The probability that the Miller-Rabin Theorem resulted in a false positive is $(1/4)^k$. The following calculations determine the probability that each test correctly identified a prime number:

```py
def fprobability(k):
    return 1 - (1/2)**k

def mprobability(k):
    return 1 - (1/4)**k
```

Each function runs in constant time, $O(1)$, because while the exponent, `k`, is variable, the base is constant.

== The Prime Test Entry Function

This program contains an entry function that calls both `run_fermat()` and `run_miller_rabin()` with the same values for `N` and `k`. For large values of `k`, `run_fermat()` serves as a lower bound for `run_miller_rabin()`, therefore, $"run_miller_rabin()" = Omega("run_fermat()")$. As a result, the entire function runs in $O(k (log N)^2)$ time.

```py
def prime_test(N, k):
    return run_fermat(N,k), run_miller_rabin(N,k)
```

= Code

The entire code for the program from this writeup is included below:

```py
import random


'''
Entry function for the primality tests.
It runs in O(k (log N)^2) time.
'''
def prime_test(N, k):
    return run_fermat(N,k), run_miller_rabin(N,k)


'''
Modular exponentiation, calculates x^y mod N.
It runs in O(log y) time.
'''
def mod_exp(x, y, N):
    if y == 0:
        return 1
    z = mod_exp(x, y//2, N) 
    if y % 2 == 0:
        return (z**2) % N
    else:
        return (x * (z**2)) % N
    

'''
The probability that Fermat's test is correct.
It runs in O(1) time.
'''
def fprobability(k):
    return 1 - (1/2)**k


'''
The probability that Miller-Rabin's test is correct.
It runs in O(1) time.
'''
def mprobability(k):
    return 1 - (1/4)**k


'''
Fermat's test for primality.
It runs in O(k log N) time.
'''
def run_fermat(N,k):
    for _ in range(k):
        a = random.randint(2,N-1)
        if mod_exp(a,N-1,N) != 1:
            return 'composite'
    return 'prime'



'''
Miller-Rabin's test for primality.
It runs in O(k (log N)^2) time.
'''
def run_miller_rabin(N,k):
    if N <= 1:
        return 'composite'
    if N <= 3:
        return 'prime'
    
    r, d = 0, N - 1
    while d % 2 == 0:
        r += 1
        d //= 2
    
    for _ in range(k):
        a = random.randint(2, N - 2)
        x = mod_exp(a, d, N)
        
        if x == 1 or x == N - 1:
            continue
        
        for _ in range(r - 1):
            x = mod_exp(x, 2, N)
            if x == N - 1:
                break
        else:
            return 'composite'
    
    return 'prime'
```
