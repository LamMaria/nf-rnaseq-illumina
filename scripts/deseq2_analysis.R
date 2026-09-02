suppressPackageStartupMessages({
  library(DESeq2)
  library(ggplot2)
  library(pheatmap)
})

dir.create("results/deseq2", recursive = TRUE, showWarnings = FALSE)

samples <- read.csv("assets/samplesheet.csv", stringsAsFactors = FALSE)
samples$condition <- factor(samples$condition, levels = c("M4", "G4"))
rownames(samples) <- samples$sample
sample_annotation <- data.frame(condition = samples$condition)
rownames(sample_annotation) <- samples$sample

count_files <- file.path(
  "results/featurecounts",
  paste0(samples$sample, ".featureCounts.txt")
)

if (!all(file.exists(count_files))) {
  missing_files <- count_files[!file.exists(count_files)]
  stop("Fichiers featureCounts introuvables :\n", paste(missing_files, collapse = "\n"))
}

count_list <- lapply(count_files, function(path) {
  tab <- read.delim(path, comment.char = "#", check.names = FALSE)
  setNames(tab[[ncol(tab)]], tab$Geneid)
})

count_matrix <- do.call(cbind, count_list)
colnames(count_matrix) <- samples$sample
rownames(count_matrix) <- names(count_list[[1]])
storage.mode(count_matrix) <- "integer"

write.table(
  data.frame(gene_id = rownames(count_matrix), count_matrix),
  "results/deseq2/raw_count_matrix.tsv",
  sep = "\t", quote = FALSE, row.names = FALSE
)

keep <- rowSums(count_matrix) >= 10
count_matrix <- count_matrix[keep, ]

dds <- DESeqDataSetFromMatrix(
  countData = count_matrix,
  colData = samples,
  design = ~ condition
)

dds <- DESeq(dds)

res <- results(dds, contrast = c("condition", "G4", "M4"))
res_shrunken <- lfcShrink(
  dds,
  coef = "condition_G4_vs_M4",
  type = "apeglm"
)

res_df <- as.data.frame(res_shrunken)
res_df$gene_id <- rownames(res_df)
res_df <- res_df[, c("gene_id", setdiff(names(res_df), "gene_id"))]
res_df <- res_df[order(res_df$padj), ]

write.table(
  res_df,
  "results/deseq2/deseq2_results_G4_vs_M4.tsv",
  sep = "\t", quote = FALSE, row.names = FALSE
)

significant <- subset(res_df, !is.na(padj) & padj < 0.05 & abs(log2FoldChange) >= 1)

write.table(
  significant,
  "results/deseq2/significant_DEGs_G4_vs_M4.tsv",
  sep = "\t", quote = FALSE, row.names = FALSE
)

normalized_counts <- counts(dds, normalized = TRUE)

write.table(
  data.frame(gene_id = rownames(normalized_counts), normalized_counts),
  "results/deseq2/normalized_count_matrix.tsv",
  sep = "\t", quote = FALSE, row.names = FALSE
)

vsd <- vst(dds, blind = FALSE)

png("results/deseq2/PCA_G4_vs_M4.png", width = 1800, height = 1400, res = 200)
pca_data <- plotPCA(vsd, intgroup = "condition", returnData = TRUE)
percent_var <- round(100 * attr(pca_data, "percentVar"))

print(
  ggplot(pca_data, aes(PC1, PC2, color = condition, label = name)) +
    geom_point(size = 5) +
    geom_text(vjust = -1, size = 4) +
    xlab(paste0("PC1: ", percent_var[1], "% variance")) +
    ylab(paste0("PC2: ", percent_var[2], "% variance")) +
    ggtitle("RNA-seq PCA: G4 vs M4") +
    theme_classic(base_size = 14)
)
dev.off()

sample_distances <- dist(t(assay(vsd)))

png("results/deseq2/sample_distance_heatmap.png", width = 1800, height = 1600, res = 200)
pheatmap(
  as.matrix(sample_distances),
  annotation_col = sample_annotation,
  annotation_row = sample_annotation,
  main = "Sample-to-sample distances"
)
dev.off()

png("results/deseq2/MA_plot_G4_vs_M4.png", width = 1800, height = 1400, res = 200)
plotMA(res_shrunken, ylim = c(-5, 5), main = "G4 vs M4")
dev.off()

volcano <- res_df
volcano$category <- "Not significant"
volcano$category[!is.na(volcano$padj) & volcano$padj < 0.05 &
                   volcano$log2FoldChange >= 1] <- "Up in G4"
volcano$category[!is.na(volcano$padj) & volcano$padj < 0.05 &
                   volcano$log2FoldChange <= -1] <- "Down in G4"

png("results/deseq2/volcano_G4_vs_M4.png", width = 1800, height = 1400, res = 200)
print(
  ggplot(volcano, aes(log2FoldChange, -log10(padj), color = category)) +
    geom_point(alpha = 0.6, size = 1.5, na.rm = TRUE) +
    scale_color_manual(values = c(
      "Down in G4" = "#2878B5",
      "Not significant" = "grey70",
      "Up in G4" = "#C82423"
    )) +
    geom_vline(xintercept = c(-1, 1), linetype = "dashed") +
    geom_hline(yintercept = -log10(0.05), linetype = "dashed") +
    labs(
      title = "Differential expression: G4 vs M4",
      x = "Shrunken log2 fold-change",
      y = "-log10 adjusted p-value",
      color = NULL
    ) +
    theme_classic(base_size = 14)
)
dev.off()

top_genes <- head(significant$gene_id, 50)

if (length(top_genes) >= 2) {
  heatmap_matrix <- assay(vsd)[top_genes, , drop = FALSE]
  heatmap_matrix <- heatmap_matrix - rowMeans(heatmap_matrix)

  png("results/deseq2/top50_DEGs_heatmap.png", width = 1800, height = 2200, res = 200)
  pheatmap(
    heatmap_matrix,
    annotation_col = sample_annotation,
    show_rownames = FALSE,
    main = "Top 50 differentially expressed genes: G4 vs M4"
  )
  dev.off()
}

capture.output(sessionInfo(), file = "results/deseq2/sessionInfo.txt")

message("Analysis complete.")
message("Genes tested: ", nrow(res_df))
message("Significant DEGs (padj < 0.05, |log2FC| >= 1): ", nrow(significant))