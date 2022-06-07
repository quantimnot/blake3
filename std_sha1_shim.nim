import std/strutils

import blake3

type
  SecureHash* = Blake3Hash

proc newSha1State*: Blake3 =
  init Blake3

proc update*(ctx: var Blake3, data: openArray[char]) =
  blake3.update ctx, data

proc finalize*(ctx: var Blake3): Blake3Hash =
  finalize ctx, result

proc secureHash*(str: openArray[char]): SecureHash =
  var ctx = init Blake3
  update ctx, str
  finalize ctx, Blake3Hash result

proc secureHashFile*(filename: string): SecureHash =
  const BufferLength = 8192

  let f = open(filename)
  var state = init Blake3
  var buffer = newString(BufferLength)
  while true:
    let length = readChars(f, buffer)
    if length == 0:
      break
    buffer.setLen(length)
    state.update(buffer)
    if length != BufferLength:
      break
  close(f)

  SecureHash(state.finalize())

proc `$`*(self: SecureHash): string =
  blake3.`$` self.Blake3Hash

proc parseSecureHash*(hash: string): SecureHash =
  SecureHash parse hash

proc `==`*(a, b: SecureHash): bool =
  Blake3Hash(a) == Blake3Hash(b)

proc isValidSha1Hash*(s: string): bool =
  s.len == defaultHexLen and allCharsInSet(s, HexDigits)
