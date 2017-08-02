proc head {list} {return [lindex $list 0] }
proc tail {list} {return [lrange $list 1 end] }
proc flip {a b}  {return "$b $a"}
proc compose {f g x} {return [$f [$g $x]] }

proc fold {f acc list} {
    foreach _ $list {
        set acc [uplevel 1 {*}$f $acc $_]
    } 
    return $acc
}

proc map {f list {res {}}} {
    foreach _ $list {
        lappend res [uplevel 1 {*}$f $_]
    }
    return $res
}

proc chain {acc cmds} {
    foreach _ $cmds {
        set acc [uplevel 1 {*}$_ $acc]
    } 
    return $acc
}

proc min {list} {
    return [fold ::tcl::matfunc::min [head $list] $list] 
}

proc max {list} {
    return [fold ::tcl::mathfunc::max [head $list] $list] 
}

proc sum {list} {
    return [fold ::tcl::mathop::+ 0 $list] 
}

proc pro {list} {
    return [fold ::tcl::mathop::* 1 $list] 
}

proc lsel {cmd list} {
    set res {}
    foreach _ $list {
        if [uplevel 1 {*}$cmd $_] {lappend res $_}
    }
    return $res
}

proc lrej {cmd list} {
    set res {}
    foreach _ $list {
        if ![uplevel 1 {*}$cmd $_] {lappend res $_}
    }
    return $res
}
