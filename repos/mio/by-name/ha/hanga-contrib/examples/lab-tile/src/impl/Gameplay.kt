package impl

import bindings.Gameplay
import bindings.Host
import bindings.runtime.Tuple4
import hanga.mod.Catalog
import hanga.mod.Kit

/**
 * Quiet tiled floor for trying a non-Rust pack. The host still only runs kits;
 * this file owns names, gravity, and the mod bus.
 */
object GameplayImpl : Gameplay {
    private const val CATALOG = "air,tile,lamp"
    private const val BUS_TOPICS = "ping,name,catalog,gravity,has,methods,voxel"

    override fun initMod() {
        Host.Import.log("info", "lab_tile ready")
    }

    override fun voxelCatalog(): String = CATALOG

    override fun queryVoxel(x: Int, y: Int, z: Int): Int {
        if (y < 0) return 1
        if (y == 0) return if (((x + z) and 1) == 0) 1 else 2
        return 0
    }

    override fun modGetActionRange(action: String): Float {
        Kit.get(action, "unused")
        return 20f
    }

    override fun modEvaluateAction(action: String, currentState: Int): Int {
        Kit.get(action, "unused")
        return currentState
    }

    override fun modShouldSpawnAgent(action: String, oldState: Int, newState: Int): String {
        Kit.get(action, "unused")
        Kit.flag(oldState.toString())
        Kit.flag(newState.toString())
        return ""
    }

    override fun steer(role: String, context: String): String {
        Kit.get(role, "unused")
        Kit.get(context, "blocked")
        return ""
    }

    override fun modGetStorytellerLevel(): Int = 0

    override fun generateStoryEvent(playerLevel: Int): String {
        Kit.flag(playerLevel.toString())
        return "void"
    }

    override fun modGetEconomyParams(): Int = (1 shl 16) or 1

    override fun computeEconomyPrice(base: Int, supply: Int, demand: Int): Int {
        if (supply == 0) return base
        return (base * demand / supply).coerceAtLeast(1)
    }

    override fun playerSpawn(): Triple<Int, Int, Int> = Triple(0, 4, 0)

    override fun vehicleSpawnCount(): Int = 0

    override fun vehicleSpawn(index: Int): Triple<Int, Int, Int> = Triple(index, 2, 0)

    override fun vehicleKit(index: Int): String {
        Kit.flag(index.toString())
        return ""
    }

    override fun gravity(): String = "kind=down;g=9.81;jump=5;walk=10"

    override fun fractureKit(voxel: String, action: String): String {
        if (action != "break" && action != "explode") return ""
        return if (voxel == "lamp" || voxel == "tile") "can=1;spread=1;impulse=4" else ""
    }

    override fun modTick(currentState: Int, dtMs: Int): Int {
        Kit.flag(dtMs.toString())
        return currentState
    }

    override fun shouldDespawnAgent(agent: String, currentState: Int): Int {
        Kit.get(agent, "unused")
        Kit.flag(currentState.toString())
        return 0
    }

    override fun ambientAgentCount(): Int = 0

    override fun ambientAgentSpawn(index: Int): Tuple4<Int, Int, Int, String> {
        Kit.flag(index.toString())
        return Tuple4(0, 0, 0, "")
    }

    override fun voxelLabel(voxel: String, locale: String): String {
        Kit.get(locale, "unused")
        return voxel
    }

    override fun modWalletAfter(action: String, currentWallet: Int, extra: Int): Int {
        Kit.get(action, "unused")
        return (currentWallet + extra).coerceIn(0, 1_000_000)
    }

    override fun modOfferContract(playerState: Int): Triple<String, Int, Int> {
        Kit.flag(playerState.toString())
        return Triple("", 0, 0)
    }

    override fun modCanComplete(
        action: String,
        playerState: Int,
        contractKind: String,
        contractDanger: Int,
        context: String,
    ): Int {
        Kit.get(action, "unused")
        Kit.get(contractKind, "unused")
        Kit.get(context, "held")
        Kit.flag(playerState.toString())
        Kit.flag(contractDanger.toString())
        return 0
    }

    override fun contractMark(kind: String): String {
        Kit.get(kind, "unused")
        return ""
    }

    override fun eventLabel(event: String, locale: String): String {
        Kit.get(locale, "unused")
        return event
    }

    override fun contractLabel(kind: String, locale: String): String {
        Kit.get(locale, "unused")
        return kind
    }

    override fun supportedLocales(): String = "en"

    override fun lootItem(voxel: String): String = if (voxel == "lamp") "lamp" else ""

    override fun itemLabel(item: String, locale: String): String {
        Kit.get(locale, "unused")
        return item
    }

    override fun craftResult(itemA: String, itemB: String): String {
        Catalog.parse("$itemA,$itemB")
        return ""
    }

    override fun crashKit(speed: Float, intoSolid: Boolean): String {
        Kit.f32("s=$speed", "s", 0f)
        Kit.flag(if (intoSolid) "1" else "0")
        return ""
    }

    override fun fireKit(ageMs: Int, nearby: String): String {
        Kit.flag(ageMs.toString())
        Kit.get(nearby, "unused")
        return ""
    }

    override fun onMessage(caller: String, topic: String, payload: Host.Payload): Host.Payload {
        Kit.get(caller, "unused")
        return when (topic) {
            "ping" -> Host.Payload.Text("pong")
            "name" -> Host.Payload.Text("lab_tile")
            "catalog" -> Host.Payload.Text(CATALOG)
            "gravity" -> Host.Payload.Text(gravity())
            "has" -> Host.Payload.Flag(busHas(payload))
            "methods" -> Host.Payload.Text(BUS_TOPICS)
            "voxel" -> {
                val x = bagInt(payload, "x").toInt()
                val y = bagInt(payload, "y").toInt()
                val z = bagInt(payload, "z").toInt()
                Host.Payload.Text(Catalog.name(Catalog.parse(CATALOG), queryVoxel(x, y, z)))
            }
            else -> Host.Payload.Empty
        }
    }

    private fun busHas(payload: Host.Payload): Boolean {
        val name = when (payload) {
            is Host.Payload.Text -> payload.value
            is Host.Payload.Bag ->
                payload.value.firstOrNull { it.key == "name" || it.key == "method" }?.let { field ->
                    (field.value as? Host.Atom.Text)?.value
                } ?: ""
            else -> ""
        }
        return BUS_TOPICS.split(',').map { it.trim() }.contains(name)
    }

    private fun bagInt(payload: Host.Payload, key: String): Long {
        val bag = payload as? Host.Payload.Bag ?: return 0
        val field = bag.value.firstOrNull { it.key == key } ?: return 0
        return when (val atom = field.value) {
            is Host.Atom.Int -> atom.value
            is Host.Atom.Text -> atom.value.toLongOrNull() ?: 0
            else -> 0
        }
    }
}
