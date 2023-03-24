## Install drivers

1. Went into `3rdparty/linux-x86_64/` and ran `make`
2. Copied the libftd3xx.so in '/usr/lib/libftd3xx.so'

Changed l20 into
`_libname = '/usr/lib/libftd3xx.so'` 

## Rules

Copied rules too
`sudo cp 51-ftd3xx.rules /lib/udev/rules.d/`

then

`sudo udevadm control --reload-rules `

and

`sudo udevadm trigger`

## Python check

Then explored the `20230313.ipynb` to check if FT worked.

```
{'bytesTransferred': 4096,
 'bytes': b'\x01\x08\x02\x08\x03\x08\x04\x08\x05\x08\x06\x08\x07\x08\x08\x08\t\x08\n\x08\x0b\x08\x0c\x08\r\x08\x0e\x08\x0f\x08\x10\x08\x11\x08\x12\x08\x13\x08\x14\x08\x15\x08\x16\x08\x17\x08\x18\x08\x19\x08\x1a\x08\x1b\x08\x1c\x08\x1d\x08\x1e\x08\x1f\x08 \x08!\x08"\x08#\x08$\x08%\x08&\x08\'\x08(\x08)\x08*\x08+\x08,\x08-\x08.\x08/\x080\x081\x082\x083\x084\x085\x086\x087\x088\x089\x08:\x08;\x08<\x08=\x08>\x08?\x08@\x08A\x08B\x08C\x08D\x08E\x08F\x08G\x08H\x08I\x08J\x08K\x08L\x08M\x08N\x08O\x08P\x08Q\x08R\x08S\x08T\x08U\x08V\x08W\x08X\x08Y\x08Z\x08[\x08\\\x08]\x08^\x08_\x08`\x08a\x08b\x08c\x08d\x08e\x08f\x08g\x08h\x08i\x08j\x08k\x08l\x08m\x08n\x08o\x08p\x08q\x08r\x08s\x08t\x08u\x08v\x08w\x08x\x08y\x08z\x08{\x08|\x08}\x08~\x08\x7f\x08\x80\x08\x81\x08\x82\x08\x83\x08\x84\x08\x85\x08\x86\x08\x87\x08\x88\x08\x89\x08\x8a\x08\x8b\x08\x8c\x08\x8d\x08\x8e\x08\x8f\x08\x90\x08\x91\x08\x92\x08\x93\x08\x94\x08\x95\x08\x96\x08\x97\x08\x98\x08\x99\x08\x9a\x08\x9b\x08\x9c\x08\x9d\x08\x9e\x08\x9f\x08\xa0\x08\xa1\x08\xa2\x08\xa3\x08\xa4\x08\xa5\x08\xa6\x08\xa7\x08\xa8\x08\xa9\x08\xaa\x08\xab\x08\xac\x08\xad\x08\xae\x08\xaf\x08\xb0\x08\xb1\x08\xb2\x08\xb3\x08\xb4\x08\xb5\x08\xb6\x08\xb7\x08\xb8\x08\xb9\x08\xba\x08\xbb\x08\xbc\x08\xbd\x08\xbe\x08\xbf\x08\xc0\x08\xc1\x08\xc2\x08\xc3\x08\xc4\x08\xc5\x08\xc6\x08\xc7\x08\xc8\x08\xc9\x08\xca\x08\xcb\x08\xcc\x08\xcd\x08\xce\x08\xcf\x08\xd0\x08\xd1\x08\xd2\x08\xd3\x08\xd4\x08\xd5\x08\xd6\x08\xd7\x08\xd8\x08\xd9\x08\xda\x08\xdb\x08\xdc\x08\xdd\x08\xde\x08\xdf\x08\xe0\x08\xe1\x08\xe2\x08\xe3\x08\xe4\x08\xe5\x08\xe6\x08\xe7\x08\xe8\x08\xe9\x08\xea\x08\xeb\x08\xec\x08\xed\x08\xee\x08\xef\x08\xf0\x08\xf1\x08\xf2\x08\xf3\x08\xf4\x08\xf5\x08\xf6\x08\xf7\x08\xf8\x08\xf9\x08\xfa\x08\xfb\x08\xfc\x08\xfd\x08\xfe\x08\xff\x08'}
 ```