# Copyright (C) 2018- Ioannis Kosmidis

#' Compute edges and nodes of package directives and collaboration networks
#'
#' @param object a [`cranly_db`] object. If missing (default) a call to [clean_CRAN_db()] is issued.
#' @param trace logical. Print progress information? Default is [`FALSE`].
#' @param perspective character. Should a `"package"` (default) or an `"author"` network be built?
#' @param ... Other arguments passed in [clean_CRAN_db()] when `object` is `NULL`.
#'
#' @aliases cranly_network build_network
#'
#' @return
#'
#' A list of 2 [`data.frame`] objects with the `edges` and `nodes` of the network.
#'
#' @details
#'
#' The convention for a [`cranly_network`] object with
#' `perspective = "package"` is that the direction of an edge is
#' from the package that is imported by, suggested by, enhances or is
#' a dependency of another package, to the latter package. The author
#' collaboration network is analyzed and visualized as undirected by
#' all methods in `cranly`.
#'
#'
#' @seealso
#' [clean_CRAN_db()] [subset.cranly_network()] [plot.cranly_network()] [`extractor-functions`]
#'
#' @examples
#' \donttest{
#' cran_db <- clean_CRAN_db()
#'
#' ## Build package directives network
#' package_network <- build_network(object = cran_db, perspective = "package")
#' head(package_network$edges)
#' head(package_network$nodes)
#' attr(package_network, "timestamp")
#' class(package_network)
#'
#' ## Build author collaboration network
#' author_network <- build_network(object = cran_db, perspective = "author")
#' head(author_network$edges)
#' head(author_network$nodes)
#' attr(author_network, "timestamp")
#' class(author_network)
#' }
#'
#' @export
build_network.cranly_db <- function(object,
                                    trace = FALSE, perspective = "package", ...) {

    perspective <- match.arg(perspective, c("package", "author"))

    if (missing(object)) {
        object <- clean_CRAN_db(...)
    }

    if (isTRUE(length(object) == 0)) {
        edges <- nodes <- data.frame()
    }
    else {

        if (perspective == "package") {
            compute_edges <- function(what = "imports", rev = FALSE) {
                out <- object[[what]]
                names(out) <- object[["package"]]
                out <- stack(out[sapply(out, function(x) !all(is.na(x)))])
                out$ind <- as.character(out$ind)
                ## out <- stack(lapply(out, function(x) x[x != "" & x != "R"]))
                names(out) <- if (rev) c("to", "from") else c("from", "to")
                data.frame(out[, c("from", "to")], type = what, stringsAsFactors = FALSE)
            }

            im <- compute_edges(what = "imports")
            su <- compute_edges(what = "suggests")
            en <- compute_edges(what = "enhances", rev = TRUE)
            de <- compute_edges(what = "depends")
            li <- compute_edges(what = "linking_to")

            ## Edges
            edges <- rbind(im, su, en, de, li)

            nodes <- merge(data.frame(package = unique(c(edges$from, edges$to)), stringsAsFactors=FALSE),
                           object, by = "package", all = TRUE) ## all.x in previous version

            ## NA in enhances, imports etc indicates that no information
            ## is available about that package (e.g being from
            ## bioconductor). character(0) on the other hand means that
            ## there is no package in enhances, imports, etc.

            base_packages <- utils::installed.packages(priority = "high")
            base_package_names <- unique(base_packages[, "Package"])

            inds <- which(base_package_names %in% nodes$package)
            nodes$priority <- as.character(nodes$priority)
            nodes[nodes$package %in% base_package_names, "priority"] <- base_packages[inds, "Priority"]

        }
        else {
            if (all(is.na(unlist(object$author)))) {
                stop("no author information found")
            }

            edges <- apply(object, 1, function(x) {
                auth <- x$author
                if (length(auth) < 2)
                    NULL
                else {
                    d <- data.frame(t(combn(auth, 2)), stringsAsFactors = FALSE)
                    d[["package"]] <- x$package
                    d[["imports"]] <- unname(x["imports"])
                    d[["suggests"]] <- unname(x["suggests"])
                    d[["enhances"]] <- unname(x["enhances"])
                    d[["depends"]] <- unname(x["depends"])
                    d[["linking_to"]] <- unname(x["linking_to"])
                    d[["version"]] <- x$version
                    d[["maintainer"]] <- x$maintainer
                    d
                }
            })

            edges <- do.call("rbind", edges)

            names(edges)[1:2] <- c("from", "to")

            nodes <- do.call("rbind", apply(object[c("author", "package")], 1, function(x) {
                                          auth <- x$author
                                          matrix(c(auth, rep(x$package, length(auth))), ncol = 2)
                                      }))

            nodes <- do.call("rbind", lapply(unique(nodes[, 1]), function(auth) {
                                          d <- data.frame(author = auth, stringsAsFactors = FALSE)
                                          d[["package"]] <- list(nodes[nodes[, 1] == auth, 2])
                                          d
                                      }))
        }
    }
    out <- list(edges = edges, nodes = nodes)
    class(out) <- c("cranly_network", class(out))
    attr(out, "timestamp") <- attr(object, "timestamp")
    attr(out, "perspective") <- perspective
    out

}


