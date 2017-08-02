function rmfield(colnr) {
    for (i=colnr; i<NF; i++) {
        $i=$(i+1)
    }
    NF--
}

function rmfieldRX(regex) {
    for (i=1; i<=NF; i++) {
        if(match($i, regex)) {
            break
        }
    }
    rmfield(i)
}
