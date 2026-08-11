package org.nixos.gradle2nix

import org.gradle.api.internal.GradleInternal
import org.gradle.api.invocation.Gradle

inline fun <reified T> Gradle.service(): T = (this as GradleInternal).services.get(T::class.java)
