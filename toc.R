
## Execute as Rscript toc.R <filename>
args <- commandArgs()
extras <- grep("--args", args) + 1
filename <- args[extras[1]]

## Generate table of contents with hyperlinks
library(xml2)
xml <- read_xml(filename)
anchors <- xml_find_all(xml, "//h2/a")
names <- xml_attr(anchors, "name")
headings <- xml_text(anchors)
contents <- lapply(anchors, xml_contents)
## Label references to sections
for (i in seq_along(names)) {
    refs <- xml_find_all(xml, paste0("//a[@href = '#", names[i], "']"))
    for (j in seq_along(refs)) {
        xml_text(refs[j]) <- headings[i]
    }
}
## Add section numbers
## Text version (for TOC)
newheadings <- paste0(1:length(anchors), ". ", headings)
## Inline version (could contain markup, NOT just text)
## (ASSUMES that FIRST child of anchor is text)
xml_text(anchors) <- mapply(function(x, i) {
                                paste0(i, ". ", xml_text(x)[1])
                            },
                            contents, 1:length(anchors), SIMPLIFY=TRUE)
## Replace <toc/> element with this content
toc <- paste('<div><h2>Table of Contents:</h2><ul style="list-style: none">',
             paste0('<li><a href="#', names, '">', newheadings, '</a></li>',
                    collapse=""),
             "</ul></div>", collapse="")
xml_replace(xml_find_first(xml, "//toc"), read_xml(toc))
write_xml(xml, gsub("-protected.xml", "-toc.xml", filename))
