module hanga.example/lab-slab

go 1.23.0

require (
	go.bytecodealliance.org/cm v0.3.0
	hanga.example/hangamod v0.0.0
)

replace hanga.example/hangamod => ../../lib/go/hangamod
