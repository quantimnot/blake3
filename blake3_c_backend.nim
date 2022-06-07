## FFI to the reference C implementation.

{.styleChecks: off.}

import std/[macros, os]

proc relPath(n: string): NimNode =
  newStrLitNode currentSourcePath().splitFile.dir / "refimpl" / "c" / n

macro header(n): untyped =
  let path = relPath n.strVal
  quote do:
    {.push header: `path`.}

macro compile(n): untyped =
  let path = relPath n.strVal
  quote do:
    {.compile: `path`.}

compile "blake3.c"
compile "blake3_dispatch.c"
compile "blake3_portable.c"

when defined blake3SSE2:
  compile "blake3_sse2_x86-64_unix.S"
else:
  {.passc: "-DBLAKE3_NO_SSE2".}

when defined blake3SSE41:
  compile "blake3_sse41_x86-64_unix.S"
else:
  {.passc: "-DBLAKE3_NO_SSE41".}

when defined blake3AVX2:
  compile "blake3_avx2_x86-64_unix.S"
else:
  {.passc: "-DBLAKE3_NO_AVX2".}

when defined blake3AVX512:
  compile "blake3_avx512_x86-64_unix.S"
else:
  {.passc: "-DBLAKE3_NO_AVX512".}

header "blake3.h"

type
  blake3_hasher {.importc, pure.} = object

proc blake3_hasher_init(self: ptr blake3_hasher) {.importc.}

proc blake3_hasher_update(
  self: ptr blake3_hasher,
  input: pointer,
  input_len: csize_t) {.importc.}

proc blake3_hasher_finalize(
  self: ptr blake3_hasher,
  `out`: pointer,
  out_len: csize_t) {.importc.}

type Blake3Impl* = object
  impl: blake3_hasher

# proc init(ctx: var Blake3Impl) =
  # blake3_hasher_init(addr Blake3C(ctx).impl)
template initInplaceImpl* =
  # var tmp = blake3_hasher()
  # let input = "test"
  # var output = newString(32)
  # blake3_hasher_init(addr tmp)
  # blake3_hasher_update(addr tmp, addr input[0], csize_t input.len)
  # blake3_hasher_finalize(addr tmp, cast[pointer](addr output[0]), csize_t 32)
  # echo output
  blake3_hasher_init(addr ctx.impl)
  # ctx.impl = move(tmp)

# proc init(t {.used.}: typedesc[Blake3Impl]): Blake3Impl =
template initTypeImpl* =
  init cast[var Blake3](result)

# # proc update(ctx: var Blake3Impl, input: openArray[byte]) =
template updateImpl* =
  blake3_hasher_update(addr ctx.impl, addr input[0], csize_t input.len)

# # proc finalize(ctx: Blake3Impl, output: var openArray[byte]) =
template finalizeImpl* =
  blake3_hasher_finalize(addr ctx.impl, addr output[0], csize_t defaultOutputLen)
