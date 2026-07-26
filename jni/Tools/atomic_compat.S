/*
 * ARMv7 atomic compatibility shim.
 *
 * The prebuilt OpenSSL libcrypto.a (armeabi-v7a) was built expecting the
 * outlined GCC atomic helper __sync_add_and_fetch_4 (used by CRYPTO_atomic_add).
 * Modern Clang inlines the __sync_* builtins on ARMv7 and no longer ships that
 * helper, and it refuses any C redefinition of a recognized builtin. Define it
 * directly in assembly so the symbol exists at link time.
 *
 * uint32_t __sync_add_and_fetch_4(volatile void *ptr, uint32_t value)
 *   atomically does *ptr += value and returns the new value.
 */
    .syntax unified
    .arch armv7-a
    .text
    .globl __sync_add_and_fetch_4
    .type  __sync_add_and_fetch_4, %function
__sync_add_and_fetch_4:
    dmb     ish
1:  ldrex   r2, [r0]
    add     r2, r2, r1
    strex   r3, r2, [r0]
    cmp     r3, #0
    bne     1b
    dmb     ish
    mov     r0, r2
    bx      lr
    .size __sync_add_and_fetch_4, .-__sync_add_and_fetch_4
