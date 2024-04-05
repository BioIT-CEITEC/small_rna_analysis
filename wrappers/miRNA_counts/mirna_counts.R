library(openxlsx)
library(dplyr)
library(readr)
library(data.table)
library(rio)
library(isomiRs)

counts_all <- function(args) {
  input_dir <- args[1]
  setwd(input_dir)

  fn_list <- list.files(path = input_dir, pattern = ".mirna$", full.names = TRUE)
  names <- gsub(".mirna", "", basename(fn_list))

  for (name in names) {
    folder_path_canonical <- file.path("../qc_reports", name, "mirbase_canonical")
    folder_path_isomiRs <- file.path("../qc_reports", name, "mirbase_isomiRs")
    dir.create(folder_path_canonical, recursive = TRUE, showWarnings = FALSE)
    dir.create(folder_path_isomiRs, recursive = TRUE, showWarnings = FALSE)
  }

  de <- data.frame(
    row.names = gsub(".mirna", "", gsub(".*/", "", fn_list), fixed = TRUE),
    patient = gsub(".mirna", "", gsub(".*/", "", fn_list), fixed = TRUE),
    condition = c(rep("dummy1", round(length(fn_list) / 2)), rep("dummy2", length(fn_list) - round(length(fn_list) / 2)))
)

  ids <- isomiRs::IsomirDataSeqFromFiles(fn_list, coldata = de, canonicalAdd = TRUE, uniqueMism = TRUE, rate = 0)

  rio::export(assay(ids), "mirna.mirbase_canonical.tsv", format = "tsv", row.names = TRUE)

  isoAll <- isomiRs::isoCounts(ids, ref = TRUE, iso5 = TRUE, iso3 = TRUE, add = TRUE, snv = TRUE, seed = TRUE, minc = 0, mins = 0)

  rio::export(assay(isoAll), "mirna.mirbase_isomiRs.tsv", format = "tsv", row.names = TRUE)

#This is for the handling of the individual files
  mirna_mirbase_canonical <- read.delim("mirna.mirbase_canonical.tsv", sep = "\t")

  colnames(mirna_mirbase_canonical)[colnames(mirna_mirbase_canonical) == "X"] <- "mirna"

  for (col_name in colnames(mirna_mirbase_canonical)[-1]) {
    sample_data <- mirna_mirbase_canonical %>% select(mirna, !!sym(col_name))
    write.table(sample_data, paste0("../qc_reports/", col_name, "/mirbase_canonical/", paste0(col_name, ".mirbase_canonical.tsv")), row.names = FALSE)
  }

  mirna_mirbase_isomiRs <- read.delim("mirna.mirbase_isomiRs.tsv", sep = "\t")

  colnames(mirna_mirbase_isomiRs)[colnames(mirna_mirbase_isomiRs) == "X"] <- "mirna"

  for (col_name in colnames(mirna_mirbase_isomiRs)[-1]) {
    sample_data <- mirna_mirbase_isomiRs %>% select(mirna, !!sym(col_name))
    write.table(sample_data, paste0("../qc_reports/", col_name, "/mirbase_isomiRs/", paste0(col_name, ".mirbase_isomiRs.tsv")), row.names = FALSE)
  }

  #unlink(c(file.path(input_dir, "mirna.mirbase_canonical.tsv"), file.path(input_dir, "mirna.mirbase_isomiRs.tsv")))

}

#run as Rscript
args <- commandArgs(trailingOnly = TRUE)
counts_all(args)
