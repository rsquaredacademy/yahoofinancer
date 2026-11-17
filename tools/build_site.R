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
# not the public site. pkgdown renders every top-level .md, so drop the pages
# and their sitemap entries, then rebuild the search index without them.
unlink(Sys.glob(file.path("docs", c("AGENTS.*", "GEMINI.*", "CLAUDE.*"))), force = TRUE)
agent_page <- r"((AGENTS|GEMINI|CLAUDE)\.html)"
sm <- paste(readLines("docs/sitemap.xml", warn = FALSE), collapse = "\n")
sm <- gsub(paste0(r"(\s*<url>\s*<loc>[^<]*)", agent_page, r"(</loc>\s*</url>)"), "", sm, perl = TRUE)
writeLines(sm, "docs/sitemap.xml")
pkgdown::build_search()
