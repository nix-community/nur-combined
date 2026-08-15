package hangamod

// Arena is the WIT cell list: children are indexes, not nested values.
type ArenaField struct {
	Key string
	At  uint32
}

type ArenaCell struct {
	Kind   WireKind
	Flag   bool
	Int    int64
	Float  float64
	Text   string
	Items  []uint32
	Fields []ArenaField
}

type Arena struct {
	Cells []ArenaCell
	Root  uint32
}

func EmptyVal() Wire { return Wire{Kind: WireEmpty} }
func FlagVal(v bool) Wire {
	return Wire{Kind: WireFlag, Flag: v}
}
func IntVal(v int64) Wire { return Wire{Kind: WireInt, Int: v} }
func FloatVal(v float64) Wire {
	return Wire{Kind: WireFloat, Float: v}
}
func DictVal(fields ...Field) Wire {
	return Wire{Kind: WireBag, Fields: fields}
}
func ListVal(items ...Wire) Wire {
	return Wire{Kind: WireList, Items: items}
}

func Pack(w Wire) Arena {
	var cells []ArenaCell
	root := appendWire(&cells, w)
	return Arena{Cells: cells, Root: root}
}

func appendWire(cells *[]ArenaCell, w Wire) uint32 {
	switch w.Kind {
	case WireList:
		idx := make([]uint32, len(w.Items))
		for i, item := range w.Items {
			idx[i] = appendWire(cells, item)
		}
		*cells = append(*cells, ArenaCell{Kind: WireList, Items: idx})
	case WireBag:
		fields := make([]ArenaField, len(w.Fields))
		for i, field := range w.Fields {
			fields[i] = ArenaField{Key: field.Key, At: appendWire(cells, field.Value)}
		}
		*cells = append(*cells, ArenaCell{Kind: WireBag, Fields: fields})
	default:
		*cells = append(*cells, ArenaCell{
			Kind:  w.Kind,
			Flag:  w.Flag,
			Int:   w.Int,
			Float: w.Float,
			Text:  w.Text,
		})
	}
	return uint32(len(*cells) - 1)
}

func Unpack(a Arena) Wire {
	if int(a.Root) >= len(a.Cells) {
		return EmptyVal()
	}
	return unpackCell(a, a.Root)
}

func unpackCell(a Arena, at uint32) Wire {
	if int(at) >= len(a.Cells) {
		return EmptyVal()
	}
	cell := a.Cells[at]
	switch cell.Kind {
	case WireList:
		items := make([]Wire, len(cell.Items))
		for i, child := range cell.Items {
			items[i] = unpackCell(a, child)
		}
		return Wire{Kind: WireList, Items: items}
	case WireBag:
		fields := make([]Field, len(cell.Fields))
		for i, field := range cell.Fields {
			fields[i] = Field{Key: field.Key, Value: unpackCell(a, field.At)}
		}
		return Wire{Kind: WireBag, Fields: fields}
	default:
		return Wire{
			Kind:  cell.Kind,
			Flag:  cell.Flag,
			Int:   cell.Int,
			Float: cell.Float,
			Text:  cell.Text,
		}
	}
}

func (w Wire) RootText() string {
	if w.Kind == WireText {
		return w.Text
	}
	return ""
}

func BusHas(w Wire, topics []string) bool {
	name := w.RootText()
	if name == "" {
		name, _ = w.BagText("name")
		if name == "" {
			name, _ = w.BagText("method")
		}
	}
	for _, topic := range topics {
		if topic == name {
			return true
		}
	}
	return false
}
