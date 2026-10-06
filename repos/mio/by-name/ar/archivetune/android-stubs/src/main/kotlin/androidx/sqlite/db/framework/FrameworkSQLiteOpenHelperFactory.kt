package androidx.sqlite.db.framework

import androidx.sqlite.db.SupportSQLiteOpenHelper

/*
 * Upstream builds its helper through FrameworkSQLiteOpenHelperFactory().create(configuration);
 * the earlier stub had no members, so that call did not resolve.
 */
open class FrameworkSQLiteOpenHelperFactory : SupportSQLiteOpenHelper.Factory {
    override fun create(configuration: SupportSQLiteOpenHelper.Configuration): SupportSQLiteOpenHelper =
        TODO()

    companion object { }
}
