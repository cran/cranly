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
package_network <- readRDS(url("https://raw.githubusercontent.com/ikosmidis/cranly/develop/inst/extdata/package_network.rds"))

## ----eval = FALSE-------------------------------------------------------------
#  cran_db <- clean_CRAN_db()
#  package_network <- build_network(cran_db)

## -----------------------------------------------------------------------------
 compute_dependence_tree(package_network, "brglm2")

## -----------------------------------------------------------------------------
compute_dependence_tree(package_network, "tibble")

## -----------------------------------------------------------------------------
tibble_tree <- build_dependence_tree(package_network, "tibble")
plot(tibble_tree)

## -----------------------------------------------------------------------------
betareg_tree <- build_dependence_tree(package_network, "betareg")
betareg_dep_index <- sapply(betareg_tree$nodes$package, function(package) {
    tree <- build_dependence_tree(package_network, package = package)
    s <- summary(tree)
    s$dependence_index
})
sort(betareg_dep_index)

