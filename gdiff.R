
library(gdiff)

## Check overall compare result
ok <- function(result) {
    all(result$controlInTest) && all(result$testInControl) &&
        all(result$diffs == 0) && all(is.na(result$errors))
}

checkImages <- function() {
    ## First check that a control set of images exists
    if (!dir.exists("figureControl"))
        stop("./figureControl/ does not exist")

    compareDir <- file.path(tempdir(), "figureCompare")
    if (dir.exists(compareDir))
        unlink(compareDir)
    dir.create(compareDir)
    
    result <- gdiffCompare("figure", "figureControl", compareDir)
    if (!ok(result)) {
        file.copy(compareDir, ".", recursive=TRUE)
        print(result)
        stop("Figures have changed!")
    }    
}

checkImages()
      
