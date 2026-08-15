package impl

import bindings.Guest
import bindings.Host
import hanga.mod.Catalog
import hanga.mod.Field
import hanga.mod.Kit
import hanga.mod.Wire

/**
 * Quiet tiled floor. Required WIT: abi, ready, catalog, query-voxel, invoke.
 * Gravity and kits are optional invoke methods (Godot virtuals).
 */
object GuestImpl : Guest {
    private val names = listOf("air", "tile", "lamp")
    private const val BUS_TOPICS = "ping,name,catalog,gravity,has,methods,voxel,fracture-kit,loot-item"

    override fun abi(): Int = 6

    override fun ready() {
        Host.Import.log("info", "lab_tile ready")
        for (peer in Host.Import.peers()) {
            Host.Import.send(peer, "hello", toHost(Wire.Empty))
        }
    }

    override fun voxelCatalog(): List<String> = names

    override fun queryVoxel(x: Int, y: Int, z: Int): Int =
        Catalog.checkerFloor(x, y, z)

    override fun invoke(caller: String, method: String, args: Host.Value): Host.Value {
        Kit.get(caller, "unused")
        val wire = fromHost(args)
        return toHost(
            when (method) {
                "ping" -> Wire.Text("pong")
                "name" -> Wire.Text("lab_tile")
                "catalog" -> Wire.Text(names.joinToString(","))
                "gravity" -> Wire.Bag(
                    listOf(
                        Field("kind", Wire.Text("down")),
                        Field("g", Wire.Float(9.81)),
                        Field("jump", Wire.Float(5.0)),
                        Field("walk", Wire.Float(10.0)),
                    ),
                )
                "has" -> Wire.Flag(busHas(wire))
                "methods" -> methodsBag()
                "voxel" -> {
                    val x = wire.bagInt("x").toInt()
                    val y = wire.bagInt("y").toInt()
                    val z = wire.bagInt("z").toInt()
                    Wire.Text(Catalog.name(names, queryVoxel(x, y, z)))
                }
                "fracture-kit" -> {
                    val voxel = wire.bagText("voxel").orEmpty()
                    val action = wire.bagText("action").orEmpty()
                    if (action != "break" && action != "explode") Wire.Empty
                    else if (voxel == "lamp" || voxel == "tile") Wire.Bag(
                        listOf(
                            Field("can", Wire.Flag(true)),
                            Field("spread", Wire.Int(1)),
                            Field("impulse", Wire.Float(4.0)),
                        ),
                    )
                    else Wire.Empty
                }
                "loot-item" -> {
                    val voxel = wire.asText() ?: wire.bagText("voxel").orEmpty()
                    if (voxel == "lamp") Wire.Text("lamp") else Wire.Empty
                }
                else -> Wire.Empty
            },
        )
    }

    private fun methodsBag(): Wire =
        Wire.Bag(BUS_TOPICS.split(',').map { Field(it.trim(), Wire.Flag(true)) })

    private fun busHas(args: Wire): Boolean {
        val name = args.asText() ?: args.bagText("name") ?: args.bagText("method") ?: ""
        return BUS_TOPICS.split(',').map { it.trim() }.contains(name)
    }

    private fun toHost(node: Wire): Host.Value {
        val cells = mutableListOf<Host.Cell>()
        fun add(value: Wire): UInt {
            when (value) {
                Wire.Empty -> cells.add(Host.Cell.Empty)
                is Wire.Flag -> cells.add(Host.Cell.Flag(value.value))
                is Wire.Int -> cells.add(Host.Cell.Int(value.value))
                is Wire.Float -> cells.add(Host.Cell.Float(value.value))
                is Wire.Text -> cells.add(Host.Cell.Text(value.value))
                is Wire.Items -> cells.add(Host.Cell.Items(value.items.map { add(it) }))
                is Wire.Bag -> cells.add(
                    Host.Cell.Dict(value.fields.map { Host.Field(it.key, add(it.value)) }),
                )
                is Wire.Fail -> cells.add(Host.Cell.Fail(value.reason))
            }
            return cells.lastIndex.toUInt()
        }
        return Host.Value(cells, add(node))
    }

    private fun fromHost(value: Host.Value): Wire {
        fun at(index: UInt): Wire {
            val cell = value.cells.getOrNull(index.toInt()) ?: return Wire.Empty
            return when (cell) {
                is Host.Cell.Empty -> Wire.Empty
                is Host.Cell.Flag -> Wire.Flag(cell.value)
                is Host.Cell.Int -> Wire.Int(cell.value)
                is Host.Cell.Float -> Wire.Float(cell.value)
                is Host.Cell.Text -> Wire.Text(cell.value)
                is Host.Cell.Items -> Wire.Items(cell.value.map { at(it) })
                is Host.Cell.Dict -> Wire.Bag(cell.value.map { Field(it.key, at(it.at)) })
                is Host.Cell.Fail -> Wire.Fail(cell.value)
            }
        }
        return at(value.root)
    }
}
