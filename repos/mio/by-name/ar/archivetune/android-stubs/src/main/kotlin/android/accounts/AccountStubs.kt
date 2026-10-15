package android.accounts

import android.content.Context

open class Account(val name: String, val type: String)

open class AccountManager {
    companion object {
        private val instance = AccountManager()
        @JvmStatic
        fun get(context: Context): AccountManager = instance
    }

    open fun getAccountsByType(type: String): Array<Account> = emptyArray()
    open fun getAccounts(): Array<Account> = emptyArray()
}
