#!/usr/bin/wish

ttk::style theme use classic

set mbprops(width)      1280
set mbprops(height)     720
set mbprops(cr)         0.0
set mbprops(ci)         0.0
set mbprops(zoom)       1.0
set mbprops(maxiter)    1000
set mbprops(zoomfac)    1.0
set mbprops(cpt)        "haxby"

set cstr      "0.0 + 0.0i"
set imgfile   "mb.ppm"

proc gencstr {cr ci pixwidth} {
    set dp [expr {int(ceil(-1 * log10($pixwidth)) + 1)}]
    if { $dp < 1 } {
        set dp 1
    }
    set fw [expr {$dp + 2}]
    append fstr "%" "$fw" "." "$dp" "f"
    set realpart [format "$fstr" $cr]
    if { $ci < 0 } {
        set imagpart [format "$fstr" [expr {-1 * $ci}]]
        set sign "-"
    } else {
        set imagpart [format "$fstr" $ci]
        set sign "+"
    }
    append imagpart "i"

    return [concat "$realpart" "$sign" "$imagpart"]
}

proc calcmb {mbprops img imgfile} {
    upvar 1 ${mbprops} mb
    #
    # Compute the new Mandelbrot image.
    #
    exec mb -c $mb(cr) $mb(ci) -z $mb(zoom) -i $mb(maxiter) -o "$imgfile" \
        -x $mb(width) -y $mb(height) -p $mb(cpt)
    #
    # Update the image displayed on the screen.
    #
    image create photo $img -file "$imgfile"
}

proc naturalnumber {num} {
    if { [string is integer $num] && ($num > 0)} {
        return 1
    } else {
        puts "Error: $num is not a natural number."
        return 0
    }
}

proc validzoom {num} {
    if { [string is double $num] && ($num > 0)} {
        return 1
    } else {
        puts "Error: $num is an invalid zoom factor."
        return 0
    }
}

proc saveimg {img} {
    set ofile [tk_getSaveFile -confirmoverwrite true \
        -defaultextension ".png"]
    $img write -format png "$ofile"
}

canvas .mbpanel -width $mbprops(width) -height $mbprops(height) 
ttk::frame .ctlpanel 
ttk::label .ctlpanel.ctrtitle -text "Centre point" -anchor "e"
ttk::label .ctlpanel.ctrvalue -anchor "w" -textvariable cstr
ttk::label .ctlpanel.zoomtitle -text "Current zoom" -anchor "e"
ttk::label .ctlpanel.zoomvalue -anchor "w" -textvariable mbprops(zoom)
ttk::label .ctlpanel.zfactitle -text "Zoom factor" -anchor "e"
ttk::entry .ctlpanel.zfacvalue -textvariable mbprops(zoomfac) \
    -validate focusout -validatecommand {validzoom $mbprops(zoomfac)} \
    -invalidcommand {set mbprops(zoomfac) 1.0}
ttk::label .ctlpanel.widthtitle -text "Width" -anchor "e"
ttk::entry .ctlpanel.widthvalue -textvariable mbprops(width) \
    -validate focusout -validatecommand {naturalnumber $mbprops(width)} \
    -invalidcommand {set mbprops(width) 1280}
ttk::label .ctlpanel.heighttitle -text "Height" -anchor "e"
ttk::entry .ctlpanel.heightvalue -textvariable mbprops(height) \
    -validate focusout -validatecommand {naturalnumber $mbprops(height)} \
    -invalidcommand {set mbprops(height) 720}
ttk::label .ctlpanel.itertitle -text "Maximum iterations" -anchor "e"
ttk::entry .ctlpanel.itervalue -textvariable mbprops(maxiter) \
    -validate focusout -validatecommand {naturalnumber $mbprops(maxiter)} \
    -invalidcommand {set mbprops(maxiter) 1000}
ttk::label .ctlpanel.cpttitle -text "Colour palette" -anchor "e"
ttk::menubutton .ctlpanel.cptmenu -menu .ctlpanel.cptmenu.cpt -textvariable mbprops(cpt)
menu .ctlpanel.cptmenu.cpt
.ctlpanel.cptmenu.cpt add command -label "grey" -command {set mbprops(cpt) "grey"}
.ctlpanel.cptmenu.cpt add command -label "haxby" -command {set mbprops(cpt) "haxby"}
.ctlpanel.cptmenu.cpt add command -label "Jet" -command {set mbprops(cpt) "jet"}
.ctlpanel.cptmenu.cpt add command -label "plasma" -command {set mbprops(cpt) "plasma"}
.ctlpanel.cptmenu.cpt add command -label "rainbow" -command {set mbprops(cpt) "rainbow"}
.ctlpanel.cptmenu.cpt add command -label "seis" -command {set mbprops(cpt) "seis"}
.ctlpanel.cptmenu.cpt add command -label "viridis" -command {set mbprops(cpt) "viridis"}
ttk::button .ctlpanel.calc -text "Recalculate Mandelbrot" \
    -command {
        tk busy hold .mbpanel;
        tk busy hold .ctlpanel.calc;
        update;
        tk busy configure .mbpanel -cursor "watch";
        calcmb mbprops $mbimg "$imgfile";
        tk busy forget .mbpanel
        tk busy forget .ctlpanel.calc
    }
ttk::button .ctlpanel.saveimg -text "Save image" \
    -command {saveimg $mbimg}

grid .mbpanel -column 0 -row 0
grid .ctlpanel -column 1 -row 0
grid .ctlpanel.ctrtitle -column 0 -row 0
grid .ctlpanel.ctrvalue -column 1 -row 0
grid .ctlpanel.zoomtitle -column 0 -row 1
grid .ctlpanel.zoomvalue -column 1 -row 1
grid .ctlpanel.zfactitle -column 0 -row 2
grid .ctlpanel.zfacvalue -column 1 -row 2
grid .ctlpanel.widthtitle -column 0 -row 3
grid .ctlpanel.widthvalue -column 1 -row 3
grid .ctlpanel.heighttitle -column 2 -row 3
grid .ctlpanel.heightvalue -column 3 -row 3
grid .ctlpanel.itertitle -column 0 -row 4
grid .ctlpanel.itervalue -column 1 -row 4
grid .ctlpanel.cpttitle -column 0 -row 5
grid .ctlpanel.cptmenu -column 1 -row 5
grid .ctlpanel.calc -column 0 -row 6
grid .ctlpanel.saveimg -column 1 -row 6

set mbimg [image create photo -file "$imgfile"]
.mbpanel create image 0 0 -image $mbimg -anchor nw
tk busy hold .mbpanel
tk busy hold .ctlpanel.calc
update
tk busy configure .mbpanel -cursor "watch"
calcmb mbprops $mbimg "$imgfile"
tk busy forget .mbpanel
tk busy forget .ctlpanel.calc

bind .mbpanel <Button-1> {
    tk busy hold .mbpanel
    tk busy hold .ctlpanel.calc
    update
    tk busy configure .mbpanel -cursor "watch"
    set pixwidth      [expr {4.0/$mbprops(height)/$mbprops(zoom)}]
    set mbprops(cr)   [expr {$mbprops(cr) + \
                       $pixwidth*(%x - $mbprops(width)/2)}]
    set mbprops(ci)   [expr {$mbprops(ci) + \
                       $pixwidth*($mbprops(height)/2 - %y)}]
    set cstr          [gencstr $mbprops(cr) $mbprops(ci) $pixwidth]
    set mbprops(zoom) [expr {$mbprops(zoom) * $mbprops(zoomfac)}]
    calcmb mbprops $mbimg "$imgfile"
    tk busy forget .mbpanel
    tk busy forget .ctlpanel.calc
}

bind .mbpanel <Button-3> {
    tk busy hold .mbpanel
    tk busy hold .ctlpanel.calc
    update
    tk busy configure .mbpanel -cursor "watch"
    set pixwidth      [expr {4.0/$mbprops(height)/$mbprops(zoom)}]
    set mbprops(cr)   [expr {$mbprops(cr) + \
                       $pixwidth*(%x - $mbprops(width)/2)}]
    set mbprops(ci)   [expr {$mbprops(ci) + \
                       $pixwidth*($mbprops(height)/2 - %y)}]
    set cstr          [gencstr $mbprops(cr) $mbprops(ci) $pixwidth]
    set mbprops(zoom) [expr {$mbprops(zoom) / $mbprops(zoomfac)}]
    calcmb mbprops $mbimg "$imgfile"
    tk busy forget .mbpanel
    tk busy forget .ctlpanel.calc
}
