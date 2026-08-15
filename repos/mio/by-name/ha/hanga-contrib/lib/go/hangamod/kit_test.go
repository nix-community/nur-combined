package hangamod

import "testing"

func TestKit(t *testing.T) {
	fields := Fields("a=1;mystery=nope\nb=2")
	if len(fields) != 3 || fields[0] != [2]string{"a", "1"} || fields[2] != [2]string{"b", "2"} {
		t.Fatalf("fields: %#v", fields)
	}
	if !Flag("1") || Flag("0") {
		t.Fatal("flag")
	}
	if v, ok := Get("kind=none;jump=5", "kind"); !ok || v != "none" {
		t.Fatal("get")
	}
	if F32("walk=10", "walk", 0) != 10 {
		t.Fatal("f32")
	}
	catalog := ParseCatalog("air, tile ,lamp")
	if len(catalog) != 3 || CatalogName(catalog, 1) != "tile" || CatalogIndex(catalog, "lamp") != 2 {
		t.Fatalf("catalog: %#v", catalog)
	}
	probe := VoxelProbe("glass", true)
	if text, ok := probe.BagText("name"); !ok || text != "glass" || !probe.BagFlag("edit") {
		t.Fatal("wire probe")
	}
	nested := Wire{
		Kind: WireBag,
		Fields: []Field{{
			Key: "parts",
			Value: Wire{
				Kind: WireList,
				Items: []Wire{{
					Kind:   WireBag,
					Fields: []Field{{Key: "name", Value: Wire{Kind: WireText, Text: "hull"}}},
				}},
			},
		}},
	}
	if name, ok := nested.Fields[0].Value.Items[0].BagText("name"); !ok || name != "hull" {
		t.Fatal("nested list of objects")
	}
	fail := FailWire("busy")
	if fail.Kind != WireFail || fail.Text != "busy" {
		t.Fatal("fail wire")
	}
	packed := Pack(nested)
	if packed.Root != 3 || len(packed.Cells) != 4 {
		t.Fatalf("pack: %#v", packed)
	}
	if name, ok := Unpack(packed).Fields[0].Value.Items[0].BagText("name"); !ok || name != "hull" {
		t.Fatal("unpack nested")
	}
	if !BusHas(TextWire("ping"), []string{"ping", "name"}) || BusHas(EmptyVal(), []string{"ping"}) {
		t.Fatal("bus has")
	}
	if CheckerFloor(0, -1, 0) != 2 || CheckerFloor(0, 0, 0) != 1 || CheckerFloor(1, 0, 0) != 2 || CheckerFloor(0, 1, 0) != 0 {
		t.Fatal("checker floor")
	}
	failArena := Pack(FailWire("busy"))
	if Unpack(failArena).Kind != WireFail || Unpack(failArena).Text != "busy" {
		t.Fatal("pack fail")
	}
}
