## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 6,
  fig.height = 6
)

## ------------------------------------------------------------------------
library("cranly")
library("magrittr")
cran_db <- clean_CRAN_db()
package_network <- cran_db %>% build_network(perspective = "package")
author_network <- cran_db %>% build_network(perspective = "author")

## ------------------------------------------------------------------------
package_network %>% package_by("Kurt Hornik", exact = TRUE)

## ------------------------------------------------------------------------
package_network %>% package_by("Ioannis")

## ------------------------------------------------------------------------
author_network %>% package_with("glm")

## ------------------------------------------------------------------------
package_network %>% author_of("lubridate", exact = TRUE)

## ------------------------------------------------------------------------
package_network %>% author_with("Ioan")

## ------------------------------------------------------------------------
package_network %>% suggested_by("sf", exact = TRUE)
package_network %>% imported_by("sf", exact = TRUE)
package_network %>% enhanced_by("sf", exact = TRUE)

## ------------------------------------------------------------------------
package_network %>% suggesting("sf", exact = TRUE)
package_network %>% importing("sf", exact = TRUE)
package_network %>% enhancing("sf", exact = TRUE)

## ------------------------------------------------------------------------
package_network %>% depending_on("sf", exact = TRUE)

## ------------------------------------------------------------------------
package_network %>% dependency_of("sf", exact = TRUE)

## ------------------------------------------------------------------------
package_network %>% maintained_by("Helen")

## ------------------------------------------------------------------------
package_network %>% maintained_by("Helen", flat = FALSE) %>% dim()

## ------------------------------------------------------------------------
package_network %>% maintainer_of("data.table", exact = TRUE)

## ------------------------------------------------------------------------
trackeRapp_maintainer <- package_network %>% maintainer_of("trackeRapp", exact = TRUE)
package_network %>% email_of(trackeRapp_maintainer, exact = TRUE)

## ------------------------------------------------------------------------
package_network %>% email_with("warwick.ac.uk")

## ------------------------------------------------------------------------
package_network %>% title_of("semnar", exact = TRUE)
package_network %>% description_of("semnar", exact = TRUE)
package_network %>% version_of("semnar", exact = TRUE)

## ------------------------------------------------------------------------
package_network %>% release_date_of(Inf) %>%
    hist(breaks = 50, main = "", xlab = "date", freq = TRUE)

## ----warning = FALSE-----------------------------------------------------
word_cloud(package_network, maintainer = "Ioannis Kosmidis", exact = TRUE, min.freq = 1)
word_cloud(package_network, maintainer = "Achim Zeileis", exact = TRUE, min.freq = 1)
word_cloud(package_network, maintainer = "Edzer Pebesma", exact = TRUE, min.freq = 1)

## ----warning = FALSE, message = FALSE------------------------------------
word_cloud(package_network, maintainer = "Ioannis Kosmidis", perspective = "title", exact = TRUE,
           scale = c(2, 0.1), min.freq = 1)
word_cloud(package_network, maintainer = "Achim Zeileis", perspective = "title", exact = TRUE,
           scale = c(2, 0.1), min.freq = 1)
word_cloud(package_network, maintainer = "Edzer Pebesma", perspective = "title", exact = TRUE,
           scale = c(2, 0.1), min.freq = 1)

## ----warning = FALSE-----------------------------------------------------
warwick_emails <- package_network %>% email_with("warwick.ac.uk", flat = FALSE)
warwick_pkgs  <- warwick_emails$package
descriptions <- package_network %>% description_of(warwick_pkgs, exact = FALSE)
term_frequency <- compute_term_frequency(descriptions)
word_cloud(term_frequency, min.freq = 1)

