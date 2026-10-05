package com.google.common.collect

open class ImmutableList<E> : List<E> by emptyList() {
    companion object {
        fun <E> copyOf(elements: Iterable<E>): ImmutableList<E> = ImmutableList()
        fun <E> copyOf(elements: Collection<E>): ImmutableList<E> = ImmutableList()
        fun <E> of(vararg elements: E): ImmutableList<E> = ImmutableList()
    }
}
