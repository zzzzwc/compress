package zstd

import (
	"encoding/binary"
	"math/bits"
)

// matchLen returns the maximum common prefix length of a and b.
// a must be the shortest of the two.
func matchLenGeneric(a, b []byte) (n int) {
	for ; len(a) >= 8 && len(b) >= 8; a, b = a[8:], b[8:] {
		diff := binary.LittleEndian.Uint64(a) ^ binary.LittleEndian.Uint64(b)
		if diff != 0 {
			return n + bits.TrailingZeros64(diff)>>3
		}
		n += 8
	}

	for i := range a {
		if a[i] != b[i] {
			break
		}
		n++
	}
	return n

}
