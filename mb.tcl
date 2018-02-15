#!/usr/bin/wish

set mbprops(width)      1280
set mbprops(height)     720
set mbprops(cr)         0.0
set mbprops(ci)         0.0
set mbprops(zoom)       1.0
set mbprops(maxiter)    1000

set cstr        "0.0 + 0.0i"
set zoomfaclist {0.01 0.1 0.2 0.5 1 2 5 10 100}
set zoomfac     1.0
set imgfile   "mb.ppm"

proc calcmb {mbprops img imgfile} {
    upvar 1 ${mbprops} mb
    #
    # Compute the new Mandelbrot image.
    #
    exec mb -c $mb(cr) $mb(ci) -z $mb(zoom) -i $mb(maxiter) -o "$imgfile" \
        -x $mb(width) -y $mb(height) 
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
ttk::label .ctlpanel.zoomtitle -text "Zoom" -anchor "e"
ttk::label .ctlpanel.zoomvalue -anchor "w" -textvariable mbprops(zoom)
ttk::label .ctlpanel.zfactitle -text "Zoom factor" -anchor "e"
ttk::spinbox .ctlpanel.zfacvalue -values $zoomfaclist \
    -command {set zoomfac [.ctlpanel.zfacvalue get]}
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
ttk::button .ctlpanel.calc -text "Recalculate Mandelbrot" \
    -command {calcmb mbprops $mbimg "$imgfile"}
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
grid .ctlpanel.calc -column 0 -row 5
grid .ctlpanel.saveimg -column 1 -row 5

set mbimg [image create photo -file "$imgfile"]
.mbpanel create image 0 0 -image $mbimg -anchor nw
calcmb mbprops $mbimg "$imgfile"
.ctlpanel.zfacvalue set $zoomfac

bind .mbpanel <Button-1> {
    set pixwidth      [expr {4.0/$mbprops(height)/$mbprops(zoom)}]
    set mbprops(cr)   [expr {$mbprops(cr) + \
                       $pixwidth*(%x - $mbprops(width)/2)}]
    set mbprops(ci)   [expr {$mbprops(ci) + \
                       $pixwidth*($mbprops(height)/2 - %y)}]
    set mbprops(zoom) [expr {$zoomfac * $mbprops(zoom)}]
    calcmb mbprops $mbimg "$imgfile"
}
