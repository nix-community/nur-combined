package main

import (
	"bytes"
	_ "embed"
	"errors"
	"fmt"
	"net/netip"
	"os"

	"github.com/cilium/ebpf"
	"github.com/cilium/ebpf/link"
)

//go:embed bpf/realm_bpf.o
var bpfObject []byte

type connectionKey struct {
	Netns                              uint64
	Family, SourcePort, ProxyPort, Pad uint32
	Source                             [16]byte
}

type destination struct {
	Cookie, Created uint64
	Family, Port    uint32
	Address         [16]byte
}

func (d destination) addr() (netip.AddrPort, error) {
	var ip netip.Addr
	switch d.Family {
	case 2:
		ip = netip.AddrFrom4([4]byte(d.Address[:4]))
	case 10:
		ip = netip.AddrFrom16(d.Address).Unmap()
	default:
		return netip.AddrPort{}, fmt.Errorf("unknown address family %d", d.Family)
	}
	if d.Port == 0 || d.Port > 65535 {
		return netip.AddrPort{}, errors.New("invalid destination port")
	}
	return netip.AddrPortFrom(ip, uint16(d.Port)), nil
}

type capture struct {
	collection *ebpf.Collection
	links      []link.Link
}

func (c *capture) Close() {
	for i := len(c.links) - 1; i >= 0; i-- {
		_ = c.links[i].Close()
	}
	if c.collection != nil {
		c.collection.Close()
	}
}

func attachCapture(cgroup *os.File, tcpPort, dnsBase uint16) (*capture, error) {
	spec, err := ebpf.LoadCollectionSpecFromReader(bytes.NewReader(bpfObject))
	if err != nil {
		return nil, err
	}
	if err = spec.RewriteConstants(map[string]interface{}{"tcp_port": tcpPort, "dns_base": dnsBase}); err != nil {
		return nil, err
	}
	coll, err := ebpf.NewCollection(spec)
	if err != nil {
		return nil, fmt.Errorf("load BPF: %w", err)
	}
	c := &capture{collection: coll}
	ok := false
	defer func() {
		if !ok {
			c.Close()
		}
	}()
	hooks := []struct {
		name string
		kind ebpf.AttachType
	}{
		{"handle_sockops", ebpf.AttachCGroupSockOps},
		{"getpeer4", ebpf.AttachCgroupInet4GetPeername}, {"getpeer6", ebpf.AttachCgroupInet6GetPeername},
		{"recvmsg4", ebpf.AttachCGroupUDP4Recvmsg}, {"recvmsg6", ebpf.AttachCGroupUDP6Recvmsg},
		{"sendmsg4", ebpf.AttachCGroupUDP4Sendmsg}, {"sendmsg6", ebpf.AttachCGroupUDP6Sendmsg},
		{"connect4", ebpf.AttachCGroupInet4Connect}, {"connect6", ebpf.AttachCGroupInet6Connect},
	}
	for _, h := range hooks {
		l, e := link.AttachCgroup(link.CgroupOptions{Path: fmt.Sprintf("/proc/self/fd/%d", cgroup.Fd()), Attach: h.kind, Program: coll.Programs[h.name]})
		if e != nil {
			return nil, fmt.Errorf("attach %s: %w", h.name, e)
		}
		c.links = append(c.links, l)
	}
	ok = true
	return c, nil
}
