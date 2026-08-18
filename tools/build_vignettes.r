# tools/build_vignettes.R
# Run this script whenever you update recipe code or want fresh output

if (!requireNamespace("knitr", quietly = TRUE)) install.packages("knitr")

# Ensure working directory is package root
orig_file <- "vignettes/cookbook.Rmd.orig"
out_file  <- "vignettes/cookbook.Rmd"

if (file.exists(orig_file)) {
  message("Pre-computing vignette: ", orig_file)
  knitr::knit(input = orig_file, output = out_file)
  message("Generated: ", out_file)
}