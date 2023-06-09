package zstd

// matchLen returns the maximum common prefix length of a and b.
// a must be the shortest of the two.
//
//go:noescape
func matchLenASM(a, b []byte) int
