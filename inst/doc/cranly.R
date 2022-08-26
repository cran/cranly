## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 6,
  fig.height = 6
)

## -----------------------------------------------------------------------------
library("cranly")

## -----------------------------------------------------------------------------
cran_db <- readRDS(url("https://raw.githubusercontent.com/ikosmidis/cranly/develop/inst/extdata/cran_db.rds"))

## ----eval = FALSE-------------------------------------------------------------
#  p_db <- tools::CRAN_package_db()

## ----eval = FALSE-------------------------------------------------------------
#  cran_db <- clean_CRAN_db(p_db)

## -----------------------------------------------------------------------------
attr(cran_db, "timestamp")

## -----------------------------------------------------------------------------
package_network <- build_network(cran_db)

## -----------------------------------------------------------------------------
## Global package network statistics
package_summaries <- summary(package_network)

## -----------------------------------------------------------------------------
plot(package_summaries, according_to = "n_authors", top = 20)
plot(package_summaries, according_to = "n_imports", top = 20)
plot(package_summaries, according_to = "n_imported_by", top = 20)

## -----------------------------------------------------------------------------
names(package_summaries)

## -----------------------------------------------------------------------------
my_packages <- package_by(package_network, "Ioannis Kosmidis")
my_packages

## -----------------------------------------------------------------------------
plot(package_network, package = my_packages, title = TRUE, legend = TRUE)

## -----------------------------------------------------------------------------
optional_packages <- subset(package_network, recommended = FALSE, base = FALSE)
optional_summary <- summary(optional_packages)
plot(optional_summary, top = 30, according_to = "n_imported_by")

## -----------------------------------------------------------------------------
author_network <- build_network(object = cran_db, perspective = "author")

## -----------------------------------------------------------------------------
author_summaries <- summary(author_network)

## -----------------------------------------------------------------------------
plot(author_summaries, according_to = "n_packages", top = 20)
plot(author_summaries, according_to = "page_rank", top = 20)
plot(author_summaries, according_to = "betweenness", top = 20)

## -----------------------------------------------------------------------------
plot(author_network, author = "R Core")

