## chocolatey

https://community.chocolatey.org/packages/Kindle#versionhistory

https://packages.chocolatey.org/Kindle.1.0.0.0.nupkg

```
Kindle.1.0.0.0.nupkg
Kindle.1.11.2.nupkg
Kindle.1.12.2.40996.nupkg
Kindle.1.14.43019.nupkg
Kindle.1.15.43061.nupkg
Kindle.1.17.nupkg
Kindle.1.20.nupkg
Kindle.1.21.48017.nupkg
Kindle.1.23.50133.nupkg
Kindle.1.24.51068.nupkg
Kindle.1.25.52064.nupkg
Kindle.1.28.57030.nupkg
Kindle.1.29.58059.nupkg
Kindle.1.30.59056.nupkg
Kindle.1.31.60170.nupkg
Kindle.1.32.61109.nupkg
Kindle.1.33.62002.nupkg
Kindle.1.34.63103.nupkg
Kindle.1.35.64251.nupkg
Kindle.1.36.65107.nupkg
Kindle.1.37.65274.nupkg
Kindle.1.38.65290.nupkg
Kindle.1.39.65306.nupkg
Kindle.1.39.65323.nupkg
Kindle.1.39.65383.nupkg
Kindle.1.40.65415.nupkg
Kindle.1.40.65535.nupkg
```

```
for f in *.nupkg; do n=${f%.*}; echo $n; [ -d $n ] && continue; mkdir $n; cd $n; 7z -y x ../$f; cd ..; done

grep -r -e "^  -Checksum" -e "^  -Url" -e "^  url " -e "^  checksum " Kindle.1.*/* -h
```

```
  -Url 'http://kindleforpc.amazon.com/40996/KindleForPC-installer-1.12.40996.exe'

  -Url 'http://kindleforpc.amazon.com/43019/KindleForPC-installer-1.14.43019.exe' `
  -Checksum 'd92901bb2d62535922017bbd0f2b2378'

  -Url 'https://s3.amazonaws.com/kindleforpc/43061/KindleForPC-installer-1.15.43061.exe' `
  -Checksum 'a40840ae89a771892732e96685c22096'

  -Url 'https://s3.amazonaws.com/kindleforpc/44183/KindleForPC-installer-1.17.44183.exe' `
  -Checksum 'C3861198D6A18BF1EEF6F6970705F7F57B5FF152B733ABBADAADD4D1BFF4BE17' `
  -ChecksumType 'SHA256'

  -Url 'https://s3.amazonaws.com/kindleforpc/47037/KindleForPC-installer-1.20.47037.exe' `
  -Checksum 'CB20581D3455D458C7AC4BAFA5C67DCFC5186C7B35951168EFCF5A8263706B47' `
  -ChecksumType 'SHA256'

  -Url 'https://s3.amazonaws.com/kindleforpc/48017/KindleForPC-installer-1.21.48017.exe' `
  -Checksum 'A6EA9068FABCDFDE6DA3099FA242C19BEDE3E393F2C6D3CB24C859A5F4281AE7' `
  -ChecksumType 'SHA256'

  -Url 'https://s3.amazonaws.com/kindleforpc/50133/KindleForPC-installer-1.23.50133.exe' `
  -Checksum 'B66F5F4F8A68965A6D04AA41C97816A043517A24E19CFF943B804F1A1363CF08' `
  -ChecksumType 'SHA256'

  -Url 'https://s3.amazonaws.com/kindleforpc/51068/KindleForPC-installer-1.24.51068.exe' `
  -Checksum 'C7A1A93763D102BCA0FED9C16799789AE18C3322B1B3BDFBE8C00422C32F83D7' `
  -ChecksumType 'SHA256'

  -Url 'https://s3.amazonaws.com/kindleforpc/52064/KindleForPC-installer-1.25.52064.exe' `
  -Checksum '314678A0A3B867BF412936ADAA67C6AB6D41C961F359A46F99C3AFA591702EF7' `
  -ChecksumType 'SHA256'
```

## web archive

https://archive.org/search?query=title%3A%28kindle+for+pc%29+

https://archive.org/details/kindle-for-pc-1-17-44170

https://archive.org/details/kindle-for-pc-installer-1.17.44183

https://archive.org/details/kindle-for-pc-installer-1.21.48017

KindleForPC-installer-1.24.51068.exe
https://community.chocolatey.org/packages/Kindle/1.24.51068
https://s3.amazonaws.com/kindleforpc/51068/KindleForPC-installer-1.24.51068.exe # http 403
C7A1A93763D102BCA0FED9C16799789AE18C3322B1B3BDFBE8C00422C32F83D7

https://archive.org/details/kindle-for-pc-installer-1.28.57030

https://archive.org/details/kindle-for-pc-installer-1.28.57030_202212

https://archive.org/details/kindle-for-pc-1-32-61109

KindleForPC-installer-1.34.63103.exe
https://archive.org/details/kindle-for-pc-installer-1.34.63103
https://www.fileeagle.com/download/software/file/12801/047458/

https://archive.org/details/kindle-for-pc-installer-1.36.65107

https://archive.org/details/kindle-for-pc-installer-1.39.65306

## mobileread

https://www.mobileread.com/forums/showthread.php?t=283371

```
version 1.17/1.17.1
filename: KindleForPC-installer-1.17.44170.exe
SHA-256: 14e0f0053f1276c0c7c446892dc170344f707fbfe99b6951762c120144163200

filename: KindleForMac-44182.dmg
SHA-256: 28dc21246a9c7cdedd2d6f0f4082e6bf7ef9db9ce9d485548e8a9e1d19eae2ac

version 1.24
filename: KindleForPC-installer-1.24.51068.exe
SHA-256: c7a1a93763d102bca0fed9c16799789ae18c3322b1b3bdfbe8c00422c32f83d7

version 1.26
filename: KindleForPC-installer-1.26.55076.exe
SHA-256: c9d104c4aad027a89ab92a521b7d64bdee422136cf562f8879f0af96abd74511

filename: KindleForMac-55093.dmg
SHA-256: 580957ca56b1e77b7952f41970836481f37ada3071eaee3552265069b89ef757

version 1.28
filename: KindleForPC-installer-1.28.57030.exe
SHA-256: 6feea6ec44ff3d3b7be23e7a969fe14ab884a7b19e23bc2c74237730411559f6

filename: KindleForMac-57029.dmg
SHA-256: b4de86ba1b78966c754d220fe09fd7dbdbadd874b19e51d261d8308e6e0d4cb3

version 1.34.1
filename: KindleForPC-installer-1.34.63103.exe
SHA-256: 3dc62b3895954fc171d4a3d08f2b7a1a503233e373c163adb7bc7fd34cdeff49
```

## calibre-dedrm-docker-image

https://github.com/vace117/calibre-dedrm-docker-image/tree/master/resources/windows

KindleForPC-installer-1.17.44170.exe

## kindle error: unable to connect

problem: missing SSL certificate /etc/ssl/certs/facacbc6.0

see also https://bugs.winehq.org/show_bug.cgi?id=50471

```sh
WINEDEBUG=+file,+ntdll,+tid ./result/bin/kindle >wine.log 2>&1
cat wine.log | grep '/facacbc6.0"' | cut -d'"' -f2 | grep -v \\\\unix/ | sort | uniq | sed 's|//|/|g'
```

```
/etc/openssl/certs/facacbc6.0
/etc/ssl/certs/facacbc6.0           # least selective
/opt/openssl/certs/facacbc6.0
/usr/lib/ssl/certs/facacbc6.0
/usr/local/ssl/certs/facacbc6.0
/usr/local/ssl/facacbc6.0
/usr/share/ssl/facacbc6.0
/var/certmgr/web/user_trusted/facacbc6.0           # most selective?
/var/ssl/certs/facacbc6.0
```

```sh
grep -r var/certmgr/web/user_trusted /nix/store/ 2>&1 | grep -v ': Permission denied$'
```

```
/etc/ssl/certs/
/usr/lib/ssl/certs/
/usr/share/ssl/
/usr/local/ssl/
/var/ssl/certs/
/usr/local/ssl/certs/
/var/certmgr/web/user_trusted/
/etc/openssl/certs/
/opt/openssl/certs/
```

these folder paths are defined in
result/opt/kindle/Qt5Network.dll

```
ideal: certs path in nixos -> not selective in /nix/store
/etc/ssl/certs/facacbc6.0

good?
/usr/local/ssl/certs/facacbc6.0
/var/ssl/certs/facacbc6.0
```

what did not work ...

```sh
if false; then
  # fix: unable to connect https://bugs.winehq.org/show_bug.cgi?id=50471
  echo patching path to SSL certificates in Qt5Network.dll
  cd $out/opt/kindle
  md5sum Qt5Network.dll
  echo patching instructions in Qt5Network.dll
  mv Qt5Network.dll Qt5Network.dll.bak
  bspatch Qt5Network.dll.bak Qt5Network.dll ${./Qt5Network.dll.93de86bd72cce2645ecd50d32038c142.bspatch}
  rm Qt5Network.dll.bak
  md5sum Qt5Network.dll
  echo patching strings in Qt5Network.dll
  a="/etc/ssl/certs/ /usr/lib/ssl/certs/ /usr/share/ssl/ /usr/local/ssl/ /var/ssl/certs/ /usr/local/ssl/certs/ "
  b="/etc/ssl/certs/ /nix/store/00000000000000000000000000000000-kindle-0.00.00000/etc/ssl/certs/ /var/empty/" # example
  b="/etc/ssl/certs/ $out/etc/ssl/certs/ /var/empty/"
  a="''${a:0:''${#b}}"
  echo "a: '$a'"
  echo "b: '$b'"
  a=$(echo "$a" | sed 's/ /\\x00/g')
  b=$(echo "$b" | sed 's/ /\\x00/g')
  mv Qt5Network.dll Qt5Network.dll.bak
  bbe -e "s|$a|$b|" Qt5Network.dll.bak >Qt5Network.dll
  md5sum Qt5Network.dll
  mkdir -p $out/etc/ssl/certs
  cp -v ${ssl-cert-facacbc6} $out/etc/ssl/certs/facacbc6.0
fi

if false; then
  echo patching path to SSL certificates in Qt5Network.dll
  cd $out/opt/kindle
  mv Qt5Network.dll Qt5Network.dll.bak
  bbe -e 's|\x00/var/ssl/certs/\x00|\x00/tmp/ssl/certs/\x00|' Qt5Network.dll.bak >Qt5Network.dll
  rm Qt5Network.dll.bak
fi

# FIXME kindle is still crashing on start
# maybe it has an integrity check for Qt5Network.dll
# https://security.stackexchange.com/questions/181388/do-software-do-an-integrity-check-before-executing
# https://security.stackexchange.com/questions/86492/how-can-i-ensure-my-dll-has-not-been-modified
```

### patching instructions in Qt5Network.dll

what did not work:
replace 0x640fee8a (add string 1) with a jmp to 0x640feee5 (add string 8)

what did not work:
set string length to zero for unused strings

```asm
0x640fee84      mov     esi, dword [public: void __thiscall QByteArray::constructor(char const *, int)] ; 0x6410f264

; add string 1
0x640fee8a      lea     ecx, [esp] ; string length 0
0x640fee8d      nop
0x640fee8e      push    0xffffffffffffffff
0x640fee90      push    str.opt_openssl_certs ; 0x6411ebf8
0x640fee95      call    esi

; add string 2
0x640fee97      push    0xffffffffffffffff
0x640fee99      push    str.etc_openssl_certs ; 0x6411ebe4
0x640fee9e      lea     ecx, [esp] ; string length 0
0x640feea1      nop
0x640feea2      call    esi

; add string 3
0x640feea4      push    0xffffffffffffffff
0x640feea6      push    str.var_certmgr_web_user_trusted ; 0x6411ebc4
0x640feeab      lea     ecx, [esp] ; string length 0
0x640feeae      nop
0x640feeaf      call    esi

; add string 4
0x640feeb1      push    0xffffffffffffffff
0x640feeb3      push    0x6411ebac
0x640feeb8      lea     ecx, [esp] ; string length 0
0x640feebb      nop
0x640feebc      call    esi

; add string 5
0x640feebe      push    0xffffffffffffffff
0x640feec0      push    str.var_ssl_certs ; 0x6411eb9c
0x640feec5      lea     ecx, [esp] ; string length 0
0x640feec8      nop
0x640feec9      call    esi

; add string 6
0x640feecb      push    0xffffffffffffffff
0x640feecd      push    0x6411eb8c
0x640feed2      lea     ecx, [esp] ; string length 0
0x640feed5      nop
0x640feed6      call    esi

; add string 7
0x640feed8      push    0xffffffffffffffff
0x640feeda      push    str.usr_share_ssl ; 0x6411eb7c
0x640feedf      lea     ecx, [esp] ; string length 0
0x640feee2      nop
0x640feee3      call    esi

; add string 8
0x640feee5      push    0xffffffffffffffff
0x640feee7      push    str.usr_lib_ssl_certs ; 0x6411eb68 ; patch string to
; "/nix/store/00000000000000000000000000000000-kindle-0.00.00000/etc/ssl/certs/"
0x640feeec      lea     ecx, [esp + 0x4d] ; string length: 0x4d = 77 (including null byte)
0x640feef0      call    esi

; add string 9
0x640feef2      push    0xffffffffffffffff
0x640feef4      push    str.etc_ssl_certs ; 0x6411eb58 ; keep string "/etc/ssl/certs/"
0x640feef9      lea     ecx, [var_10h] ; length 0x10 = 16 (including null byte)
0x640feefd      call    esi

0x640feeff      mov     eax, dword [public: static struct QListData::Data const QListData::shared_null] ; 0x6410f258
0x640fef04      mov     esi, dword [public: void * * __thiscall QListData::append(void)] ; 0x6410fd10
```
