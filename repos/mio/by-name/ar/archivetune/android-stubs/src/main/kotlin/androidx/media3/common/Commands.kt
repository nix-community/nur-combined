package androidx.media3.common

/*
 * Command bit set exposed as Player.availableCommands. Upstream queries it with
 * `player.availableCommands.contains(Player.COMMAND_CHANGE_MEDIA_ITEMS)`.
 */
class Commands {
    fun contains(command: Int): Boolean = true

    fun containsAny(vararg commands: Int): Boolean = true

    fun size(): Int = 0

    fun isEmpty(): Boolean = false
}
