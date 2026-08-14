package main

import (
	"strconv"
	"strings"

	"go.bytecodealliance.org/cm"
	"hanga.example/hangamod"
	"hanga.example/lab-slab/gen/hanga/engine/gameplay"
	"hanga.example/lab-slab/gen/hanga/engine/host"
)

const catalog = "air,slab,mark"
const busTopics = "ping,name,catalog,gravity,has,methods,voxel"

func init() {
	gameplay.Exports.InitMod = func() { host.Log("info", "lab_slab ready") }
	gameplay.Exports.VoxelCatalog = func() string { return catalog }
	gameplay.Exports.QueryVoxel = queryVoxel
	gameplay.Exports.ModGetActionRange = func(action string) float32 {
		hangamod.Get(action, "unused")
		return 20
	}
	gameplay.Exports.ModEvaluateAction = func(_ string, state int32) int32 { return state }
	gameplay.Exports.ModShouldSpawnAgent = func(string, int32, int32) string { return "" }
	gameplay.Exports.Steer = func(_, context string) string {
		hangamod.Get(context, "blocked")
		return ""
	}
	gameplay.Exports.ModGetStorytellerLevel = func() int32 { return 0 }
	gameplay.Exports.GenerateStoryEvent = func(int32) string { return "void" }
	gameplay.Exports.ModGetEconomyParams = func() int32 { return (1 << 16) | 1 }
	gameplay.Exports.ComputeEconomyPrice = func(base, supply, demand int32) int32 {
		if supply == 0 {
			return base
		}
		n := base * demand / supply
		if n < 1 {
			return 1
		}
		return n
	}
	gameplay.Exports.PlayerSpawn = func() [3]int32 { return [3]int32{0, 4, 0} }
	gameplay.Exports.VehicleSpawnCount = func() int32 { return 0 }
	gameplay.Exports.VehicleSpawn = func(i int32) [3]int32 { return [3]int32{i, 2, 0} }
	gameplay.Exports.VehicleKit = func(int32) string { return "" }
	gameplay.Exports.Gravity = gravity
	gameplay.Exports.FractureKit = func(voxel, action string) string {
		if action != "break" && action != "explode" {
			return ""
		}
		if voxel == "slab" || voxel == "mark" {
			return "can=1;spread=1;impulse=4"
		}
		return ""
	}
	gameplay.Exports.ModTick = func(state, _ int32) int32 { return state }
	gameplay.Exports.ShouldDespawnAgent = func(string, int32) int32 { return 0 }
	gameplay.Exports.AmbientAgentCount = func() int32 { return 0 }
	gameplay.Exports.AmbientAgentSpawn = func(int32) cm.Tuple4[int32, int32, int32, string] {
		return cm.Tuple4[int32, int32, int32, string]{}
	}
	gameplay.Exports.VoxelLabel = func(voxel, _ string) string { return voxel }
	gameplay.Exports.ModWalletAfter = func(_ string, wallet, extra int32) int32 {
		n := wallet + extra
		if n < 0 {
			return 0
		}
		if n > 1_000_000 {
			return 1_000_000
		}
		return n
	}
	gameplay.Exports.ModOfferContract = func(int32) cm.Tuple3[string, int32, int32] {
		return cm.Tuple3[string, int32, int32]{}
	}
	gameplay.Exports.ModCanComplete = func(string, int32, string, int32, string) int32 { return 0 }
	gameplay.Exports.ContractMark = func(string) string { return "" }
	gameplay.Exports.EventLabel = func(event, _ string) string { return event }
	gameplay.Exports.ContractLabel = func(kind, _ string) string { return kind }
	gameplay.Exports.SupportedLocales = func() string { return "en" }
	gameplay.Exports.LootItem = func(voxel string) string {
		if voxel == "mark" {
			return "mark"
		}
		return ""
	}
	gameplay.Exports.ItemLabel = func(item, _ string) string { return item }
	gameplay.Exports.CraftResult = func(a, b string) string {
		hangamod.ParseCatalog(a + "," + b)
		return ""
	}
	gameplay.Exports.CrashKit = func(speed float32, intoSolid bool) string {
		hangamod.F32("s="+formatF32(speed), "s", 0)
		if intoSolid {
			hangamod.Flag("1")
		}
		return ""
	}
	gameplay.Exports.FireKit = func(int32, string) string { return "" }
	gameplay.Exports.OnMessage = onMessage
}

func gravity() string { return "kind=down;g=9.81;jump=5;walk=10" }

func queryVoxel(x, y, z int32) int32 {
	if y < 0 {
		return 1
	}
	if y == 0 {
		if (x+z)&1 == 0 {
			return 1
		}
		return 2
	}
	return 0
}

func onMessage(caller, topic string, payload host.Payload) host.Payload {
	hangamod.Get(caller, "unused")
	switch topic {
	case "ping":
		return host.PayloadText("pong")
	case "name":
		return host.PayloadText("lab_slab")
	case "catalog":
		return host.PayloadText(catalog)
	case "gravity":
		return host.PayloadText(gravity())
	case "has":
		return host.PayloadFlag(busHas(payload))
	case "methods":
		return host.PayloadText(busTopics)
	case "voxel":
		x := int32(bagInt(payload, "x"))
		y := int32(bagInt(payload, "y"))
		z := int32(bagInt(payload, "z"))
		names := hangamod.ParseCatalog(catalog)
		return host.PayloadText(hangamod.CatalogName(names, int(queryVoxel(x, y, z))))
	default:
		return host.PayloadEmpty()
	}
}

func busHas(payload host.Payload) bool {
	name := ""
	if text := payload.Text(); text != nil {
		name = *text
	} else if bag := payload.Bag(); bag != nil {
		for _, field := range bag.Slice() {
			if field.Key == "name" || field.Key == "method" {
				if text := field.Value.Text(); text != nil {
					name = *text
				}
			}
		}
	}
	for _, method := range strings.Split(busTopics, ",") {
		if strings.TrimSpace(method) == name {
			return true
		}
	}
	return false
}

func bagInt(payload host.Payload, key string) int64 {
	bag := payload.Bag()
	if bag == nil {
		return 0
	}
	for _, field := range bag.Slice() {
		if field.Key != key {
			continue
		}
		if n := field.Value.Int(); n != nil {
			return *n
		}
		if text := field.Value.Text(); text != nil {
			v, _ := strconv.ParseInt(*text, 10, 64)
			return v
		}
	}
	return 0
}

func formatF32(value float32) string {
	return strconv.FormatFloat(float64(value), 'f', -1, 32)
}

func main() {}
