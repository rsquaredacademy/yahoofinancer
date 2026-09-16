# tools/build_site.R
# Rebuild the pkgdown documentation site and ensure the reference index catalog
# is not overwritten by the case-insensitive alias redirect for Index.html.

if (!requireNamespace("pkgdown", quietly = TRUE)) {
  stop("pkgdown package is required to build the site.", call. = FALSE)
}

pkgdown::build_site()
unlink("docs/reference/index.html", force = TRUE)
pkgdown::build_reference_index()
