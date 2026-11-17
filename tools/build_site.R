# tools/build_site.R
# Rebuild the pkgdown documentation site and ensure the reference index catalog
# is not overwritten by the case-insensitive alias redirect for Index.html.

if (!requireNamespace("pkgdown", quietly = TRUE)) {
  stop("pkgdown package is required to build the site.", call. = FALSE)
}

pkgdown::build_site()
unlink("docs/reference/index.html", force = TRUE)
pkgdown::build_reference_index()

# Agent instruction files (AGENTS.md, GEMINI.md) are for contributors' tools,
# not the public site; pkgdown renders every top-level .md, so drop them and
# rebuild the sitemap and search index without them.
unlink(Sys.glob(file.path("docs", c("AGENTS.*", "GEMINI.*", "CLAUDE.*"))), force = TRUE)
pkgdown::build_sitemap()
pkgdown::build_search()
