
## Generate set of glyph info to use to demonstrate fine control over
## justification

## Information taken directly from Montserrat font files:
library(xml2)
head <- read_xml("Montserrat-Medium-head.ttx")
unitsPerEm <- as.numeric(xml_attr(xml_find_first(head, "//unitsPerEm"),
                                  "value"))
fxmin <- as.numeric(xml_attr(xml_find_first(head, "//xMin"), "value"))
fymin <- as.numeric(xml_attr(xml_find_first(head, "//yMin"), "value"))
fxmax <- as.numeric(xml_attr(xml_find_first(head, "//xMax"), "value"))
fymax <- as.numeric(xml_attr(xml_find_first(head, "//yMax"), "value"))

chars <- c("D", "i", "n", "o")
N <- length(chars)

glyphOrder <- read_xml("Montserrat-Medium-GlyphOrder.ttx")
ids <- numeric()
for (i in seq_along(chars)) {
    ids[i] <- as.numeric(xml_attr(xml_find_first(glyphOrder,
                                                 paste0('//GlyphID[@name="',
                                                        chars[i], '"]')),
                                  "id"))
}
hmtx <- read_xml("Montserrat-Medium-hmtx.ttx")
widths <- numeric()
lsbs <- numeric()
for (i in seq_along(chars)) {
    mtx <- xml_find_first(hmtx, paste0('//mtx[@name="', chars[i], '"]'))
    widths[i] <- as.numeric(xml_attr(mtx, "width"))
    lsbs[i] <- as.numeric(xml_attr(mtx, "lsb"))
}
glyf <- read_xml("Montserrat-Medium-glyf.ttx")
xmin <- numeric()
xmax <- numeric()
ymin <- numeric()
ymax <- numeric()
for (i in seq_along(chars)) {
    ttglyph <- xml_find_first(glyf, paste0('//TTGlyph[@name="', chars[i], '"]'))
    xmin[i] <- as.numeric(xml_attr(ttglyph, "xMin"))
    xmax[i] <- as.numeric(xml_attr(ttglyph, "xMax"))
    ymin[i] <- as.numeric(xml_attr(ttglyph, "yMin"))
    ymax[i] <- as.numeric(xml_attr(ttglyph, "yMax"))
}

size <- 100
scale <- size/unitsPerEm

gx <- c(0, cumsum(widths[-N]))
width <- sum(widths)
inkwidth <- xmax[N] - xmin[1]
hcentre <- width/2
height <- fymax - fymin
inkheight <- max(ymax) - min(ymin)
vcentre <- fymin + height/2

dinoGlyphsLarge <-
    glyphInfo(id=ids,
              x=gx*scale,
              y=rep(0, N),
              1,
              size,
              glyphFontList(glyphFont(system.file("fonts", "Montserrat",
                                                  "static",
                                                  "Montserrat-Medium.ttf",
                                                  package="grDevices"),
                                      0, "Montserrat", 400, "normal")),
              width=glyphWidth(c(width, inkwidth)*scale,
                               label=c("width", "inkwidth"),
                               left=c("left", "inkleft")),
              height=glyphHeight(c(height, inkheight, max(ymax))*scale,
                                 label=c("height", "inkheight", "ascent"),
                                 bottom=c("bottom", "inkbottom", "baseline")),
              hAnchor=glyphAnchor(c(0, width/2, width,
                                    min(xmin), max(xmax))*scale,
                                  label=c("left", "centre", "right",
                                          "inkleft", "inkright")),
              vAnchor=glyphAnchor(c(fymin, vcentre, fymax,
                                    min(ymin), 0, max(ymax))*scale,
                                  label=c("bottom", "centre", "top",
                                          "inkbottom", "baseline", "inktop")))  

## Check against textshaping::shape_text() result
textshaping::shape_text(paste(chars, collapse=""), size=size,
                        path=system.file("fonts", "Montserrat", "static",
                                         "Montserrat-Medium.ttf",
                                         package="grDevices"))

## Diagram of glyphs and their metrics
png("glyph-metrics.png", res=96, width=700, height=400)
library(grid)
grid.newpage()
pushViewport(viewport(width=unit(dinoGlyphsLarge$width["width"], "bigpts"),
                      height=unit(dinoGlyphsLarge$height["height"], "bigpts"),
                      xscale=c(0, width),
                      yscale=c(fymin, fymax),
                      gp=gpar(fill=NA, fontface="bold")))
## Vertical anchors
vanchor <- function(y, label, vjust="bottom", col=4, lty="dashed",
                    fontface="bold") {
    grid.segments(unit(-1, "cm"), unit(y, "native"),
                  unit(1, "npc") + unit(1, "cm"), unit(y, "native"),
                  gp=gpar(lty=lty, col=col))
    grid.text(label,
              unit(1, "npc") + unit(1, "cm") + unit(2, "mm"),
              unit(y, "native"), just=c("left", vjust),
              gp=gpar(col=col, fontface=fontface))
}
vanchor(fymin, "bottom", vjust="top")
vanchor(min(ymin), "inkbottom", vjust="top", col=2)
vanchor(0, "baseline", vjust="bottom", col=1, lty="solid", fontface="plain")
vanchor(vcentre, "centre")
vanchor(max(ymax), "inktop", col=2)
vanchor(fymax, "top")
## Heights
drawHeight <- function(x, ymin, ymax, label, col=4) {
    grid.segments(x, ymin, x, ymax, default.units="native",
                  gp=gpar(col=col))
    grid.segments(x - unit(1, "mm"), ymin, x + unit(1, "mm"), ymin,
                  default.units="native", gp=gpar(col=col))
    grid.segments(x - unit(1, "mm"), ymax, x + unit(1, "mm"), ymax,
                  default.units="native", gp=gpar(col=col))
    grid.text(label, x - unit(2, "mm"), unit(ymin, "native"),
              just=c("left", "bottom"), rot=90, gp=gpar(col=col))
}
drawHeight(unit(-1.5, "cm"), fymin, fymax, "height")
drawHeight(unit(-2.5, "cm"), min(ymin), max(ymax), "inkheight", col=2)
drawHeight(unit(-3.5, "cm"), 0, max(ymax), "ascent", col=2)
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
hanchor(0, "left", hjust="right")
hanchor(xmin[1], "inkleft", bottom=FALSE, hjust="left", col=2)
hanchor(hcentre, "centre", bottom=FALSE)
hanchor(gx[N] + xmax[N], "inkright", bottom=FALSE, hjust="right", col=2)
hanchor(width, "right", hjust="left")
## Widths
drawWidth <- function(xmin, xmax, y, label, col=4) {
    grid.segments(xmin, y, xmax, y, default.units="native",
                  gp=gpar(col=col))
    grid.segments(xmin, y - unit(1, "mm"), xmin, y + unit(1, "mm"),
                  default.units="native", gp=gpar(col=col))
    grid.segments(xmax, y - unit(1, "mm"), xmax, y + unit(1, "mm"),
                  default.units="native", gp=gpar(col=col))
    grid.text(label, unit(xmin, "native"),
              y - unit(2, "mm"), just=c("left", "top"), gp=gpar(col=col))
}
drawWidth(0, width, unit(-1.5, "cm"), "width")
drawWidth(xmin[1], gx[N] + xmax[N], unit(-2.5, "cm"), "inkwidth", col=2)
## Blank
grid.rect(0, fymin, width, height, default.units="native",
          just=c("left", "bottom"),
          gp=gpar(col=NA, fill="white"))
## Glyph metrics
bbox <- function(x, y, w, h, col=4) {
    grid.rect(x, y, w, h, default.units="native",
              just=c("left", "bottom"),
              gp=gpar(col=col, fill=adjustcolor(col, alpha=.5)))
}
for (i in seq_along(chars)) {
    bbox(gx[i], fymin, widths[i], height)
    bbox(gx[i] + xmin[i], ymin[i], xmax[i] - xmin[i], ymax[i] - ymin[i], col=2)
}
## The glyphs
grid.glyph(dinoGlyphsLarge, y=unit(0, "native"), vjust="baseline",
           gp=gpar(col=rgb(0,0,0)))
## Origins
grid.circle(gx, 0, r=unit(.5, "mm"), default.units="native",
            gp=gpar(fill="black"))
popViewport()
dev.off()

## Generate another set of glyph info for use in other figures
size <- 12
scale <- size/unitsPerEm

gx <- c(0, cumsum(widths[-N]))
width <- sum(widths)
inkwidth <- xmax[N] - xmin[1]
hcentre <- width/2
height <- fymax - fymin
inkheight <- max(ymax) - min(ymin)
vcentre <- fymin + height/2

dinoGlyphs <-
    glyphInfo(id=ids,
              x=gx*scale,
              y=rep(0, N),
              1,
              size,
              glyphFontList(glyphFont(system.file("fonts", "Montserrat",
                                                  "static",
                                                  "Montserrat-Medium.ttf",
                                                  package="grDevices"),
                                      0, "Montserrat", 400, "normal")),
              width=glyphWidth(c(width, inkwidth)*scale,
                               label=c("width", "inkwidth"),
                               left=c("left", "inkleft")),
              height=glyphHeight(c(height, inkheight, max(ymax))*scale,
                                 label=c("height", "inkheight", "ascent"),
                                 bottom=c("bottom", "inkbottom", "baseline")),
              hAnchor=glyphAnchor(c(0, width/2, width,
                                    min(xmin), max(xmax))*scale,
                                  label=c("left", "centre", "right",
                                          "inkleft", "inkright")),
              vAnchor=glyphAnchor(c(fymin, vcentre, fymax,
                                    min(ymin), 0, max(ymax))*scale,
                                  label=c("bottom", "centre", "top",
                                          "inkbottom", "baseline", "inktop")))  
