package hanga.mod

internal fun checkKit() {
    val fields = Kit.fields("a=1;mystery=nope\nb=2")
    require(fields == listOf("a" to "1", "mystery" to "nope", "b" to "2"))
    require(Kit.flag("1"))
    require(!Kit.flag("0"))
    require(Kit.get("kind=none;jump=5", "kind") == "none")
    require(Kit.f32("walk=10", "walk", 0f) == 10f)
    val catalog = Catalog.parse("air, tile ,lamp")
    require(catalog == listOf("air", "tile", "lamp"))
    require(Catalog.name(catalog, 1) == "tile")
    require(Catalog.index(catalog, "lamp") == 2)
    val probe = Wire.voxelProbe("glass", true)
    require(probe.bagText("name") == "glass")
    require(probe.bagFlag("edit"))
}

fun main() {
    checkKit()
    println("hanga-mod kit ok")
}
