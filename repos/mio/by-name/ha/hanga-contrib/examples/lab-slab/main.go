package main

import (
	"strconv"
	"strings"

	"go.bytecodealliance.org/cm"
	"hanga.example/hangamod"
	"hanga.example/lab-slab/gen/hanga/engine/guest"
	"hanga.example/lab-slab/gen/hanga/engine/host"
)

var names = []string{"air", "slab", "mark"}

const busTopics = "ping,name,catalog,gravity,has,methods,voxel,fracture-kit,loot-item"

func init() {
	guest.Exports.ABI = func() int32 { return 6 }
	guest.Exports.Ready = func() { host.Log("info", "lab_slab ready") }
	guest.Exports.VoxelCatalog = func() cm.List[string] { return cm.ToList(names) }
	guest.Exports.QueryVoxel = queryVoxel
	guest.Exports.Invoke = onMessage
}

func shiftCell(cell host.Cell, base uint32) host.Cell {
	if items := (&cell).Items(); items != nil {
		idx := make([]uint32, 0, items.Len())
		for _, at := range items.Slice() {
			idx = append(idx, at+base)
		}
		return host.CellItems(cm.ToList(idx))
	}
	if bag := (&cell).Dict(); bag != nil {
		fields := make([]host.Field, 0, bag.Len())
		for _, field := range bag.Slice() {
			fields = append(fields, host.Field{Key: field.Key, At: field.At + base})
		}
		return host.CellDict(cm.ToList(fields))
	}
	return cell
}

func appendValue(cells []host.Cell, child host.Value) ([]host.Cell, uint32) {
	base := uint32(len(cells))
	for _, cell := range child.Cells.Slice() {
		cells = append(cells, shiftCell(cell, base))
	}
	return cells, base + child.Root
}

func valLeaf(cell host.Cell) host.Value {
	return host.Value{Cells: cm.ToList([]host.Cell{cell}), Root: 0}
}

func valText(s string) host.Value { return valLeaf(host.CellText(s)) }
func valFlag(v bool) host.Value   { return valLeaf(host.CellFlag(v)) }
func valInt(v int64) host.Value   { return valLeaf(host.CellInt(v)) }
func valFloat(v float64) host.Value {
	return valLeaf(host.CellFloat(v))
}
func valEmpty() host.Value { return valLeaf(host.CellEmpty()) }

func valDict(pairs [][2]any) host.Value {
	cells := make([]host.Cell, 0)
	fields := make([]host.Field, 0, len(pairs))
	for _, pair := range pairs {
		key := pair[0].(string)
		child := pair[1].(host.Value)
		var at uint32
		cells, at = appendValue(cells, child)
		fields = append(fields, host.Field{Key: key, At: at})
	}
	root := uint32(len(cells))
	cells = append(cells, host.CellDict(cm.ToList(fields)))
	return host.Value{Cells: cm.ToList(cells), Root: root}
}

func rootCell(v host.Value) host.Cell {
	slice := v.Cells.Slice()
	if int(v.Root) >= len(slice) {
		return host.CellEmpty()
	}
	return slice[v.Root]
}

func gravity() host.Value {
	return valDict([][2]any{
		{"kind", valText("down")},
		{"g", valFloat(9.81)},
		{"jump", valFloat(5)},
		{"walk", valFloat(10)},
	})
}

func queryVoxel(x, y, z int32) int32 {
	if y < 0 {
		return 2
	}
	if y == 0 {
		if (x+z)&1 == 0 {
			return 2
		}
		return 2
	}
	return 0
}

func onMessage(caller, topic string, payload host.Value) host.Value {
	hangamod.Get(caller, "unused")
	switch topic {
	case "ping":
		return valText("pong")
	case "name":
		return valText("lab_slab")
	case "catalog":
		return valText(strings.Join(names, ","))
	case "gravity":
		return gravity()
	case "has":
		return valFlag(busHas(payload))
	case "methods":
		return methodsBag()
	case "voxel":
		x := int32(bagInt(payload, "x"))
		y := int32(bagInt(payload, "y"))
		z := int32(bagInt(payload, "z"))
		return valText(hangamod.CatalogName(names, int(queryVoxel(x, y, z))))
	case "fracture-kit":
		voxel := bagText(payload, "voxel")
		action := bagText(payload, "action")
		if action != "break" && action != "explode" {
			return valEmpty()
		}
		if voxel == "slab" || voxel == "mark" {
			return valDict([][2]any{
				{"can", valFlag(true)},
				{"spread", valInt(1)},
				{"impulse", valFloat(4)},
			})
		}
		return valEmpty()
	case "loot-item":
		voxel := payloadText(payload)
		if voxel == "" {
			voxel = bagText(payload, "voxel")
		}
		if voxel == "mark" {
			return valText("mark")
		}
		return valEmpty()
	default:
		return valEmpty()
	}
}

func methodsBag() host.Value {
	pairs := make([][2]any, 0)
	for _, topic := range strings.Split(busTopics, ",") {
		topic = strings.TrimSpace(topic)
		if topic == "" {
			continue
		}
		pairs = append(pairs, [2]any{topic, valFlag(true)})
	}
	return valDict(pairs)
}

func busHas(payload host.Value) bool {
	name := payloadText(payload)
	if name == "" {
		name = bagText(payload, "name")
		if name == "" {
			name = bagText(payload, "method")
		}
	}
	for _, method := range strings.Split(busTopics, ",") {
		if strings.TrimSpace(method) == name {
			return true
		}
	}
	return false
}

func payloadText(payload host.Value) string {
	cell := rootCell(payload)
	if text := (&cell).Text(); text != nil {
		return *text
	}
	return ""
}

func bagText(payload host.Value, key string) string {
	root := rootCell(payload)
	bag := (&root).Dict()
	if bag == nil {
		return ""
	}
	cells := payload.Cells.Slice()
	for _, field := range bag.Slice() {
		if field.Key != key || int(field.At) >= len(cells) {
			continue
		}
		child := cells[field.At]
		if text := (&child).Text(); text != nil {
			return *text
		}
	}
	return ""
}

func bagInt(payload host.Value, key string) int64 {
	root := rootCell(payload)
	bag := (&root).Dict()
	if bag == nil {
		return 0
	}
	cells := payload.Cells.Slice()
	for _, field := range bag.Slice() {
		if field.Key != key || int(field.At) >= len(cells) {
			continue
		}
		child := cells[field.At]
		if n := (&child).Int(); n != nil {
			return *n
		}
		if text := (&child).Text(); text != nil {
			v, _ := strconv.ParseInt(*text, 10, 64)
			return v
		}
	}
	return 0
}

func main() {}
