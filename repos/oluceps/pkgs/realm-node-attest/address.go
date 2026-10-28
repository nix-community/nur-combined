package nodeattest

import "net/netip"

func validAddress(address netip.Addr) bool {
	if !address.IsValid() || address.Zone() != "" || address.Is4In6() || !address.IsGlobalUnicast() || address.IsLoopback() {
		return false
	}
	// Registry entries can use ULA or private LAN addresses on the trusted transport.
	if address.Is4() {
		first := address.As4()[0]
		return first != 0 && first < 224
	}
	return true
}
