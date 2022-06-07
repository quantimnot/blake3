import std/[monotimes]

when defined data:
  import std/[random, syncio]
  const
    seed = 123
    bufSize = 4096
    iterations = 1_000_000
    totalSize = bufSize * iterations
  var buf: array[bufSize, uint64]
  var rand = initRand(seed)
  var file = open("data", fmWrite, bufSize)
  for _ in 1..iterations:
    for i in 0..bufSize-1:
      buf[i] = rand.next
    write file, buf
  quit 0

when defined sha1:
  import std/sha1
  echo "std/sha1"
else:
  import std_sha1_shim
  echo "shim"

let t0 = getMonoTime()

discard secureHashFile "data"

echo getMonoTime() - t0
echo getTotalMem()
echo getOccupiedMem()
