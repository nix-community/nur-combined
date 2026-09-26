package com.google.common.collect

open class ImmutableList<E> private constructor(private val backing: List<E> = emptyList()) : List<E> by backing {
    companion object {
        fun <E> of(): ImmutableList<E> = ImmutableList()
        fun <E> of(vararg elements: E): ImmutableList<E> = ImmutableList(elements.toList())
        fun <E> copyOf(elements: Iterable<E>): ImmutableList<E> = ImmutableList(elements.toList())
        fun <E> copyOf(elements: Collection<E>): ImmutableList<E> = ImmutableList(elements.toList())
        fun <E> copyOf(elements: Array<E>): ImmutableList<E> = ImmutableList(elements.toList())
        fun <E> builder(): Builder<E> = Builder()
    }

    class Builder<E> {
        private val list = mutableListOf<E>()
        fun add(element: E): Builder<E> = also { list.add(element) }
        fun addAll(elements: Iterable<E>): Builder<E> = also { list.addAll(elements) }
        fun build(): ImmutableList<E> = ImmutableList(list.toList())
    }
}
