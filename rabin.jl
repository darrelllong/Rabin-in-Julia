#!/usr/bin/env julia

using Random

#=
a^b (mod n) using the method of repeated squares.

The key here is that every integer can be written as a sum of powers of 2 (binary numbers)
and that includes the exponent. By repeated squaring we get a raised to a power of 2. Also
recall that a^b * a^c = a^(b + c), so rather than adding we multiply since we are dealing
with the exponent.
=#

function powerMod(a, d, n)
    v = 1 # Value
    p = a # Powers of a
    while d > 0
        if isodd(d) # 1 bit in the exponent
           v = (v * p) % n
        end
        p = p^2 % n # Next power of two
        d >>>= 1
    end
    v
end

#=
Greatest common divisor, Euclidean version.
=#

function gcd(a, b)
    while b ≠ 0
        a, b = b, a % b
    end
    a
end

#=
Witness loop of the Miller-Rabin probabilistic primality test.
=#

function witness(a, n)
    u, t = n - 1, 0
    while iseven(u) # n = u * 2^t + 1
        t += 1   # Increase exponent
        u >>>= 1 # Decrease the multiplier
    end
    x = powerMod(a, u, n)
    for i in 1:t
        y = powerMod(x, 2, n)
        if y == 1 && x ≠ 1 && x ≠ n - 1
            return true
        end
        x = y
    end
    x ≠ 1
end

#=
Miller-Rabin probabilistic primality test: the chance of being wrong is ≈ 1/4 each pass through
the loop.
=#

function isPrime(n, k)
    if n < 2 || (n ≠ 2 && iseven(n)) # 0, 1, and even except for 2 are not prime.
        return false
    elseif n < 4 # 3 is prime
        return true
    end # We must test all others
    for j in 1:k
        a = rand(2:n - 2) # Choose a random witness
        if witness(a, n)
            return false
        end
    end
    true
end

#=
We need a random prime number in [low, high] and for now a 4^–100 chance of a composite is
good enough.
=#

function randomPrime(low, high)
    guess = 0 # Certainly not prime!
    while !isPrime(guess, 100)
        guess = rand(low:high) # Half will be even, the rest have Pr[prime] ≈ 1/log(N).
    end
    guess
end

#=
A safe prime is the one following a Sophie German prime. If prime(p) and prime(2p + 1) then
2p + 1 is a safe prime.
=#

function safePrime(low, high)
    p = randomPrime(low, high)
    while !isPrime(2 * p + 1,100)
        p = randomPrime(low, high)
    end
    return 2 * p + 1
end

# Rabin prime

function RabinPrime(safe, low, high)
    f = safe ? safePrime : randomPrime
    p = f(low, high)
    while p % 4 != 3
        p = f(low, high)
    end
    return p
end

# Euclidean extended greatest common divisor

function extendedGCD(a, b)
    (r, rP) = (a, b)
    (s, sP) = (1, 0)
    (t, tP) = (0, 1)
    while rP != 0
        q = r ÷ rP
        (r, rP) = (rP, r - q * rP)
        (s, sP) = (sP, s - q * sP)
        (t, tP) = (tP, t - q * tP)
        end
    return (r, (s, t))
end

#=
Add comment
=#

function key(safe, k)
    x = k + 40 # Make room for the tag
    p = RabinPrime(safe, big"2"^(x - 1), big"2"^x - 1)
    q = RabinPrime(safe, big"2"^(x - 1), big"2"^x - 1)
    while p == q
        q = RabinPrime(safe, big"2"^(x - 1), big"2"^x - 1)
    end
    return (p * q, (p, q))
end

#=
We need dicriminate amongst the four possible roots.
=#

#using CRC32c

#h::BigInt = crc32c("Michael O. Rabin")
h = BigInt(0x08051962)

#=
Add comment
=#

function encrypt(m, n)
println("m = ", digits(m, base=16), typeof(m))
println("h = ", digits(h, base=16), typeof(h))
    t = m << 40
println("t = ", digits(t, base=16), typeof(t))
println("t + h = ", digits(t + h, base=16), typeof(t))
println("(t + h) % 2^40) = ", digits((t + h) % 2^40, base=16), typeof(t))
    return powerMod(t + h, big"2", n) # Insert tag and square (mod n)
end

#=
Add comment
=#

function decrypt(m, key)
    (p, q) = key
    n = p * q
    (g, (yP, yQ)) = extendedGCD(p, q)
    mP = powerMod(m, (p + 1) ÷ 4, p)
    mQ = powerMod(m, (q + 1) ÷ 4, q)
    x = (yP * p * mQ + yQ * q * mP) % n
    y = (yP * p * mQ - yQ * q * mP) % n
    msgs = [x, n - x, y, n - y]
    for d in  msgs
        if d % 2^40 == h
            return d ÷ 2^40
        end
    end
for d in msgs
    println(typeof(d ÷ 2^40))
    println(decode(d ÷ 2^40))
end
    3873696748 # FAIL
end

function encode(s)
    sum::BigInt = 0
    pow::BigInt = 1
    for c in s
        sum += pow * BigInt(c)
        pow *= 256
    end
    BigInt(sum)
end

#=
Transform a BigInt back into a string, subtracting off the 0xAA. We treat it as a base-256
integer and just pull off the digits.
=#

function decode(n)
    s = ""
    while n > 0
        s = s * Char(n % 256)
        n ÷= 256
    end
    s
end

print("How many bits? ")

bits = parse(Int64, readline())

(n, k) = key(false, bits)

println("n = $n")
println("k = $k")

print(">> ")
for m in eachline()
    c = encrypt(encode(m), n); println("En[$m] = $c")
    t = decode(decrypt(c, k)); println("De[$c] = $t")
    print(">> ")
end
