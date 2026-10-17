package androidx.hilt.navigation.compose

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.lifecycle.ViewModel
import java.lang.reflect.Proxy
import java.lang.reflect.Modifier

@Composable
inline fun <reified VM : ViewModel> hiltViewModel(): VM {
    val backStackEntry = androidx.navigation.compose.LocalCurrentBackStackEntry.current
        ?: androidx.navigation.NavController.globalInstance?.currentBackStackEntry
    val savedStateHandle = backStackEntry?.savedStateHandle
    return remember(backStackEntry, VM::class.java) {
        _createViewModelInstance(VM::class.java, savedStateHandle) as VM
    }
}

private var _globalMusicDatabase: Any? = null
private var _dbInitialized = false

fun getGlobalMusicDatabase(): Any? {
    if (!_dbInitialized) {
        try {
            val clazz = Class.forName("moe.rukamori.archivetune.db.InternalDatabase")
            val companion = clazz.getField("Companion").get(null)
            val method = companion.javaClass.methods.first { m ->
                m.name == "newInstance" && m.parameterCount == 1
            }
            _globalMusicDatabase = method.invoke(companion, android.content.DummyContext())
        } catch (e: java.lang.reflect.InvocationTargetException) {
            throw e.targetException ?: e
        }
        _dbInitialized = true
    }
    return _globalMusicDatabase
}

fun _createViewModelInstance(clazz: Class<*>, savedStateHandle: androidx.lifecycle.SavedStateHandle? = null): Any? {
    println("[HiltViewModel] creating instance of ${clazz.name} (savedStateHandle keys: ${savedStateHandle?.keys()})")
    if (android.content.Context::class.java.isAssignableFrom(clazz)) {
        if (clazz.name == "android.app.Application") {
            return android.app.Application()
        }
        return android.content.DummyContext()
    }
    if (clazz.name == "androidx.lifecycle.SavedStateHandle") {
        return savedStateHandle ?: androidx.lifecycle.SavedStateHandle()
    }
    if (clazz.name == "moe.rukamori.archivetune.db.MusicDatabase") {
        return getGlobalMusicDatabase()
    }
    if (clazz.name == "moe.rukamori.archivetune.playback.PlayerConnection") {
        try {
            val c = Class.forName("moe.rukamori.archivetune.CompositionLocalsKt")
            val m = c.getMethod("getGlobalPlayerConnection")
            return m.invoke(null)
        } catch (e: Throwable) {}
    }

    when {
        clazz == Int::class.java -> return 0
        clazz == Boolean::class.java -> return false
        clazz == String::class.java -> return ""
        clazz == Long::class.java -> return 0L
        clazz == Float::class.java -> return 0f
        clazz == Double::class.java -> return 0.0
        clazz.isInterface -> return Proxy.newProxyInstance(
            clazz.classLoader,
            arrayOf(clazz)
        ) { _, method, _ ->
            val ret = method.returnType
            when {
                ret == Boolean::class.java -> false
                ret == Int::class.java -> 0
                ret == Long::class.java -> 0L
                ret == Float::class.java -> 0f
                ret == Double::class.java -> 0.0
                ret == String::class.java -> ""
                ret.name == "kotlinx.coroutines.flow.Flow" -> kotlinx.coroutines.flow.emptyFlow<Any>()
                ret.name == "kotlinx.coroutines.flow.StateFlow" -> kotlinx.coroutines.flow.MutableStateFlow<Any?>(null)
                else -> _createViewModelInstance(ret, savedStateHandle)
            }
        }
    }
    
    // Abstract classes
    if (Modifier.isAbstract(clazz.modifiers)) {
        return null
    }

    // Try to construct it
    try {
        val constructor = clazz.declaredConstructors.firstOrNull { c ->
            c.annotations.any { it.annotationClass.java.name == "javax.inject.Inject" }
        } ?: clazz.constructors.firstOrNull { !it.isSynthetic }
          ?: clazz.declaredConstructors.firstOrNull { !it.isSynthetic }
          ?: clazz.constructors.firstOrNull()
          ?: clazz.declaredConstructors.firstOrNull()

        if (constructor != null) {
            constructor.isAccessible = true
            val args = constructor.parameterTypes.map { _createViewModelInstance(it, savedStateHandle) }
            return constructor.newInstance(*args.toTypedArray())
        }
    } catch (e: Throwable) {
        println("Failed to construct ${clazz.name}: $e")
        e.printStackTrace()
        try {
            val unsafeClass = Class.forName("sun.misc.Unsafe")
            val f = unsafeClass.getDeclaredField("theUnsafe")
            f.isAccessible = true
            val unsafe = f.get(null)
            val allocateInstance = unsafeClass.getMethod("allocateInstance", Class::class.java)
            val instance = allocateInstance.invoke(unsafe, clazz)
            if (instance != null) {
                var currentClass: Class<*>? = clazz
                while (currentClass != null && currentClass != Any::class.java) {
                    for (field in currentClass.declaredFields) {
                        try {
                            field.isAccessible = true
                            if (field.get(instance) == null) {
                                if (android.content.Context::class.java.isAssignableFrom(field.type)) {
                                    field.set(instance, android.content.DummyContext())
                                } else if (field.type.name == "androidx.lifecycle.SavedStateHandle") {
                                    field.set(instance, savedStateHandle ?: androidx.lifecycle.SavedStateHandle())
                                } else if (field.type.name == "moe.rukamori.archivetune.db.MusicDatabase") {
                                    field.set(instance, getGlobalMusicDatabase())
                                } else if (field.type.name == "moe.rukamori.archivetune.playback.PlayerConnection") {
                                    val c = Class.forName("moe.rukamori.archivetune.CompositionLocalsKt")
                                    val m = c.getMethod("getGlobalPlayerConnection")
                                    field.set(instance, m.invoke(null))
                                } else if (field.type.name == "kotlinx.coroutines.flow.StateFlow" || field.type.name == "kotlinx.coroutines.flow.MutableStateFlow") {
                                    field.set(instance, kotlinx.coroutines.flow.MutableStateFlow<Any?>(null))
                                }
                            }
                        } catch (fe: Throwable) {}
                    }
                    currentClass = currentClass.superclass
                }
            }
            return instance
        } catch (ue: Throwable) {
            ue.printStackTrace()
        }
    }
    return null
}
