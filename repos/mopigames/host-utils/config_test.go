package main

import "testing"

func TestNormaliseToken(t *testing.T) {
	canonical := "S95G234X0H8AK602"
	// Everything someone might plausibly type from a television screen.
	for _, typed := range []string{
		"S95G234X0H8AK602",
		"S95G-234X-0H8A-K602",
		"s95g-234x-0h8a-k602",
		" S95G 234X 0H8A K602 ",
		"S95G–234X–0H8A–K602", // en dashes, from a copy-paste
	} {
		if got := NormaliseToken(typed); got != canonical {
			t.Errorf("NormaliseToken(%q) = %q, want %q", typed, got, canonical)
		}
	}
}

func TestNormaliseTokenDropsAmbiguous(t *testing.T) {
	// I, L, O and U are not in the alphabet, so a code can never contain
	// them -- and someone typing "O" for "0" gets a wrong code rather than
	// a silently different one.  This pins that they are dropped rather
	// than mapped, which would let two distinct codes collide.
	if got := NormaliseToken("OIL"); got != "" {
		t.Errorf("want ambiguous letters dropped, got %q", got)
	}
}

func TestNewTokenShape(t *testing.T) {
	seen := map[string]bool{}
	for i := 0; i < 100; i++ {
		tok, err := newToken()
		if err != nil {
			t.Fatal(err)
		}
		if len(tok) != 16 {
			t.Fatalf("want 16 characters, got %d (%q)", len(tok), tok)
		}
		if NormaliseToken(tok) != tok {
			t.Fatalf("a generated token must already be canonical: %q", tok)
		}
		if seen[tok] {
			t.Fatalf("newToken repeated %q within 100 draws", tok)
		}
		seen[tok] = true
	}
}

func TestFormatToken(t *testing.T) {
	if got := FormatToken("S95G234X0H8AK602"); got != "S95G-234X-0H8A-K602" {
		t.Errorf("got %q", got)
	}
	// Round trip, because the printed form is what gets typed back in.
	if got := NormaliseToken(FormatToken("S95G234X0H8AK602")); got != "S95G234X0H8AK602" {
		t.Errorf("round trip broke: %q", got)
	}
}
