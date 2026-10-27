package main

import (
	"bytes"
	"encoding/binary"
	"testing"

	"github.com/cilium/ebpf"
)

// These structures cross a C/Go ABI boundary. Check the compiled object's
// actual sizes so field edits cannot silently redirect unrelated connections.
func TestCompiledBPFABI(t *testing.T) {
	spec, e := ebpf.LoadCollectionSpecFromReader(bytes.NewReader(bpfObject))
	if e != nil {
		t.Fatal(e)
	}
	m := spec.Maps["connections"]
	if int(m.KeySize) != binary.Size(connectionKey{}) || int(m.ValueSize) != binary.Size(destination{}) {
		t.Fatalf("C/Go map ABI differs: key %d/%d value %d/%d", m.KeySize, binary.Size(connectionKey{}), m.ValueSize, binary.Size(destination{}))
	}
	d := destination{Family: 2, Port: 443}
	copy(d.Address[:], []byte{192, 0, 2, 1})
	a, e := d.addr()
	if e != nil || a.String() != "192.0.2.1:443" {
		t.Fatalf("IPv4 network byte order: %v, %v", a, e)
	}
}
