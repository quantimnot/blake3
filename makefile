.POSIX:
.SUFFIXES:
.SUFFIXES: .log .exe
.exe.log:
	@{ \time -l ./$(<); } 2>&1 > $(@)

logs = 	bench_sha1_refc.log \
				bench_sha1_arc.log \
				bench_shim_arc.log \
				bench_shim_refc.log \
				bench_shim_sse2_arc.log \
				bench_shim_sse2_refc.log \
				bench_shim_sse41_arc.log \
				bench_shim_sse41_refc.log

$(logs): data

data:
	nim r -d:data -d:danger bench.nim

bench_sha1_refc.exe: bench.nim
	nim c --out:$(@) --mm:refc -d:danger -d:sha1 bench.nim

bench_sha1_arc.exe: bench.nim
	nim c --out:$(@) --mm:arc -d:danger -d:sha1 bench.nim

bench_shim_refc.exe: bench.nim
	nim c --out:$(@) --mm:refc -d:danger -d:shim bench.nim

bench_shim_arc.exe: bench.nim
	nim c --out:$(@) --mm:arc -d:danger -d:shim bench.nim

bench_shim_sse2_refc.exe: bench.nim
	nim c --out:$(@) --mm:refc -d:danger -d:shim -d:blake3SSE2 bench.nim

bench_shim_sse2_arc.exe: bench.nim
	nim c --out:$(@) --mm:arc -d:danger -d:shim -d:blake3SSE2 bench.nim

bench_shim_sse41_refc.exe: bench.nim
	nim c --out:$(@) --mm:refc -d:danger -d:shim -d:blake3SS41 bench.nim

bench_shim_sse41_arc.exe: bench.nim
	nim c --out:$(@) --mm:arc -d:danger -d:shim -d:blake3SS41 bench.nim

.PHONEY: FORCE
FORCE:

.PHONEY: clean
clean:
	git clean -x
