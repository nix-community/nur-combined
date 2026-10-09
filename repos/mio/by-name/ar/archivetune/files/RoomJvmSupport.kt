// JVM support shims for Room's Kotlin Multiplatform runtime.
//
// Room's KSP code generator picks its "Android" code shape when `android.content.Context` is
// resolvable on the processing classpath (which it is here, because :app depends on
// org.robolectric:android-all). That shape calls two helpers that only exist in the *Android*
// runtime artifact (androidx.room:room-runtime-android), not in the JVM one
// (androidx.room:room-runtime-jvm):
//
//   * androidx.room.util.performBlocking      - runs a non-suspending DAO function
//   * androidx.room.util.recursiveFetchArrayMap - @Transaction relations returning an ArrayMap
//
// Providing JVM implementations here lets the generated DAO compile and run against the real
// KMP runtime + BundledSQLiteDriver without converting the 150+ blocking DAO functions upstream
// ships to `suspend` (which Room KMP otherwise requires on non-Android targets).
//
// NOTE: do NOT annotate this file with @file:JvmName("DBUtil") / ("RelationUtil"). Those names are
// the runtime's own multi-file class facades; a same-named class in the app would shadow them and
// break every other DBUtil/RelationUtil entry point (NoSuchMethodError at runtime).

package androidx.room.util

import androidx.collection.ArrayMap
import androidx.room.RoomDatabase
import androidx.sqlite.SQLiteConnection
import kotlinx.coroutines.runBlocking

/** Blocking version of [performSuspending]. Mirrors the Android runtime implementation. */
public fun <R> performBlocking(
    db: RoomDatabase,
    isReadOnly: Boolean,
    inTransaction: Boolean,
    block: (SQLiteConnection) -> R,
): R =
    runBlocking {
        performSuspending(db, isReadOnly, inTransaction, block)
    }

/**
 * Same as the runtime's `recursiveFetchHashMap` but for [ArrayMap]. `MAX_BIND_PARAMETER_CNT` is
 * `internal` in the runtime (`androidx.room.util.RelationUtil.kt`), so it is inlined here as 999.
 */
public fun <K : Any, V> recursiveFetchArrayMap(
    map: ArrayMap<K, V>,
    isRelationCollection: Boolean,
    fetchBlock: (ArrayMap<K, V>) -> Unit,
) {
    val tmpMap = ArrayMap<K, V>()
    var count = 0
    for (key in map.keys.toList()) {
        @Suppress("UNCHECKED_CAST")
        if (isRelationCollection) {
            tmpMap[key] = map[key] as V
        } else {
            tmpMap[key] = null as V
        }
        count++
        if (count == MAX_BIND_PARAMETER_CNT) {
            fetchBlock(tmpMap)
            if (!isRelationCollection) map.putAll(tmpMap as Map<K, V>)
            tmpMap.clear()
            count = 0
        }
    }
    if (count > 0) {
        fetchBlock(tmpMap)
        if (!isRelationCollection) map.putAll(tmpMap as Map<K, V>)
    }
}

private const val MAX_BIND_PARAMETER_CNT = 999
