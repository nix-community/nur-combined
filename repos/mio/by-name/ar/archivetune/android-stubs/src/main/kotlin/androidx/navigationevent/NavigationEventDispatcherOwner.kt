package androidx.navigationevent

import android.view.View

/*
 * Desktop stand-in for androidx.navigationevent, which Android gets transitively through
 * activity; the port only needs the owner type and the view lookup.
 */
interface NavigationEventDispatcherOwner

fun View.findViewTreeNavigationEventDispatcherOwner(): NavigationEventDispatcherOwner? = null
