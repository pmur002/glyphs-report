
## Execute as Rscript foot.R <filename>
args <- commandArgs()
extras <- grep("--args", args) + 1
filename <- args[extras[1]]

## Find all footnote labels 
library(xml2)
xml <- read_xml(filename)

internalAnchor <- xml_find_all(xml, "//a[starts-with(@href, '#')]")
footCount <- 0
footnotes <- xml_new_root("div")
for (i in seq_along(internalAnchor)) {
    label <- gsub("^#", "", xml_attr(internalAnchor[i], "href"))
    note <- xml_find_first(xml,
                           paste0("//p[@class = 'footnote' and a[@name = '",
                                  label, "']]"))
    if (length(note)) {
        footCount <- footCount + 1
        xml_add_child(internalAnchor[i], "sup", footCount)
        p <- xml_add_child(footnotes, note)
        xml_add_child(p, "sup", footCount, .where=0)
    }
}
oldfootnotes <- xml_find_first(xml,
                               "//div[preceding-sibling::h2[contains(., 'Footnotes')]]")
xml_replace(oldfootnotes, xml_root(footnotes))

## write out modified XML
write_xml(xml, gsub("-bib.xml", ".xml", filename))
