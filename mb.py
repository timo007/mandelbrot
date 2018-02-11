from tkinter import *
#from tkinter.ttk import *
import subprocess as sub

root = Tk()

imgfile = "mb.ppm"
imgwidth = 1280
imgheight = 720

zoom        = DoubleVar()
zoomfactor  = DoubleVar()
cr          = DoubleVar()
ci          = DoubleVar()
pr          = DoubleVar()
pi          = DoubleVar()
cstr        = StringVar()
pstr        = StringVar()

zoom.set(1.0)
zoomfactor.set(5.0)
cr.set(0.0)
ci.set(0.0)
pr.set(cr.get())
pi.set(ci.get())
cstr.set("Current centre point: "+str(cr.get())+"+"+str(ci.get())+"i")
pstr.set("Selected zoom point: "+str(pr.get())+"+"+str(pi.get())+"i")

def setcentrezoom(event):
    setcentre(event)
    calcmb(event)

def setcentre(event):
    global imgheight
    global imgwidth

    pixwidth = 4/imgheight/zoom.get()
    pr.set(cr.get() + pixwidth*(event.x - imgwidth/2))
    pi.set(ci.get() + pixwidth*(imgheight/2 - event.y))
    pstr.set("Selected zoom point: "+str(pr.get())+"+"+str(pi.get())+"i")
    controlpanel.update_idletasks()

def calcmb(event):
    global canvas
    global mbimg

    zoom.set(zoom.get()*zoomfactor.get())
    cr.set(pr.get())
    ci.set(pi.get())
    cstr.set("Current centre point: "+str(cr.get())+"+"+str(ci.get())+"i")
    controlpanel.update_idletasks()
    command = "mb"
    command = command+" -c "+str(pr.get())+" "+str(pi.get())
    command = command+" -z "+str(zoom.get())
    command = command+" -i 1000 -x 1280 -y 720 -o mb.ppm"
    sub.run(command, shell=True)
    img.configure(file="mb.ppm")
    print("Processing done: "+command)
    


canvas = Canvas(root, width=imgwidth, height=imgheight)

controlpanel = Frame(root)

centrelabel = Label(controlpanel, textvariable=cstr)
zoomlabel = Label(controlpanel, textvariable=zoom)
zoomptlabel = Label(controlpanel, textvariable=pstr)

zfscale = Scale(controlpanel, length=400, resolution=1,
                label="Zoom Factor", from_=1.0, to=100, orient=HORIZONTAL,
                variable=zoomfactor)
#zfscale = Scale(controlpanel, length=400, from_=1.0, to=100,
#                orient=HORIZONTAL, variable=zoomfactor)

calcbutton = Button(controlpanel, text="Compute Mandelbrot Set")
calcbutton.bind('<Button-1>', func=calcmb)

canvas.grid(row=0, column=0)
img = PhotoImage(file=imgfile)
mbimg = canvas.create_image(0, 0, anchor=NW, image=img)
canvas.bind('<Button-1>', func=setcentre)
canvas.bind('<Double-Button-1>', func=setcentrezoom)

controlpanel.grid(row=0, column=1)
zoomlabel.grid(row=0, column=0)
centrelabel.grid(row=1, column=0)
zoomptlabel.grid(row=2, column=0)
zfscale.grid(row=3, column=0)
calcbutton.grid(row=4, column=0)

mainloop()
