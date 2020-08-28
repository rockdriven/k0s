#!/bin/sh

: ${bindata:=bindata}
: ${gooffsets:=bindata-offsets.go}
: ${pkg:=assets}

offset=0
rm -f "$bindata" "$gooffsets"

( cat <<HEADER
// Code generated by $0
// DO NOT EDIT!

package $pkg

var (
	BinData = map[string]struct { offset, size int64 }{
HEADER

for f; do
	size=$(stat -c "%s" $f)
	printf '\t\t"%s": {%d, %d},\n' "${f#$prefix}" $offset $size
	cat $f >> $bindata
	offset=$(($offset + $size))
done

cat <<FOOTER
	}

	BinDataSize int64 = $offset
)

FOOTER
) | gofmt > "$gooffsets.tmp" && mv "$gooffsets.tmp" "$gooffsets"