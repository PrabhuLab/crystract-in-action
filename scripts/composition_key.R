# Parse plain sum formulas, including grouped occupancies; leave other notation unresolved.
composition_key <- function(formula) {
  vapply(formula, function(value) {
    if (is.na(value) || !nzchar(value)) return(NA_character_)
    value <- gsub("[[:space:]'\"]", "", value)
    tokens <- regmatches(value, gregexpr("[A-Z][a-z]?|[0-9]*\\.?[0-9]+|[()]", value))[[1]]
    if (!length(tokens) || paste0(tokens, collapse = "") != value) return(NA_character_)
    i <- 1L
    parse_group <- function(nested = FALSE) {
      amounts <- numeric()
      while (i <= length(tokens) && tokens[i] != ")") {
        token <- tokens[i]; i <<- i + 1L
        if (token == "(") {
          group <- parse_group(TRUE)
        } else if (grepl("^[A-Z][a-z]?$", token)) {
          group <- setNames(1, token)
        } else stop("Unsupported formula")
        multiplier <- 1
        if (i <= length(tokens) && grepl("^[0-9.]", tokens[i])) {
          multiplier <- as.numeric(tokens[i]); i <<- i + 1L
        }
        for (element in names(group)) {
          old <- if (element %in% names(amounts)) amounts[element] else 0
          amounts[element] <- old + group[element] * multiplier
        }
      }
      if (nested) {
        if (i > length(tokens) || tokens[i] != ")") stop("Unbalanced formula")
        i <<- i + 1L
      }
      amounts
    }
    totals <- tryCatch(parse_group(), error = function(e) NULL)
    if (is.null(totals) || i <= length(tokens) || !length(totals) ||
        any(!is.finite(totals)) || any(totals <= 0)) return(NA_character_)
    totals <- totals[order(names(totals))]
    paste(names(totals), sprintf("%.6f", totals / sum(totals)), collapse = ";")
  }, character(1), USE.NAMES = FALSE)
}
