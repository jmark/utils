#!/bin/awk -f

BEGIN {
	# left window bound
    L = ww != "" ? -ww : -1

	# right window bound
    R = ww != "" ?  ww :  1

	OFS = "\t"
	CONVFMT = "%e"
}

/^[$|#]/ {
	# empty lines and comments
	print
	next
}

/^[a-zA-Z]/ {
	# handle column headers
	joined = ""
	for (n = 2; n <= NF; n++) {
		joined = joined OFS "D_" $n
	}
	print $0, joined
	next
}

{
	# save original fields into array, since we will tamper with $n
	# from now on...
	N  = NF
	for (n = 1; n <= N; n++) {orig[n] = $n}

	# as soon as we have an entirely filled window, start differentiating
	if (W[1,L] != "") {
		dx = W[1,R] - W[1,L]
		$1 = W[1,0]
		for (n = 2; n <= N; n++) {
			$n		= W[n,0]
			$(NF+1) = dx == 0 ? "NaN" : (W[n,R] - W[n,L])/dx
		}
		print
	}

	# move window and update right boundary
	for (n = 1; n <= NF; n++) {
		for (i = L; i < R; i++) {W[n,i] = W[n,i+1]}
		W[n,R] = orig[n]
	}
}
