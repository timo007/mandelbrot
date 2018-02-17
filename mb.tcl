#!/usr/bin/wish

ttk::style theme use classic

set mbprops(width)      1280
set mbprops(height)     720
set mbprops(cr)         0.0
set mbprops(ci)         0.0
set mbprops(zoom)       1.0
set mbprops(zoomfac)    5.0
set mbprops(maxiter)    1000
set mbprops(cpt)        "haxby"

set imgfile   "mb.ppm"

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
    image create photo $img -format ppm -file "$imgfile"
}

proc naturalnumber {num} {
    if { [string is integer $num] && ($num > 0)} {
        return 1
    } else {
        return 0
    }
}

proc validctr {num} {
    if { [string is double $num] } {
        return 1
    } else {
        return 0
    }
}

proc validzoom {num} {
    if { [string is double $num] && ($num > 0)} {
        return 1
    } else {
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

ttk::frame .ctlpanel.ctr
ttk::label .ctlpanel.ctr.title -text "Centre point" -anchor "e"
ttk::label .ctlpanel.ctr.rlab -anchor "w" -text "Real"
ttk::label .ctlpanel.ctr.ilab -anchor "w" -text "Imag"
ttk::entry .ctlpanel.ctr.real -textvariable mbprops(cr) \
    -validate key -validatecommand {validctr %P}
ttk::entry .ctlpanel.ctr.imag -textvariable mbprops(ci) \
    -validate key -validatecommand {validctr %P}

ttk::label .ctlpanel.zoomtitle -text "Current zoom" -anchor "e"
ttk::label .ctlpanel.zoomvalue -anchor "w" -textvariable mbprops(zoom)
ttk::label .ctlpanel.zfactitle -text "Zoom factor" -anchor "e"
ttk::entry .ctlpanel.zfacvalue -textvariable mbprops(zoomfac) \
    -validate key -validatecommand {validzoom %P}
ttk::label .ctlpanel.widthtitle -text "Width" -anchor "e"
ttk::entry .ctlpanel.widthvalue -textvariable mbprops(width) \
    -validate key -validatecommand {naturalnumber %P}
ttk::label .ctlpanel.heighttitle -text "Height" -anchor "e"
ttk::entry .ctlpanel.heightvalue -textvariable mbprops(height) \
    -validate key -validatecommand {naturalnumber %P}
ttk::label .ctlpanel.itertitle -text "Maximum iterations" -anchor "e"
ttk::entry .ctlpanel.itervalue -textvariable mbprops(maxiter) \
    -validate key -validatecommand {naturalnumber %P}
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
#
# Position the frame with the central coordinates.
#
grid .ctlpanel.ctr -column 0 -row 0
grid .ctlpanel.ctr.title -column 0 -row 0 -columnspan 2
grid .ctlpanel.ctr.rlab -column 0 -row 1
grid .ctlpanel.ctr.real -column 1 -row 1
grid .ctlpanel.ctr.ilab -column 0 -row 2
grid .ctlpanel.ctr.imag -column 1 -row 2

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

#
# Create and display the initial image.
#
set mbimg [image create photo -format ppm \
    -width $mbprops(width) -height $mbprops(height)]
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
    set mbprops(zoom) [expr {$mbprops(zoom) / $mbprops(zoomfac)}]
    calcmb mbprops $mbimg "$imgfile"
    tk busy forget .mbpanel
    tk busy forget .ctlpanel.calc
}
