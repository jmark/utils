#!/usr/bin/awk -f

# produce report with minimum and maximum values
# of every column from given data file

function min(a,b) {
    return a < b ? a : b
}

function max(a,b) {
    return a > b ? a : b
}

NR == 1 {
    for (i = 1; i <= NF; i++) {
        mins[i] = $i
        maxs[i] = $i
    }
    next
}

{
    for (i = 1; i <= NF; i++) {
        mins[i] = min(mins[i], $i)
        maxs[i] = max(maxs[i], $i)
    }
}

END{
    for (i = 1; i <= NF; i++) {
        printf("% 2d % 20f % 20f\n", i, mins[i],maxs[i])
    }
}
