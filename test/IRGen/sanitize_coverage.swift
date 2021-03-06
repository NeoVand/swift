// RUN: %target-swift-frontend -emit-ir -sanitize=address -sanitize-coverage=func %s | %FileCheck %s -check-prefix=SANCOV
// RUN: %target-swift-frontend -emit-ir -sanitize=address -sanitize-coverage=bb %s | %FileCheck %s -check-prefix=SANCOV
// RUN: %target-swift-frontend -emit-ir -sanitize=address -sanitize-coverage=edge %s | %FileCheck %s -check-prefix=SANCOV
// RUN: %target-swift-frontend -emit-ir -sanitize=fuzzer %s | %FileCheck %s -check-prefix=SANCOV
// RUN: %target-swift-frontend -emit-ir -sanitize=address -sanitize-coverage=edge,trace-cmp %s | %FileCheck %s -check-prefix=SANCOV -check-prefix=SANCOV_TRACE_CMP
// RUN: %target-swift-frontend -emit-ir -sanitize=address -sanitize-coverage=edge,trace-bb %s | %FileCheck %s -check-prefix=SANCOV -check-prefix=SANCOV_TRACE_BB
// RUN: %target-swift-frontend -emit-ir -sanitize=address -sanitize-coverage=edge,indirect-calls %s | %FileCheck %s -check-prefix=SANCOV -check-prefix=SANCOV_INDIRECT_CALLS
// RUN: %target-swift-frontend -emit-ir -sanitize=address -sanitize-coverage=edge,8bit-counters %s | %FileCheck %s -check-prefix=SANCOV -check-prefix=SANCOV_8BIT_COUNTERS
// RUN: %target-swift-frontend -emit-ir -sanitize=fuzzer %s | %FileCheck %s -check-prefix=SANCOV -check-prefix=SANCOV_TRACE_CMP

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
import Darwin
#elseif os(Android) || os(Cygwin) || os(FreeBSD) || os(Linux)
import Glibc
#elseif os(Windows)
import MSVCRT
#endif

// FIXME: We should have a reliable way of triggering an indirect call in the
// LLVM IR generated from this code.
func test() {
  // Use random numbers so the compiler can't constant fold
#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
  let x = arc4random()
  let y = arc4random()
#else
  let x = rand()
  let y = rand()
#endif
  // Comparison is to trigger insertion of __sanitizer_cov_trace_cmp
  let z = x == y
  print("\(z)")
}

test()

// FIXME: We need a way to distinguish the different types of coverage instrumentation
// that isn't really fragile. For now just check there's at least one call to the function
// used to increment coverage count at a particular PC.
// SANCOV: call void @__sanitizer_cov

// SANCOV_TRACE_CMP: call void @__sanitizer_cov_trace_cmp
