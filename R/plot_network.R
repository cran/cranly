# Copyright (C) 2018- Ioannis Kosmidis

#' Interactive visualization of a package or author [`cranly_network`]
#'
#' @inheritParams subset.cranly_network
#' @inheritParams summary.cranly_network
#' @inheritParams visNetwork::visNetwork
#' @param physics_threshold integer. How many nodes before switching off physics simulations for edges? Default is `200`. See, also [visNetwork::visEdges()].
#' @param dragNodes logical. Should the user be able to drag the nodes that are not fixed? Default is [`TRUE`].
#' @param dragView logical. Should the user be able to drag the view around? Default is [`TRUE`].
#' @param zoomView logical. Should the user be able to zoom in? Default is [`TRUE`].
#' @param legend logical. Should a legend be added on the resulting visualization? Default is [`TRUE`].
#' @param title logical. Should a title be added on the resulting visualization? Default is [`TRUE`].
#' @param global logical. If `TRUE` (default) the network summary statistics are computed on `object`, otherwise, on the subset of `object` according to `package`, `author`, `directive`, `base`, `recommended`.
#' @param plot logical. Should the visualization be returned? Default is [`TRUE`].
#' @param ... currently not used.
#'
#' @examples
#' \donttest{
#' cran_db <- clean_CRAN_db()
#' package_network <- build_network(cran_db)
#'
#' ## The package directives network of all users with Ioannis in
#' ## their name from the CRAN database subset crandb
#' plot(package_network, author = "Ioannis", exact = FALSE)
#' ## The package directives network of "Achim Zeileis"
#' plot(package_network, author = "Achim Zeileis")
#'
#' author_network <- build_network(cran_db, perspective = "author")
#' plot(author_network, author = "Ioannis", exact = FALSE, title = TRUE)
#' }
#' @export
plot.cranly_network <- function(x,
                                package = Inf,
                                author = Inf,
                                directive = c("imports", "suggests", "enhances", "depends", "linking_to"),
                                base = TRUE,
                                recommended = TRUE,
                                exact = TRUE,
                                global = TRUE,
                                physics_threshold = 200,
                                height = NULL, #"1080px",
                                width = NULL, #"1080px",
                                dragNodes = TRUE,
                                dragView = TRUE,
                                zoomView = TRUE,
                                legend = TRUE,
                                title = TRUE,
                                plot = TRUE,
                                ...) {
    if (!has_usable_data(x)) {
        message("The supplied object has no package or author information. Nothing to plot")
        return(invisible(NULL))
    }

    if (global) {
        summaries <- summary(x, advanced = FALSE)
    }

    x <- subset(x, package = package, author = author, directive = directive, exact = exact,
                base = base, recommended = recommended)

    if (!global) {
        summaries <- summary(x, advanced = FALSE)
    }
    timestamp <- attr(x, "timestamp")

    if (nrow(x$nodes) == 0) {
            message("Nothing to plot [exact = ", exact, "]")
            return(invisible(NULL))
    }

    edges_subset <- x$edges
    nodes_subset <- x$nodes
    colors <- colorspace::diverge_hcl(10, c = 100, l = c(50, 100), power = 1)
    perspective <- attr(x, "perspective")
    keep <- attr(x, "keep")
    lnodes <- ledges <- main <- NULL

    if (perspective == "package") {
        edges_subset <- within(edges_subset, {
            color <- str_replace_all(type,
                                     c("imports" = colors[10],
                                       "depends" = colors[10],
                                       "suggests" = colors[4],
                                       "enhances" = colors[4],
                                       "linking_to" = colors[7]))
            dashes <- ifelse(type %in% c("imports", "depends", "suggests"), FALSE, TRUE)
            title <- str_replace_all(type,
                                     c("imports" = "is imported by",
                                       "depends" = "is dependency of",
                                       "suggests" = "is suggested by",
                                       "enhances" = "enhances",
                                       "linking_to" = "is linked by"))
        })
        summaries <- summaries[nodes_subset$package, ]
        nodes_subset <- within(nodes_subset, {
            color <- ifelse(package %in% keep, colors[1], colors[5])
            label <- package
            id <- package
            title <- paste0("<a href=https://CRAN.R-project.org/package=", package, ">", package, "</a> (", version, ")<br>",
                            "Maintainer: ", maintainer, "<br>",
                            "imports/imported by:", summaries$n_imports, "/", summaries$n_imported_by, "<br>",
                            "depends/is dependency of:", summaries$n_depends, "/", summaries$n_depended_by, "<br>",
                            "suggests/suggested by:", summaries$n_suggests, "/", summaries$n_suggested_by, "<br>",
                            "enhances/enhaced by:", summaries$n_enhances, "/", summaries$n_enhanced_by, "<br>",
                            "linking_to/linked by:", summaries$n_linking, "/", summaries$n_linked_by, "<br>",
                            "<img src=https://cranlogs.r-pkg.org/badges/", package, "?color=969696>")
        })

        ## legend
        if (legend) {
            lnodes <- data.frame(label = c("Packages matching query", "Neighbouring packages"),
                                 color = c(colors[1], colors[5]),
                                 font.align = "top")

            ledges <- data.frame(label = c("is imported by", "is dependency of", "is suggested by", "enhances", "is linked by"),
                                 color = c(colors[10], colors[10], colors[4], colors[4], colors[7]),
                                 dashes = c(FALSE, FALSE, FALSE, TRUE, TRUE),
                                 arrows = c("to", "to", "to", "to", "to"),
                                 font.align = "top")
        }
x
        if (title) {
            main <- paste(
                paste0("cranly package network<br>"),
                paste0("CRAN database version<br>", format(timestamp, format = "%a, %d %b %Y, %H:%M"), collapse = ""),
                "<br>",
                if (any(is.infinite(package))) "" else paste0("Package names with<br> \"", paste(package, collapse = "\", \""), "\"", collapse = ""),
                "<br>",
                if (any(is.infinite(author))) "" else paste0("Author names with<br> \"", paste(author, collapse = "\", \""), "\"", collapse = ""))
        }
    }
    else {
        edges_subset <- within(edges_subset, {
            title <- paste("collaborate in:", package)
            color <- colors[1]
        })

        format_fun <- function(vec) {
            n_items <- length(vec)
            n_full_rows <- n_items %/% 4
            n_last_row <- n_items %% 4
            ind <- c(if (n_full_rows > 0) rep(seq.int(n_full_rows), each = 4) else NULL,
                     rep(n_full_rows + 1, n_last_row))
            paste(tapply(vec, ind, function(x) paste(x, collapse = ", ")), collapse = "<br>")
        }
        summaries <- summaries[nodes_subset$author, ]

        nodes_subset <- within(nodes_subset, {
            color <- ifelse(author %in% keep, colors[1], colors[5])
            label <- author
            id <- author
            title <- paste0("Author: ", author, "<br>",
                            summaries$n_collaborators, " collaborators in ",
                            unlist(lapply(nodes_subset$package, length)),
                            " packages: <br>", unlist(lapply(nodes_subset$package, format_fun)))
        })

        if (legend) {
            lnodes <- data.frame(label = c("Authors matching query", "Collaborators"),
                                 color = c(colors[1], colors[5]))
        }

        if (title) {
            main <- paste(
                paste0("cranly collaboration network<br>"),
                paste0("CRAN database version<br>", format(timestamp, format = "%a, %d %b %Y, %H:%M"), collapse = ""),
                "<br>",
                if (!is.null(author)) paste0("Author names with<br> \"", paste(author, collapse = "\", \""), "\"", collapse = ""),
                "<br>",
                if (!is.null(package)) paste0("Package names with<br> \"", paste(package, collapse = "\", \""), "\"", collapse = ""))
        }
    }

    export_name <- paste0("cranly_network-", format(timestamp, format = "%d-%b-%Y"), "-", paste0(c(author, package), collapse = "-"))

    ## Keep only relevant information
    nodes_subset <- nodes_subset[match(c("color", "label", "id", "title"), names(nodes_subset), nomatch = 0)]
    edges_subset <- edges_subset[match(c("from", "to", "color", "title", "dashes"), names(edges_subset), nomatch = 0)]
    res <- visNetwork::visNetwork(nodes_subset, edges_subset, height = height, width = width,
                           main = list(text = main,
                                       style = "font-family:Georgia, Times New Roman, Times, serif;font-size:15px")) |>
        visNetwork::visEdges(arrows = if (perspective == "author") NULL else list(to = list(enabled = TRUE, scaleFactor = 0.5)),
                             physics = nrow(nodes_subset) < physics_threshold) |>
            visNetwork::visOptions(highlightNearest = TRUE) |>
            visNetwork::visLegend(addNodes = lnodes, addEdges = ledges, useGroups = FALSE) |>
            visNetwork::visInteraction(dragNodes = dragNodes, dragView = dragView, zoomView = zoomView) |>
            visNetwork::visExport(name = export_name, label = "PNG snapshot", style = "")
    if (plot) {
        return(res)
    }
    else {
        return(invisible(res))
    }
}


