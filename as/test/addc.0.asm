mov $1, $0
not $1, $1

loop:
	addc $1, $1
	addc $1, $1
	rjmpi loop
