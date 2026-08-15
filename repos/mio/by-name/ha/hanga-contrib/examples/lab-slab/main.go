package main

import (
	"strings"

	"go.bytecodealliance.org/cm"
	"hanga.example/hangamod"
	"hanga.example/lab-slab/gen/hanga/engine/guest"
	"hanga.example/lab-slab/gen/hanga/engine/host"
)

var names = []string{"air", "slab", "mark"}

var busTopics = []string{
	"ping", "name", "catalog", "gravity", "has", "methods", "voxel", "fracture-kit", "loot-item",
}

func init() {
	guest.Exports.ABI = func() int32 { return 6 }
	guest.Exports.Ready = ready
	guest.Exports.VoxelCatalog = func() cm.List[string] { return cm.ToList(names) }
	guest.Exports.QueryVoxel = queryVoxel
	guest.Exports.Invoke = onMessage
}

func ready() {
	host.Log("info", "lab_slab ready")
	for _, peer := range host.Peers().Slice() {
		host.Send(peer, "hello", toHost(hangamod.EmptyVal()))
	}
}

func toHostCell(cell hangamod.ArenaCell) host.Cell {
	switch cell.Kind {
	case hangamod.WireFlag:
		return host.CellFlag(cell.Flag)
	case hangamod.WireInt:
		return host.CellInt(cell.Int)
	case hangamod.WireFloat:
		return host.CellFloat(cell.Float)
	case hangamod.WireText:
		return host.CellText(cell.Text)
	case hangamod.WireList:
		return host.CellItems(cm.ToList(cell.Items))
	case hangamod.WireBag:
		fields := make([]host.Field, 0, len(cell.Fields))
		for _, field := range cell.Fields {
			fields = append(fields, host.Field{Key: field.Key, At: field.At})
		}
		return host.CellDict(cm.ToList(fields))
	case hangamod.WireFail:
		return host.CellFail(cell.Text)
	default:
		return host.CellEmpty()
	}
}

func fromHostCell(cell host.Cell) hangamod.ArenaCell {
	if v := (&cell).Flag(); v != nil {
		return hangamod.ArenaCell{Kind: hangamod.WireFlag, Flag: *v}
	}
	if v := (&cell).Int(); v != nil {
		return hangamod.ArenaCell{Kind: hangamod.WireInt, Int: *v}
	}
	if v := (&cell).Float(); v != nil {
		return hangamod.ArenaCell{Kind: hangamod.WireFloat, Float: *v}
	}
	if v := (&cell).Text(); v != nil {
		return hangamod.ArenaCell{Kind: hangamod.WireText, Text: *v}
	}
	if v := (&cell).Items(); v != nil {
		return hangamod.ArenaCell{Kind: hangamod.WireList, Items: v.Slice()}
	}
	if v := (&cell).Dict(); v != nil {
		fields := make([]hangamod.ArenaField, 0, v.Len())
		for _, field := range v.Slice() {
			fields = append(fields, hangamod.ArenaField{Key: field.Key, At: field.At})
		}
		return hangamod.ArenaCell{Kind: hangamod.WireBag, Fields: fields}
	}
	if v := (&cell).Fail(); v != nil {
		return hangamod.ArenaCell{Kind: hangamod.WireFail, Text: *v}
	}
	return hangamod.ArenaCell{Kind: hangamod.WireEmpty}
}

func toHost(w hangamod.Wire) host.Value {
	arena := hangamod.Pack(w)
	cells := make([]host.Cell, len(arena.Cells))
	for i, cell := range arena.Cells {
		cells[i] = toHostCell(cell)
	}
	return host.Value{Cells: cm.ToList(cells), Root: arena.Root}
}

func fromHost(v host.Value) hangamod.Wire {
	slice := v.Cells.Slice()
	cells := make([]hangamod.ArenaCell, len(slice))
	for i, cell := range slice {
		cells[i] = fromHostCell(cell)
	}
	return hangamod.Unpack(hangamod.Arena{Cells: cells, Root: v.Root})
}

func gravity() hangamod.Wire {
	return hangamod.DictVal(
		hangamod.Field{Key: "kind", Value: hangamod.TextWire("down")},
		hangamod.Field{Key: "g", Value: hangamod.FloatVal(9.81)},
		hangamod.Field{Key: "jump", Value: hangamod.FloatVal(5)},
		hangamod.Field{Key: "walk", Value: hangamod.FloatVal(10)},
	)
}

func queryVoxel(x, y, z int32) int32 {
	return hangamod.CheckerFloor(x, y, z)
}

func onMessage(caller, topic string, payload host.Value) host.Value {
	return toHost(handle(caller, topic, fromHost(payload)))
}

func handle(caller, topic string, payload hangamod.Wire) hangamod.Wire {
	hangamod.Get(caller, "unused")
	switch topic {
	case "ping":
		return hangamod.TextWire("pong")
	case "name":
		return hangamod.TextWire("lab_slab")
	case "catalog":
		return hangamod.TextWire(strings.Join(names, ","))
	case "gravity":
		return gravity()
	case "has":
		return hangamod.FlagVal(hangamod.BusHas(payload, busTopics))
	case "methods":
		return methodsBag()
	case "voxel":
		x := int32(payload.BagInt("x"))
		y := int32(payload.BagInt("y"))
		z := int32(payload.BagInt("z"))
		return hangamod.TextWire(hangamod.CatalogName(names, int(queryVoxel(x, y, z))))
	case "fracture-kit":
		voxel, _ := payload.BagText("voxel")
		action, _ := payload.BagText("action")
		if action != "break" && action != "explode" {
			return hangamod.EmptyVal()
		}
		if voxel == "slab" || voxel == "mark" {
			return hangamod.DictVal(
				hangamod.Field{Key: "can", Value: hangamod.FlagVal(true)},
				hangamod.Field{Key: "spread", Value: hangamod.IntVal(1)},
				hangamod.Field{Key: "impulse", Value: hangamod.FloatVal(4)},
			)
		}
		return hangamod.EmptyVal()
	case "loot-item":
		voxel := payload.RootText()
		if voxel == "" {
			voxel, _ = payload.BagText("voxel")
		}
		if voxel == "mark" {
			return hangamod.TextWire("mark")
		}
		return hangamod.EmptyVal()
	default:
		return hangamod.EmptyVal()
	}
}

func methodsBag() hangamod.Wire {
	fields := make([]hangamod.Field, 0, len(busTopics))
	for _, topic := range busTopics {
		fields = append(fields, hangamod.Field{Key: topic, Value: hangamod.FlagVal(true)})
	}
	return hangamod.DictVal(fields...)
}

func main() {}
