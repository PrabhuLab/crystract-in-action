library(crystract)
library(data.table)
library(future)
library(future.apply)
lines <- readLines("minerals/natural.Rmd")
start <- grep("^custom_radii_values <-", lines)[1]
end <- which(seq_along(lines) > start & lines == "```")[1]
eval(parse(text = lines[start:(end - 1)]))
start <- grep("^process_structure_robust <-", lines)[1]
end <- grep("^# --- Execution Loop ---", lines)[1]
eval(parse(text = lines[start:(end - 1)]))
args <- commandArgs(trailingOnly = TRUE)
path <- if (length(args)) args[1] else system.file("extdata", "2405219.cif", package = "crystract")
serial <- process_structure_robust(path)
plan(multisession, workers = 2)
parallel_result <- future_lapply(path, process_structure_robust, future.seed = TRUE)[[1]]
plan(sequential)
stopifnot(serial$filter_status == "applied", parallel_result$filter_status == "applied",
          isTRUE(all.equal(serial$bonds_econ[[1]], parallel_result$bonds_econ[[1]])))
cat("Serial and parallel mineral bond tables agree with the configured radius table.\n")

if (length(args) > 1L) {
  invalid <- process_structure_robust(args[2])
  stopifnot(invalid$filter_status == "invalid_site_occupancy")
  cat("Over-occupied sites are explicitly rejected.\n")
}
