
## Generate glyphInfo input from textshaping::shape_text

info <- shape_text(c("Ferrari", " Dino"), id=1, 
           size=12,
           path=c(system.file("fonts", "Montserrat", "static",
                              "Montserrat-BoldItalic.ttf", package="grDevices"),
                  system.file("fonts", "Montserrat", "static",
                              "Montserrat-Medium.ttf", package="grDevices")),
           index=0)

dput(info$shape$index, control=NULL)
dput(info$shape$x_offset, control=NULL)
dput(info$shape$y_offset, control=NULL)
info$metric$width
info$metric$height/2

