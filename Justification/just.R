
## Hand craft set of glyph info to use to demonstrate fine control over
## justification

## Information taken directly from Montserrat font files:
## Montserrat-Medium-head.ttx
##    <unitsPerEm value="1000"/>
##    <xMin value="-170"/>
##    <yMin value="-259"/>
##    <xMax value="1529"/>
##    <yMax value="1021"/>
## Montserrat-Medium-GlyphOrder.ttx
##    <GlyphID id="492" name="j"/>
##    <GlyphID id="589" name="u"/>
##    <GlyphID id="567" name="s"/>
##    <GlyphID id="581" name="t"/>
## Montserrat-Medium-hmtx.ttx
##    <mtx name="j" width="284" lsb="-92"/>
##    <mtx name="u" width="677" lsb="86"/>
##    <mtx name="s" width="501" lsb="24"/>
##    <mtx name="t" width="414" lsb="15"/>
## Montserrat-Medium-glyf.ttx
##    <TTGlyph name="j" xMin="-92" yMin="-200" xMax="209" yMax="757">
##    <TTGlyph name="u" xMin="86" yMin="-6" xMax="585" yMax="530">
##    <TTGlyph name="s" xMin="24" yMin="-6" xMax="472" yMax="535">
##    <TTGlyph name="t" xMin="15" yMin="-6" xMax="389" yMax="646">
size <- 100
unitsPerEm <- 1000
scale <- size/unitsPerEm
glyphs <-
    glyphInfo(id=c(492, 589, 567, 581),
              x=c(0, 284, 961, 1462)*scale,
              y=rep(0, 4),
              1,
              size,
              glyphFontList(glyphFont(system.file("fonts", "Montserrat",
                                                  "static",
                                                  "Montserrat-Medium.ttf",
                                                  package="grDevices"),
                                      0, "Montserrat", 400, "normal")),
              width=glyphWidth(c(1876, 1958)*scale,
                               label=c("width", "inkwidth"),
                               left=c("left", "inkleft")),
              height=glyphHeight(c(1280, 957, 757)*scale,
                                 label=c("height", "inkheight", "ascent"),
                                 bottom=c("bottom", "bottom", "baseline")),
              hAnchor=glyphAnchor(c(0, 938, 1876,
                                    -92, 1851)*scale,
                                  label=c("left", "centre", "right",
                                          "inkleft", "inkright")),
              vAnchor=glyphAnchor(c(-259, 640, 1021,
                                    -200, 0, 757)*scale,
                                  label=c("bottom", "centre", "top",
                                          "inkbottom", "baseline", "inktop")))  

## Check against textshaping::shape_text() result
textshaping::shape_text("just", size=36,
                        path=system.file("fonts", "Montserrat", "static",
                                         "Montserrat-Medium.ttf",
                                         package="grDevices"))
## $shape
##   glyph index metric_id string_id x_offset y_offset x_midpoint
## 1     0   492         1         1  0.00000        0   5.109375
## 2     1   589         1         1 10.21875        0  12.187500
## 3     2   567         1         1 34.59375        0   9.015625
## 4     3   581         1         1 52.62500        0   7.453125
## 
## $metrics
##   string    width   height left_bearing right_bearing top_bearing
## 1   just 67.53125 78.71875      -3.3125       0.90625     7.59375
##   bottom_bearing left_border top_border    pen_x pen_y
## 1       1.828125           0   34.84375 67.53125     0

## Diagram of glyphs and their metrics
png("just-metrics.png", res=96, width=600, height=500)
library(grid)
grid.newpage()
pushViewport(viewport(width=unit(glyphs$width["width"], "bigpts"),
                      height=unit(glyphs$height["height"], "bigpts"),
                      xscale=c(0, 1876),
                      yscale=c(-259, 1021),
                      gp=gpar(fill=NA, fontface="bold")))
## Vertical anchors
vanchor <- function(y, label, vjust="bottom", col=4) {
    grid.segments(unit(-1, "cm"), unit(y, "native"),
                  unit(1, "npc") + unit(1, "cm"), unit(y, "native"),
                  gp=gpar(lty="dashed", col=col))
    grid.text(label,
              unit(1, "npc") + unit(1, "cm") + unit(2, "mm"),
              unit(y, "native"), just=c("left", vjust),
              gp=gpar(col=col))
}
vanchor(-259, "bottom", vjust="top")
vanchor(-200, "inkbottom", col=2)
vanchor(0, "baseline", col=2)
vanchor(400, "centre")
vanchor(757, "inktop", col=2)
vanchor(1021, "top")
## Heights
height <- function(x, ymin, ymax, label, col=4) {
    grid.segments(x, ymin, x, ymax, default.units="native",
                  gp=gpar(col=col))
    grid.segments(x - unit(1, "mm"), ymin, x + unit(1, "mm"), ymin,
                  default.units="native", gp=gpar(col=col))
    grid.segments(x - unit(1, "mm"), ymax, x + unit(1, "mm"), ymax,
                  default.units="native", gp=gpar(col=col))
    grid.text(label, x - unit(2, "mm"), unit(ymin, "native"),
              just=c("left", "bottom"), rot=90, gp=gpar(col=col))
}
height(unit(-1.5, "cm"), -259, 1021, "height")
height(unit(-2.5, "cm"), -200, 757, "inkheight", col=2)
height(unit(-3.5, "cm"), 0, 757, "ascent", col=2)
## Horizontal anchors
hanchor <- function(x, label, bottom=FALSE, hjust="left", col=4) {
    grid.segments(unit(x, "native"), unit(-1, "cm"),
                  unit(x, "native"), unit(1, "npc") + unit(1, "cm"),
                  gp=gpar(lty="dashed", col=col))
    if (bottom) {
        grid.text(label,
                  unit(x, "native"), unit(-1, "cm") - unit(2, "mm"),
                  just=c(hjust, "top"), gp=gpar(col=col))
    } else {
        grid.text(label,
                  unit(x, "native"),
                  unit(1, "npc") + unit(1, "cm") + unit(2, "mm"),
                  just=c(hjust, "bottom"), gp=gpar(col=col))
    }
}
hanchor(-92, "inkleft", bottom=FALSE, hjust="right", col=2)
hanchor(0, "left", hjust="left")
hanchor(938, "centre", bottom=FALSE)
hanchor(1851, "inkright", bottom=FALSE, hjust="right", col=2)
hanchor(1876, "right", hjust="left")
## Widths
width <- function(xmin, xmax, y, label, col=4) {
    grid.segments(xmin, y, xmax, y, default.units="native",
                  gp=gpar(col=col))
    grid.segments(xmin, y - unit(1, "mm"), xmin, y + unit(1, "mm"),
                  default.units="native", gp=gpar(col=col))
    grid.segments(xmax, y - unit(1, "mm"), xmax, y + unit(1, "mm"),
                  default.units="native", gp=gpar(col=col))
    grid.text(label, unit(xmin, "native"),
              y - unit(2, "mm"), just=c("left", "top"), gp=gpar(col=col))
}
width(0, 1876, unit(-1.5, "cm"), "width")
width(-92, 1851, unit(-2.5, "cm"), "inkwidth", col=2)
## Blank
grid.rect(0, -259, 1876, 1280, default.units="native",
          just=c("left", "bottom"),
          gp=gpar(col=NA, fill="white"))
## Glyph metrics
bbox <- function(x, y, w, h, col=4) {
    grid.rect(x, y, w, h, default.units="native",
              just=c("left", "bottom"),
              gp=gpar(col=col, fill=adjustcolor(col, alpha=.5)))
}
bbox(0, -259, 284, 1280)
bbox(-92, -200, 301, 957, col=2)
bbox(284, -259, 677, 1280)
bbox(370, -6, 499, 536, col=2)
bbox(961, -259, 501, 1280)
bbox(985, -6, 448, 541, col=2)
bbox(1462, -259, 414, 1280)
bbox(1477, -6, 374, 652, col=2)
## The glyphs
grid.glyph(glyphs, y=unit(0, "native"), vjust="baseline",
           gp=gpar(col=rgb(0,0,0)))
## Origins
grid.circle(c(0, 284, 961, 1462), 0, r=unit(.5, "mm"), default.units="native",
            gp=gpar(fill="black"))
popViewport()
dev.off()

