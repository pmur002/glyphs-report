
## migration.csv built from copy-pasted data from 
## https://dashboard.e-stat.go.jp/en/graph?screenCode=00030
## This site is brilliant because it has selectable text
## as well as both Japanese and English versions.

migration <- read.csv("migration.csv")
migration$month <- as.Date(paste0("01.", migration$month), format="%d.%b.%Y")
subset <- subset(migration, month >= as.Date("2019-09-01"))

## Japanese labels are taken from the Japenese version of the page
## (with English translations from the English version of the page)
## and a bit of fiddling with Google Translate to see which bits
## are within the parentheses

## The larger blocks of text are from English/Japanese versions of
## the "White Paper on Tourism in Japan,2022 (Summary)"
## https://www.mlit.go.jp/kankocho/en/siryou/content/001583966.pdf
## https://www.mlit.go.jp/statistics/content/001512919.pdf

## Actually they are quotes found (generated?) by ChatGPT
## (Google translate converts the Japanese to the same English)
## "This statement was made by the Minister of Land, Infrastructure, Transport
## and Tourism, Hiroshi Tabata, on January 6, 2022, during a press conference."
commentaryAuthorEN <- "Hiroshi Tabata\n" 
commentaryAuthor <- "田畑浩志"
## Google Translate
commentaryDate <- "2022 年 1 月 6 日"
commentaryTextEN <- '"The COVID-19 pandemic has had a significant impact on the tourism industry. We will continue to take measures to prevent the spread of infection and strengthen efforts to restore tourism demand."'
commentaryText <- "新型コロナウイルス感染症は、観光業にとって大きな打撃となっています。今後も感染拡大防止に万全を期し、観光需要を取り戻すための取り組みを強化してまいります。"
    
library(xdvir)
options(xdvir.ttxCacheDir="/scratch/TTXfonts/")
fontMap("Ryumin-Light"="IPAPMincho", "GothicBBB-Medium"="IPAPGothic")
ylabeldvi <- readDVI("ylabel.dvi")
ylabelgrob <- dviGrob(ylabeldvi, engine=uplatexEngine)
commentarydvi <- readDVI("commentary.dvi")
commentarygrob <- dviGrob(commentarydvi, engine=uplatexEngine,
                          x=1, y=1, hjust="right", vjust="top")

library(ggplot2)

ggh <- ggplot(subset) +
    geom_col(aes(month, entries), fill=adjustcolor(4, alpha=.5)) +
    scale_y_continuous(breaks=1e6*1:4, labels=1e3*1:4,
                       expand=expansion(c(0, NA))) +
    scale_x_date(expand=expansion(c(0, NA))) +
    ## labs(title="出入国者（千人）") + ## Those entering/departing the country
    ## Those entering/departing the country (thousand persons)
    labs(title="出入国者（千人）") +
    ## Number of entries (Total)
    ## ylab("入（帰）国者数（総数）")
    ## Number of immigrants
    ylab("入国者数") +
    theme(axis.title.x=element_blank(),
          axis.title.y=element_text(size=9),
          panel.background=element_blank(),
          panel.grid=element_blank())

library(gggrid)

ggv <- ggh +
    grid_panel(commentarygrob) +
    theme(axis.title.y=element_blank())

## Changes required to 'textshaping::shape_text()' to make this more
## convenient
library(textshaping)
library(systemfonts)
strings <- c(commentaryAuthorEN, commentaryTextEN)
boldfont <- match_font("DejaVu", bold=TRUE)
italicfont <- match_font("DejaVu", italic=TRUE)
shaped <- shape_text(strings,
                     id=c(1, 1),
                     bold=c(TRUE, FALSE),
                     italic=c(FALSE, TRUE),
                     size=c(14, 10),
                     path=c(boldfont$path, italicfont$path),
                     align="right",
                     width=3.5)
keep <- shaped$shape$index != 0
fontList <-
    glyphFontList(glyphFont(boldfont$path,
                            0, "DejaVu", 700, "normal"),
                  glyphFont(italicfont$path,
                            0, "DejaVu", 400, "oblique"))
glyph <- glyphInfo(shaped$shape$index[keep],
                   shaped$shape$x_offset[keep],
                   shaped$shape$y_offset[keep],
                   rep(1:2, c(14, nrow(shaped$shape[keep,]) - 14)),
                   rep(c(14, 10), c(14, nrow(shaped$shape[keep,]) - 14)),
                   fontList,
                   shaped$metric$width,
                   shaped$metric$height)                                    

ggen <- ggplot(subset) +
    geom_col(aes(month, entries), fill=adjustcolor(4, alpha=.5)) +
    grid_panel(glyphGrob(glyph, 1, 1, hjust="right", vjust="top")) +
    scale_y_continuous(breaks=1e6*1:4, labels=1e3*1:4,
                       expand=expansion(c(0, NA))) +
    scale_x_date(expand=expansion(c(0, NA))) +
    labs(title="Those entering/departing the country (thousand persons)") +
    ylab("Number of immigrants") +
    theme(axis.title.x=element_blank(),
          axis.title.y=element_text(size=9),
          panel.background=element_blank(),
          panel.grid=element_blank())


library(grid)
margin <- viewport(width=unit(1, "npc") - unit(2, "cm"),
                   height=unit(1, "npc") - unit(2, "cm"))

png("migration-horizontal.png", width=600, height=400, res=96)
pushViewport(margin)
print(ggh, newpage=FALSE)
dev.off()

png("migration-vertical.png", width=600, height=400, res=96)
width <- unit(5, "mm")
pushViewport(margin)
pushViewport(viewport(x=1, width=unit(1, "npc") - width, just="right"))
print(ggv, newpage=FALSE)
upViewport()
pushViewport(viewport(x=0, width=width, just="left"))
grid.draw(ylabelgrob)
upViewport()
dev.off()

png("migration-horizontal-en.png", width=600, height=400, res=96)
pushViewport(margin)
print(ggen, newpage=FALSE)
dev.off()

