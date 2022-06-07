## Blake3 cryptographic hashing routines

{.define(blake3CBackend).}

import blake3_types

when defined blake3CBackend:
  import blake3_c_backend
elif defined blake3RustBackend:
  import blake3_rust_backend
else:
  import blake3_nim_backend

const
  defaultHexLen* = 64 # 32 bytes * 2 hexdigits per a byte

type
  Blake3* = Blake3Impl
  Blake3Hash* = array[32, byte]

# iterator items(hash: Blake3Hash): byte =
#   for b in array[32, byte]](hash):
#     yield b

func toHex(byt: byte, result: var openArray[char]) {.inline.} =
  const hexChars = "0123456789abcdef"
  result[0] = hexChars[int(byt shr 4 and 0x0f'u8)]
  result[1] = hexChars[int(byt and 0x0f'u8)]

func toHex*(hash: Blake3Hash): string =
  result = newString defaultHexLen
  for i, byt in hash:
    toHex byt, toOpenArray(result, i * 2, i * 2 + 1)

func `$`*(hash: Blake3Hash): string =
  toHex hash

# func `==`*(a, b: Blake3Hash): bool =
#   cast[array[32, byte]](a) == cast[array[32, byte]](b)

proc init*(ctx: var Blake3) =
  initInplaceImpl

proc init*(t: typedesc[Blake3]): Blake3 =
  result = t()
  init result

proc update*(ctx: var Blake3, input: openArray[char]) =
  updateImpl

proc update*(ctx: var Blake3, input: openArray[byte]) =
  update ctx, cast[string](input)

proc finalize*(ctx: Blake3, output: var openArray[byte]) =
  finalizeImpl

func readHexByte(byt: openArray[char]): byte {.raises: [ValueError, Defect], inline.} =
  case byt[0]
  of '0'..'9': result = byte(ord(byt[0]) - ord('0')) shl 4
  of 'a'..'f': result = byte(ord(byt[0]) - ord('a') + 10) shl 4
  of 'A'..'F': result = byte(ord(byt[0]) - ord('A') + 10) shl 4
  else:
    raise newException(ValueError, "'" & $byt[0] & "' is not a hexadecimal character")
  case byt[1]
  of '0'..'9': result = result or byte(ord(byt[1]) - ord('0'))
  of 'a'..'f': result = result or byte(ord(byt[1]) - ord('a') + 10)
  of 'A'..'F': result = result or byte(ord(byt[1]) - ord('A') + 10)
  else:
    raise newException(ValueError, "'" & $byt[1] & "' is not a hexadecimal character")

func parse*(input: openArray[char]): Blake3Hash {.raises: [ValueError, Defect].} =
  for i in 0..31:
    result[i] = readHexByte(toOpenArray[char](input, i * 2, i * 2 + 1))

# when defined blake3CBackend:
#   include blake3_c_backend
# elif defined blake3RustBackend:
#   include blake3_rust_backend
# else:
#   {.error: "[blake3] Nim backend hasn't been implemented yet.".}
#   include blake3_nim_backend

when isMainModule and defined test:
  import std/unittest
  
  test "basic operations":
    var ctx = init Blake3
    var output: array[32, byte]
    update ctx, "test"
    finalize ctx, output
    let s = $cast[Blake3Hash](output)
    check $parse(s) == s
