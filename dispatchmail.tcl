proc dispatch meta {
    # connect to pop3 server

    # download mails one by one

    # filter
    set filter [concat [dict get $meta filter]]
:
    foreach el [split $filter \n] {
        set tmp [split [concat $el]]
        set src [lindex $tmp 0]
        set dst [lindex $tmp end]

        puts "$src => $dst"
    }

    # dispatch

}



































server      pop.gmail.com
login       jmarkert.ml@gmail.com
pass        [3RhBx|BtNxgGiesbgR5zugG
address     jmarkert.ml@gmail.com
filter  {
    niederrhein-pm@pm.org      -> lists/perl-niederrhein.pm
    python-users@uni-koeln.de  -> lists/python-users
}




































