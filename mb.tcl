#!/usr/bin/wish

ttk::style theme use classic

#
# A procedure to set default values for the Mandelbrot set.
#
proc defaultvals {mbprops} {
    upvar 1 ${mbprops} mb
    set mb(width)      1280
    set mb(height)     720
    set mb(cr)         0.0
    set mb(ci)         0.0
    set mb(zoom)       1.0
    set mb(zoomfac)    5.0
    set mb(maxiter)    1000
    set mb(cpt)        "haxby"
    set mb(ifile)      "mb.ppm"
}
defaultvals mbprops

proc calcmb {mbprops img} {
    upvar 1 ${mbprops} mb
    #
    # Compute the new Mandelbrot image.
    #
    exec mb -c $mb(cr) $mb(ci) -z $mb(zoom) -i $mb(maxiter) \
        -o "$mb(ifile)" -x $mb(width) -y $mb(height) -p $mb(cpt)
    #
    # Update the image displayed on the screen.
    #
    image create photo $img -format ppm -file "$mb(ifile)"
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

font create labelfont -family {Liberation Sans} -size 14 -weight bold
font create textfont -family {Liberation Sans} -size 12 -weight normal

canvas .mbpanel -width $mbprops(width) -height $mbprops(height) 
ttk::frame .ctlpanel 

ttk::frame .ctlpanel.ctr
ttk::label .ctlpanel.ctr.title -text "Mandelprot properties" -font labelfont
ttk::label .ctlpanel.ctr.rlab -anchor "w" -text "Real" -font textfont
ttk::label .ctlpanel.ctr.ilab -anchor "w" -text "Imag" -font textfont
ttk::entry .ctlpanel.ctr.real -textvariable mbprops(cr) \
    -validate key -validatecommand {validctr %P} -font textfont
ttk::entry .ctlpanel.ctr.imag -textvariable mbprops(ci) \
    -validate key -validatecommand {validctr %P} -font textfont

ttk::label .ctlpanel.ctr.zlab -text "Current zoom" -font textfont
ttk::label .ctlpanel.ctr.zval -anchor "w" -textvariable mbprops(zoom) \
    -font textfont
ttk::label .ctlpanel.ctr.zflab -text "Zoom factor" -anchor "e" \
    -font textfont
ttk::entry .ctlpanel.ctr.zfval -textvariable mbprops(zoomfac) \
    -validate key -validatecommand {validzoom %P} -font textfont

ttk::label .ctlpanel.ctr.iterlab -text "Maximum iterations" -anchor "e"
ttk::entry .ctlpanel.ctr.iterval -textvariable mbprops(maxiter) \
    -validate key -validatecommand {naturalnumber %P}

ttk::frame .ctlpanel.img -padding {0 20 0 0}
ttk::label .ctlpanel.img.title -text "Image properties" -font labelfont
ttk::label .ctlpanel.img.wlab -text "Width" -anchor "e"
ttk::entry .ctlpanel.img.wval -textvariable mbprops(width) \
    -validate key -validatecommand {naturalnumber %P}
ttk::label .ctlpanel.img.hlab -text "Height" -anchor "e"
ttk::entry .ctlpanel.img.hval -textvariable mbprops(height) \
    -validate key -validatecommand {naturalnumber %P}

ttk::label .ctlpanel.img.cptlab -text "Colour palette" -anchor "e"
ttk::menubutton .ctlpanel.img.cptmenu -menu .ctlpanel.img.cptmenu.cpt \
    -textvariable mbprops(cpt)
menu .ctlpanel.img.cptmenu.cpt
.ctlpanel.img.cptmenu.cpt add command -label "grey" \
    -command {set mbprops(cpt) "grey"}
.ctlpanel.img.cptmenu.cpt add command -label "haxby" \
    -command {set mbprops(cpt) "haxby"}
.ctlpanel.img.cptmenu.cpt add command -label "Jet" \
    -command {set mbprops(cpt) "jet"}
.ctlpanel.img.cptmenu.cpt add command -label "plasma" \
    -command {set mbprops(cpt) "plasma"}
.ctlpanel.img.cptmenu.cpt add command -label "rainbow" \
    -command {set mbprops(cpt) "rainbow"}
.ctlpanel.img.cptmenu.cpt add command -label "seis" \
    -command {set mbprops(cpt) "seis"}
.ctlpanel.img.cptmenu.cpt add command -label "viridis" \
    -command {set mbprops(cpt) "viridis"}

ttk::button .ctlpanel.calc -text "Recalculate Mandelbrot" \
    -command {
        tk busy hold .mbpanel;
        tk busy hold .ctlpanel.calc;
        update;
        tk busy configure .mbpanel -cursor "watch";
        calcmb mbprops $mbimg
        tk busy forget .mbpanel
        tk busy forget .ctlpanel.calc
    }
ttk::button .ctlpanel.saveimg -text "Save image" \
    -command {saveimg $mbimg}

grid .mbpanel -column 0 -row 0
grid .ctlpanel -column 1 -row 0
#
# Position the frame with the central coordinates and zoom values.
#
grid .ctlpanel.ctr -column 0 -row 0
grid .ctlpanel.ctr.title -column 0 -row 0 -columnspan 2
grid .ctlpanel.ctr.rlab -column 0 -row 1
grid .ctlpanel.ctr.real -column 1 -row 1
grid .ctlpanel.ctr.ilab -column 0 -row 2
grid .ctlpanel.ctr.imag -column 1 -row 2
grid .ctlpanel.ctr.zlab -column 0 -row 3
grid .ctlpanel.ctr.zval -column 1 -row 3
grid .ctlpanel.ctr.zflab -column 0 -row 4
grid .ctlpanel.ctr.zfval -column 1 -row 4
grid .ctlpanel.ctr.iterlab -column 0 -row 5
grid .ctlpanel.ctr.iterval -column 1 -row 5

grid .ctlpanel.img -column 0 -row 2
grid .ctlpanel.img.title -column 0 -row 0 -columnspan 4
grid .ctlpanel.img.wlab -column 0 -row 1
grid .ctlpanel.img.wval -column 1 -row 1
grid .ctlpanel.img.hlab -column 2 -row 1
grid .ctlpanel.img.hval -column 3 -row 1
grid .ctlpanel.img.cptlab -column 0 -row 2
grid .ctlpanel.img.cptmenu -column 1 -row 2

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
calcmb mbprops $mbimg
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
    calcmb mbprops $mbimg
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
    calcmb mbprops $mbimg
    tk busy forget .mbpanel
    tk busy forget .ctlpanel.calc
}
