package androidx.hilt.navigation.compose

import androidx.compose.runtime.Composable
import androidx.lifecycle.ViewModel
import java.lang.reflect.Proxy
import java.lang.reflect.Modifier

@Composable
inline fun <reified VM : ViewModel> hiltViewModel(): VM {
    return _createViewModelInstance(VM::class.java) as VM
}

fun _createViewModelInstance(clazz: Class<*>): Any? {
    if (clazz.name == "android.content.Context") {
        return android.content.DummyContext()
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
                else -> _createViewModelInstance(ret)
            }
        }
    }
    
    // Abstract classes
    if (Modifier.isAbstract(clazz.modifiers)) {
        return null
    }

    // Try to construct it
    try {
        val constructor = clazz.constructors.firstOrNull() ?: clazz.declaredConstructors.firstOrNull()
        if (constructor != null) {
            constructor.isAccessible = true
            val args = constructor.parameterTypes.map { _createViewModelInstance(it) }
            return constructor.newInstance(*args.toTypedArray())
        }
    } catch (e: Exception) {
        try {
            val unsafeClass = Class.forName("sun.misc.Unsafe")
            val f = unsafeClass.getDeclaredField("theUnsafe")
            f.isAccessible = true
            val unsafe = f.get(null)
            val allocateInstance = unsafeClass.getMethod("allocateInstance", Class::class.java)
            return allocateInstance.invoke(unsafe, clazz)
        } catch (ue: Exception) {
            ue.printStackTrace()
        }
    }
    return null
}
