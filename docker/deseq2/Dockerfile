FROM bioconductor/bioconductor_docker:RELEASE_3_23

RUN R -q -e "BiocManager::install(c('DESeq2', 'apeglm', 'org.At.tair.db', 'clusterProfiler', 'enrichplot'), ask = FALSE, update = FALSE)" \
    && R -q -e "install.packages(c('ggplot2', 'pheatmap'), repos = 'https://cloud.r-project.org')"