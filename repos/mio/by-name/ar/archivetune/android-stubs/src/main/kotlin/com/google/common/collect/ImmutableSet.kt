package com.google.common.collect

open class ImmutableSet<E> : Set<E> by emptySet() {
    companion object {
        fun <E> copyOf(elements: Iterable<E>): ImmutableSet<E> = ImmutableSet()
        fun <E> copyOf(elements: Collection<E>): ImmutableSet<E> = ImmutableSet()
        fun <E> of(): ImmutableSet<E> = ImmutableSet()
    }
}
