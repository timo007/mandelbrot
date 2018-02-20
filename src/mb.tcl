#!/bin/sh
# the next line restarts using wish \
exec wish "$0" ${1+"$@"}

#
# Set the style.
#
ttk::style theme use classic
ttk::style configure Header.TLabel -font TkHeadingFont

#
# A procedure to set default values for the Mandelbrot set.
#
proc defaultvals {mbprops} {
    upvar 1 ${mbprops} mb
    set mb(width)      1280
    set mb(height)     720
    set mb(cr)         0.0
    set mb(ci)         0.0
    set mb(zoom)       0.25
    set mb(zoomfac)    5.0
    set mb(maxiter)    1000
    set mb(cpt)        "haxby"
    set mb(ifile)      "mb.ppm"
}
defaultvals mbprops

#
# Call the program which computes the Mandelbrot set image.
#
proc calcmb {mbprops} {
    upvar 1 ${mbprops} mb
    #
    # Compute the new Mandelbrot image.
    #
    exec mb -c $mb(cr) $mb(ci) -z $mb(zoom) -i $mb(maxiter) \
        -o "$mb(ifile)" -x $mb(width) -y $mb(height) -p $mb(cpt)
}

#
# Limit canvas dimensions to no bigger than 1280x720
#
proc canwidth {width} {
    if { $width > 1280 } {
        return 1280
    } else {
        return $width
    } 
}
 
proc canheight {height} {
    if { $height > 720 } {
        return 720
    } else {
        return $height
    } 
}
#
# Test if a number is natural.
#
proc naturalnumber {num} {
    if { [string is integer $num] && ($num > 0)} {
        return 1
    } else {
        return 0
    }
}

#
# Test if a number forms part of a valid centre coordinate.
#
proc validctr {num} {
    if { [string is double $num] } {
        return 1
    } else {
        return 0
    }
}

#
# Test if a number is a valid zoom value.
#
proc validzoom {num} {
    if { [string is double $num] && ($num > 0)} {
        return 1
    } else {
        return 0
    }
}

#
# Save the Mandelbrot image as a PNG file.
#
proc saveimg {img} {
    set ofile [tk_getSaveFile -confirmoverwrite true \
        -defaultextension ".png"]
    if { [string length $ofile] > 0 } {
        $img write -format png "$ofile"
    }
}

#
# The widgets.
#
canvas .mbpanel -width [canwidth $mbprops(width)] \
    -height [canheight $mbprops(height)]
ttk::frame .ctlpanel 

ttk::frame .ctlpanel.ctr
ttk::label .ctlpanel.ctr.title -text "Mandelbrot properties" \
    -style Header.TLabel
ttk::label .ctlpanel.ctr.rlab -anchor "w" -text "Centre Real" -anchor e
ttk::label .ctlpanel.ctr.ilab -anchor "w" -text "Centre Imag" -anchor e
ttk::entry .ctlpanel.ctr.real -textvariable mbprops(cr) \
    -validate key -validatecommand {validctr %P}
ttk::entry .ctlpanel.ctr.imag -textvariable mbprops(ci) \
    -validate key -validatecommand {validctr %P}

ttk::label .ctlpanel.ctr.zlab -text "Current zoom" -anchor e
ttk::entry .ctlpanel.ctr.zval -textvariable mbprops(zoom) \
    -validate key -validatecommand {validzoom %P}
ttk::label .ctlpanel.ctr.zflab -text "Zoom factor" -anchor "e" 
ttk::entry .ctlpanel.ctr.zfval -textvariable mbprops(zoomfac) \
    -validate key -validatecommand {validzoom %P}

ttk::label .ctlpanel.ctr.iterlab -text "Iterations"
ttk::entry .ctlpanel.ctr.iterval -textvariable mbprops(maxiter) \
    -validate key -validatecommand {naturalnumber %P}

ttk::frame .ctlpanel.img -padding {0 20 0 0}
ttk::label .ctlpanel.img.title -text "Image properties" \
    -style Header.TLabel
ttk::label .ctlpanel.img.wlab -text "Width" -anchor e
ttk::entry .ctlpanel.img.wval -textvariable mbprops(width) -width 10 \
    -validate key -validatecommand {naturalnumber %P}
ttk::label .ctlpanel.img.hlab -text "Height" -anchor e
ttk::entry .ctlpanel.img.hval -textvariable mbprops(height) -width 10 \
    -validate key -validatecommand {naturalnumber %P}

ttk::label .ctlpanel.img.cptlab -text "Palette"
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

ttk::frame .ctlpanel.buttons -padding {0 20 0 0}
ttk::button .ctlpanel.buttons.calc -text "Calculate" \
    -command {
        tk busy hold .mbpanel;
        tk busy hold .ctlpanel
        update;
        tk busy configure .mbpanel -cursor "watch";
        calcmb mbprops
        .mbpanel configure -width [canwidth $mbprops(width)] \
            -height [canheight $mbprops(height)]
        image create photo $mbimg -format ppm -file "$mbprops(ifile)"
        tk busy forget .mbpanel
        tk busy forget .ctlpanel
    }
ttk::button .ctlpanel.buttons.saveimg -text "Save" \
    -command {saveimg $mbimg}
ttk::button .ctlpanel.buttons.reset -text "Reset" \
    -command {
        defaultvals mbprops
        tk busy hold .mbpanel;
        tk busy hold .ctlpanel;
        update;
        tk busy configure .mbpanel -cursor "watch";
        calcmb mbprops
        .mbpanel configure -width [canwidth $mbprops(width)] \
            -height [canheight $mbprops(height)]
        image create photo $mbimg -format ppm -file "$mbprops(ifile)"
        tk busy forget .mbpanel
        tk busy forget .ctlpanel
    }
ttk::button .ctlpanel.buttons.quit -text "Quit" \
    -command {exit 0}

#
# Position the Mandelbrot canvas and control panel.
#
grid .mbpanel -column 0 -row 0 -sticky n
grid .ctlpanel -column 1 -row 0 -sticky n

#
# Position the various control panel widgets.
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

#
# Position the frame with the image settings.
#
grid .ctlpanel.img -column 0 -row 1
grid .ctlpanel.img.title -column 0 -row 0 -columnspan 4
grid .ctlpanel.img.wlab -column 0 -row 1
grid .ctlpanel.img.wval -column 1 -row 1
grid .ctlpanel.img.hlab -column 2 -row 1
grid .ctlpanel.img.hval -column 3 -row 1
grid .ctlpanel.img.cptlab -column 0 -row 2
grid .ctlpanel.img.cptmenu -column 1 -row 2

#
# The buttons at the bottom.
#
grid .ctlpanel.buttons -column 0 -row 2
grid .ctlpanel.buttons.calc -column 0 -row 0
grid .ctlpanel.buttons.saveimg -column 1 -row 0
grid .ctlpanel.buttons.reset -column 2 -row 0
grid .ctlpanel.buttons.quit -column 3 -row 0

#
# Left and right mouse button bindings.
#
bind .mbpanel <Button-1> {
    tk busy hold .mbpanel
    tk busy hold .ctlpanel
    update
    tk busy configure .mbpanel -cursor "watch"
    set pixwidth      [expr {1.0/$mbprops(height)/$mbprops(zoom)}]
    set mbprops(cr)   [expr {$mbprops(cr) + \
                       $pixwidth*(%x - $mbprops(width)/2)}]
    set mbprops(ci)   [expr {$mbprops(ci) + \
                       $pixwidth*($mbprops(height)/2 - %y)}]
    set mbprops(zoom) [expr {$mbprops(zoom) * $mbprops(zoomfac)}]
    calcmb mbprops
    .mbpanel configure -width [canwidth $mbprops(width)] \
        -height [canheight $mbprops(height)]
    image create photo $mbimg -format ppm -file "$mbprops(ifile)"
    tk busy forget .mbpanel
    tk busy forget .ctlpanel
}

bind .mbpanel <Button-3> {
    tk busy hold .mbpanel
    tk busy hold .ctlpanel
    update
    tk busy configure .mbpanel -cursor "watch"
    set pixwidth      [expr {1.0/$mbprops(height)/$mbprops(zoom)}]
    set mbprops(cr)   [expr {$mbprops(cr) + \
                       $pixwidth*(%x - $mbprops(width)/2)}]
    set mbprops(ci)   [expr {$mbprops(ci) + \
                       $pixwidth*($mbprops(height)/2 - %y)}]
    set mbprops(zoom) [expr {$mbprops(zoom) / $mbprops(zoomfac)}]
    calcmb mbprops
    .mbpanel configure -width [canwidth $mbprops(width)] \
        -height [canheight $mbprops(height)]
    image create photo $mbimg -format ppm -file "$mbprops(ifile)"
    tk busy forget .mbpanel
    tk busy forget .ctlpanel
}

#
# Create and display the initial image.
#
set mbimg [image create photo -format ppm \
    -width $mbprops(width) -height $mbprops(height)]
.mbpanel create image 0 0 -image $mbimg -anchor nw
tk busy hold .mbpanel
tk busy hold .ctlpanel
update
tk busy configure .mbpanel -cursor "watch"
calcmb mbprops
.mbpanel configure -width [canwidth $mbprops(width)] \
    -height [canheight $mbprops(height)]
image create photo $mbimg -format ppm -file "$mbprops(ifile)"
tk busy forget .mbpanel
tk busy forget .ctlpanel
