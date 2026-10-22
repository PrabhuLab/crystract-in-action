prepare_amcsd <- function(mapping_csv, source_dir, output_dir) {
  mapping <- read.csv(mapping_csv, stringsAsFactors = FALSE)
  stopifnot(all(c("File", "Database_Code") %in% names(mapping)), dir.exists(source_dir))
  paths <- list.files(source_dir, "\\.cif$", recursive = TRUE, full.names = TRUE, ignore.case = TRUE)
  ids <- sub(".*?([0-9]{7})\\.cif$", "\\1", basename(paths), ignore.case = TRUE)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  report <- data.frame(File = mapping$File, Database_Code = mapping$Database_Code,
                       Status = "missing", Source = NA_character_)
  for (i in seq_len(nrow(mapping))) {
    id <- sub("^amcsd\\s+", "", mapping$Database_Code[i], ignore.case = TRUE)
    candidates <- if (!is.na(id) && grepl("^[0-9]{7}$", id)) paths[ids == id] else paths[basename(paths) == mapping$File[i]]
    # Prefer the requested filename when an archive contains multiple versions.
    exact <- candidates[basename(candidates) == mapping$File[i]]
    if (length(exact) == 1L) candidates <- exact
    if (length(candidates) != 1L) {
      if (length(candidates) > 1L) report$Status[i] <- "ambiguous"
      next
    }
    report$Source[i] <- candidates
    report$Status[i] <- if (file.copy(candidates, file.path(output_dir, mapping$File[i]), overwrite = TRUE)) "copied" else "copy_failed"
  }
  write.csv(report, file.path(output_dir, "preparation_report.csv"), row.names = FALSE)
  if (any(report$Status != "copied")) warning(sum(report$Status != "copied"), " records require review; see preparation_report.csv")
  report
}
