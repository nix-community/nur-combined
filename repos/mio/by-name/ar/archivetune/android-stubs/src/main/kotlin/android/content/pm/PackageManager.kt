package android.content.pm

import android.content.ComponentName
import android.content.Intent
import android.content.res.Resources

open class PackageManager {
    open fun getPackageInfo(packageName: String, flags: Int): PackageInfo = PackageInfo()
    open fun setComponentEnabledSetting(componentName: ComponentName, newState: Int, flags: Int) {}
    open fun queryIntentActivities(intent: Intent, flags: Int): List<ResolveInfo> = emptyList()
    open fun getServiceInfo(component: ComponentName, flags: Int): ServiceInfo = ServiceInfo()
    open fun getApplicationInfo(packageName: String, flags: Int): ApplicationInfo = ApplicationInfo()
    open fun getResourcesForApplication(appInfo: ApplicationInfo): Resources = Resources()
    open fun resolveActivity(intent: Intent, flags: Int): ResolveInfo = ResolveInfo()

    companion object {
        const val COMPONENT_ENABLED_STATE_DEFAULT = 0
        const val COMPONENT_ENABLED_STATE_ENABLED = 1
        const val COMPONENT_ENABLED_STATE_DISABLED = 2
        const val DONT_KILL_APP = 1
        const val MATCH_DEFAULT_ONLY = 0x00010000
        const val MATCH_ALL = 0x00020000
    }
}

open class PackageInfo {
    open val versionName: String = ""
    open val longVersionCode: Long = 0L
}

open class ComponentInfo {
    open var name: String = ""
    open var packageName: String = ""
}

open class ApplicationInfo : ComponentInfo() {
    open fun loadLabel(pm: PackageManager): CharSequence = ""
    open var flags: Int = 0
    companion object {
        const val FLAG_SYSTEM = 1
    }
}

open class ServiceInfo : ComponentInfo() {
    open val applicationInfo: ApplicationInfo = ApplicationInfo()
}

open class ResolveInfo {
    open val activityInfo: ActivityInfo = ActivityInfo()
    open val serviceInfo: ServiceInfo = ServiceInfo()
    open fun loadLabel(pm: PackageManager): CharSequence = ""
}

open class ActivityInfo : ComponentInfo() {
    open val applicationInfo: ApplicationInfo = ApplicationInfo()
}
