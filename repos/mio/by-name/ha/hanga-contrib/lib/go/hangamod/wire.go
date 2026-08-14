package hangamod

type AtomKind uint8

const (
	AtomFlag AtomKind = iota
	AtomInt
	AtomFloat
	AtomText
)

type Atom struct {
	Kind  AtomKind
	Flag  bool
	Int   int64
	Float float64
	Text  string
}

type Field struct {
	Key   string
	Value Atom
}

type WireKind uint8

const (
	WireEmpty WireKind = iota
	WireFlag
	WireInt
	WireFloat
	WireText
	WireBag
)

type Wire struct {
	Kind   WireKind
	Flag   bool
	Int    int64
	Float  float64
	Text   string
	Fields []Field
}

func TextWire(value string) Wire {
	return Wire{Kind: WireText, Text: value}
}

func VoxelProbe(name string, edit bool) Wire {
	return Wire{
		Kind: WireBag,
		Fields: []Field{
			{Key: "name", Value: Atom{Kind: AtomText, Text: name}},
			{Key: "edit", Value: Atom{Kind: AtomFlag, Flag: edit}},
		},
	}
}

func (w Wire) AsText() (string, bool) {
	if w.Kind != WireText {
		return "", false
	}
	return w.Text, true
}

func (w Wire) BagText(key string) (string, bool) {
	if w.Kind != WireBag {
		return "", false
	}
	for _, field := range w.Fields {
		if field.Key == key && field.Value.Kind == AtomText {
			return field.Value.Text, true
		}
	}
	return "", false
}

func (w Wire) BagFlag(key string) bool {
	if w.Kind != WireBag {
		return false
	}
	for _, field := range w.Fields {
		if field.Key != key {
			continue
		}
		switch field.Value.Kind {
		case AtomFlag:
			return field.Value.Flag
		case AtomInt:
			return field.Value.Int == 1
		}
	}
	return false
}

func (w Wire) BagInt(key string) int64 {
	if w.Kind != WireBag {
		return 0
	}
	for _, field := range w.Fields {
		if field.Key != key {
			continue
		}
		switch field.Value.Kind {
		case AtomInt:
			return field.Value.Int
		case AtomText:
			n, _ := parseInt64(field.Value.Text)
			return n
		}
	}
	return 0
}
