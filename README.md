# Rabin in Julia
A simple implementation of the Rabin cryptosystem in the Julia language.

Originally written for the students at the University of California, Santa Cruz.

```
@techreport{rabin1979digitalized,
  title={Digitalized signatures and public-key functions as intractable as factorization},
  author={Rabin, Michael O},
  year={1979},
  institution={Massachusetts Institute of Technology Cambridge Laboratory for Computer Science}
}
```

The implementation provides the ability to use *safe primes* for creating
the keys. This can be a little slow, but you do not need to do this more
than once.

```
@misc{cryptoeprint:2001:007,
    author       = {Ronald Rivest and Robert Silverman},
    title        = {Are 'Strong' Primes Needed for {RSA}?},
    howpublished = {Cryptology ePrint Archive, Report 2001/007},
    year         = {2001},
    note         = {\url{https://ia.cr/2001/007}},
}

```
# Usage

```
(n, k) = key(bits)

c = encrypt(encode("string"), n)

m = decode(decrypt(c, k))
```

Running it on the command line executes interactively to encrypt and decrypt strings.

```
dmz :: ~/Rabin-in-Julia » ./rabin.jl
How many bits? 128
n = 1333045194867734771455917735581060567393369506725227488408009988266942129770352532495264967766321
k = (1385228406081447448572337295088118247035206052423, 962328803694309706284890156512384392834019888327)
>> Hi, Buckaroos!
En[Hi, Buckaroos!] = 148418469319570449818525168245796609181204966597413929527230972688670842372793233702976
De[148418469319570449818525168245796609181204966597413929527230972688670842372793233702976] = Hi, Buckaroos!
>> ^D
```
