# tools/build_vignettes.r
# Run this script whenever you update recipe code or want fresh output

if (!requireNamespace("knitr", quietly = TRUE)) install.packages("knitr")

orig_file <- "cookbook.Rmd.orig"
out_file  <- "cookbook.Rmd"

old_wd <- setwd("vignettes")
on.exit(setwd(old_wd), add = TRUE)

if (file.exists(orig_file)) {
  message("Pre-computing vignette: vignettes/", orig_file)
  knitr::knit(input = orig_file, output = out_file)
  message("Generated: vignettes/", out_file)
}