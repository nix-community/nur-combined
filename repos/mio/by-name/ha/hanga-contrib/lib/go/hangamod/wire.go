package hangamod

type WireKind uint8

const (
	WireEmpty WireKind = iota
	WireFlag
	WireInt
	WireFloat
	WireText
	WireList
	WireBag
	WireFail
)

type Field struct {
	Key   string
	Value Wire
}

// JSON-shaped payload: null, bool, number, string, array, object.
type Wire struct {
	Kind   WireKind
	Flag   bool
	Int    int64
	Float  float64
	Text   string
	Items  []Wire
	Fields []Field
}

func TextWire(value string) Wire {
	return Wire{Kind: WireText, Text: value}
}

func FailWire(reason string) Wire {
	return Wire{Kind: WireFail, Text: reason}
}

func VoxelProbe(name string, edit bool) Wire {
	return Wire{
		Kind: WireBag,
		Fields: []Field{
			{Key: "name", Value: Wire{Kind: WireText, Text: name}},
			{Key: "edit", Value: Wire{Kind: WireFlag, Flag: edit}},
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
		if field.Key == key && field.Value.Kind == WireText {
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
		case WireFlag:
			return field.Value.Flag
		case WireInt:
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
		case WireInt:
			return field.Value.Int
		case WireText:
			n, _ := parseInt64(field.Value.Text)
			return n
		}
	}
	return 0
}
