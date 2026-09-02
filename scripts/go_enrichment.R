suppressPackageStartupMessages({
  library(AnnotationDbi)
  library(clusterProfiler)
  library(enrichplot)
  library(org.At.tair.db)
})

dir.create("results/deseq2", recursive = TRUE, showWarnings = FALSE)

results <- read.delim(
  "results/deseq2/deseq2_results_G4_vs_M4.tsv",
  stringsAsFactors = FALSE
)

significant <- subset(
  results,
  !is.na(padj) & padj < 0.05 & abs(log2FoldChange) >= 1
)

symbols <- mapIds(
  org.At.tair.db,
  keys = significant$gene_id,
  keytype = "TAIR",
  column = "SYMBOL",
  multiVals = "first"
)

gene_names <- mapIds(
  org.At.tair.db,
  keys = significant$gene_id,
  keytype = "TAIR",
  column = "GENENAME",
  multiVals = "first"
)

annotated_degs <- significant
annotated_degs$symbol <- unname(symbols[annotated_degs$gene_id])
annotated_degs$gene_name <- unname(gene_names[annotated_degs$gene_id])

write.table(
  annotated_degs,
  "results/deseq2/annotated_DEGs_G4_vs_M4.tsv",
  sep = "\t", quote = FALSE, row.names = FALSE
)

background_genes <- unique(results$gene_id)
up_genes <- significant$gene_id[significant$log2FoldChange >= 1]
down_genes <- significant$gene_id[significant$log2FoldChange <= -1]

run_go <- function(genes) {
  enrichGO(
    gene = unique(genes),
    universe = background_genes,
    OrgDb = org.At.tair.db,
    keyType = "TAIR",
    ont = "BP",
    pAdjustMethod = "BH",
    pvalueCutoff = 0.05,
    qvalueCutoff = 0.05,
    readable = TRUE
  )
}

go_up <- run_go(up_genes)
go_down <- run_go(down_genes)

write_go <- function(go_result, output_file) {
  go_table <- as.data.frame(go_result)

  if (nrow(go_table) == 0) {
    go_table <- data.frame(
      message = "No significant GO Biological Process enrichment detected."
    )
  }

  write.table(
    go_table,
    output_file,
    sep = "\t", quote = FALSE, row.names = FALSE
  )
}

write_go(go_up, "results/deseq2/GO_BP_up_in_G4.tsv")
write_go(go_down, "results/deseq2/GO_BP_down_in_G4.tsv")

save_dotplot <- function(go_result, output_file, title) {
  go_table <- as.data.frame(go_result)

  if (nrow(go_table) > 0) {
    png(output_file, width = 2000, height = 1500, res = 200)
    print(
      dotplot(go_result, showCategory = min(15, nrow(go_table))) +
        ggtitle(title)
    )
    dev.off()
  }
}

save_dotplot(
  go_up,
  "results/deseq2/GO_BP_up_in_G4_dotplot.png",
  "GO Biological Process enrichment: genes up in G4"
)

save_dotplot(
  go_down,
  "results/deseq2/GO_BP_down_in_G4_dotplot.png",
  "GO Biological Process enrichment: genes down in G4"
)

message("Significant DEGs: ", nrow(significant))
message("Up in G4: ", length(up_genes))
message("Down in G4: ", length(down_genes))
message("Annotated DEGs: ", sum(!is.na(annotated_degs$symbol)))