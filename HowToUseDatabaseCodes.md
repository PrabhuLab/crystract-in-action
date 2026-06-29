# Database Access and Data Preparation Guide

This guide provides step-by-step instructions and R scripts to reproduce the dataset used in the `crystract` processing pipeline. It covers how to acquire and organize the Crystallographic Information Files (CIFs) for both the Clathrate and Mineral datasets from the Inorganic Crystal Structure Database (ICSD) and the American Mineralogist Crystal Structure Database (AMCSD).

## 1. ICSD Data Access (Clathrates)

As noted by the database's limitations, it is difficult to query a bulk list of specific collection codes without the ICSD API. To reproduce the Clathrate dataset, you must perform a bulk download based on the structural type.

### Instructions:
1. Log into the [ICSD Web Portal](https://icsd.fiz-karlsruhe.de/) (requires an institutional subscription).
2. Go to the Advanced Search interface and search for the specific structure type (e.g., `K8Si46` for Clathrate Type I).
3. Select all the resulting entries and export/download them in `.cif` format to a local folder (e.g., `ICSD_Bulk_Downloads`).
4. *Note:* One file in the dataset (`Ca-B-C-clatI-2338100-corr.cif` / `CCDC 2338100`) is hosted on the Cambridge Crystallographic Data Centre (CCDC) and must be downloaded individually from the free [Access Structures portal](https://www.ccdc.cam.ac.uk/structures/).

### Data Preparation Script (R)
Our pipeline expects the clathrate CIFs to be organized into subdirectories based on their structural category (e.g., `6c-16i-24k`, `24k-48l`). Once you have bulk-downloaded the CIFs into a single directory, you can use the R script below alongside the provided `materials_database_codes.csv` to automatically route them into the proper directory structure:

```R
# 1. Define paths
bulk_download_dir <- "./ICSD_Bulk_Downloads"
pipeline_input_dir <- "./clathrates"

# 2. Load the mapping CSV
df <- read.csv("materials_database_codes.csv", stringsAsFactors = FALSE)

# 3. Create necessary structural category subdirectories
categories <- na.omit(unique(df$Category))
for (category in categories) {
  dir.create(file.path(pipeline_input_dir, category), recursive = TRUE, showWarnings = FALSE)
}

# 4. Route each downloaded CIF to its proper folder
cat("Routing CIF files to structural categories...\n")
for (i in 1:nrow(df)) {
  filename <- df$File[i]
  category <- df$Category[i]

  if (!is.na(category) && category != "") {
    src <- file.path(bulk_download_dir, filename)
    dest <- file.path(pipeline_input_dir, category, filename)

    if (file.exists(src)) {
      file.copy(from = src, to = dest, overwrite = TRUE)
    } else {
      cat(sprintf("Missing file from bulk download: %s\n", filename))
    }
  }
}
cat("ICSD routing complete.\n")
```

## 2. AMCSD Data Access (Minerals)

The Mineral dataset (used for analyzing Sulfides, Selenides, and Tellurides) uses data from the open-access American Mineralogist Crystal Structure Database (AMCSD). AMCSD provides a single compressed archive containing all CIFs. The list of required files for our pipeline is provided in `minerals_database_codes.csv`.

### Instructions:
1. Download the complete AMCSD CIF archive directly from this URL: [https://www.rruff.net/AMS/zipped_files/cif.zip](https://www.rruff.net/AMS/zipped_files/cif.zip).
2. You can either extract it manually, or use the R script below to automate the download, extraction, and filtering of the specific CIFs needed for the workflow.

### Data Preparation Script (R)
This R script downloads the bulk `.zip` file, extracts it, and copies only the specific files required by `minerals_database_codes.csv` into your pipeline input directory.

```R
# 1. Define paths
zip_url <- "https://www.rruff.net/AMS/zipped_files/cif.zip"
zip_path <- "./cif.zip"
bulk_extract_dir <- "./AMCSD_Bulk_Downloads"
pipeline_input_dir <- "./chalcogens"

dir.create(bulk_extract_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(pipeline_input_dir, recursive = TRUE, showWarnings = FALSE)

# 2. Download and Extract the AMCSD bulk zip file
cat("Downloading AMCSD bulk zip...\n")
download.file(url = zip_url, destfile = zip_path, mode = "wb")

cat("Extracting files...\n")
unzip(zipfile = zip_path, exdir = bulk_extract_dir)

# 3. Load the mapping CSV
df <- read.csv("minerals_database_codes.csv", stringsAsFactors = FALSE)

# 4. Route the required CIFs to the pipeline directory
cat("Filtering required CIF files...\n")
missing_files <- character(0)

for (i in 1:nrow(df)) {
  filename <- df$File[i]
  db_code <- df$Database_Code[i]

  # In the AMCSD zip, files are typically named exactly by their AMCSD ID
  # (e.g., "0010584.cif"). We extract that ID from the CSV.
  if (!is.na(db_code) && grepl("^amcsd ", db_code)) {
    amcsd_id <- trimws(sub("^amcsd ", "", db_code))
    expected_filename <- paste0(amcsd_id, ".cif")

    src <- file.path(bulk_extract_dir, expected_filename)
    dest <- file.path(pipeline_input_dir, filename) # Saving as the specific name used in the pipeline

    if (file.exists(src)) {
      file.copy(from = src, to = dest, overwrite = TRUE)
    } else {
      missing_files <- c(missing_files, filename)
    }
  } else {
    # Catch non-standard codes or unindexed files
    missing_files <- c(missing_files, filename)
  }
}

cat(sprintf("Extraction complete. %d files require manual review.\n", length(missing_files)))
```

## 3. Pipeline Integration

Once both datasets are downloaded and properly organized into their directory structures using the R scripts above, you are ready to run the main data pipelines:
1. Open the primary R Markdown notebooks.
2. For the **Clathrates** workflow, ensure the `cif_root_dir` variable is updated to point to your new `clathrates` directory.
3. For the **Minerals** workflow, ensure the `cif_directory` variable is updated to point to your new `chalcogens` directory.
4. Execute the notebooks to reproduce the filtering logic, ghost removal, and geometric extractions.
