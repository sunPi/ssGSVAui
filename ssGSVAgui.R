#---- Functions ----
handleRequirements <- function(pkgs){ 
  install.packages("pacman")
  ipkgs <- sapply(pkgs, function(...) require(..., character.only = TRUE))
  if (any(!ipkgs)) {
    BiocManager::install(pkgs[!ipkgs])
    install.packages(pkgs[!ipkgs])
  }
  else {
    message("\n\nCool! your machine has everything is needed.\n\n")
  }
  
  print("Loading required packages...")
  pacman::p_load(pkgs, install = TRUE, character.only = TRUE)
  return(pacman::p_loaded())
}
prepareGSVAMatrix <- function(m){

  fe <- tools::file_ext(m)
  
  if(fe == "csv"){
    x <- read.csv(m)
    
  } else if (fe %in% c("xls", "xlsx")) {
    # Install and load the readxl package if not already installed
    if (!require(readxl)) {
      install.packages("readxl")
      library(readxl)
    }
    x <- read_excel(m)
    
  } else {
    stop("Unsupported file type.")
  }
  
  gene.symbols <- x[,1]
  x   <- as.matrix((x[,-1]))
  sid <- colnames(x)
  
  rownames(x) <- gene.symbols
  
  return(
    list(x = x,
         sid = sid,
         genes  = gene.symbols)
  )
}
ESToMatrix <- function(ES){
  res <- rownames_to_column(as.data.frame(ES))
  res <- t(res)
  colnames(res) <- res[1,]
  res <- res[-1, ]
  res <- rownames_to_column(as.data.frame(res))
  colnames(res)[1] <- "SampleID"
  return(res)
}

#---- Package Installation ----
pkgs <- c("GSVA", "here", "GSEABase", "rstudioapi", "tibble")
suppressMessages(handleRequirements(pkgs))

#---- Header ----
showDialog("ssGSEA", "Initialising ssGSEA script...")

#------------------ Load dataset and parameters into R environment -------------
# Command Line Arguments
showDialog("ssGSEA", "Select your RNA-seq expression file...")
expr.mat <- selectFile()
print("Creating a GSVA object...")
gsva.obj  <- prepareGSVAMatrix(expr.mat)

showDialog("ssGSEA", "Select your molecular signature...")
sig.path <- selectFile()
gene.signature        <- getGmt(sig.path)
# verbose   <- as.integer(arguments$verbose)

# Main
# gsea.set <- ssgseaParam(gsva.obj$x, gs)
# ES <- gsva(gsea.set, verbose = T)
showDialog("ssGSEA", "Calculating enrichment scores...")
ES <- gsva(expr = gsva.obj$x, 
           gset.idx.list = gene.signature, 
           method = "ssgsea", 
           ssgsea.norm = TRUE)
showDialog("ssGSEA", "Success!")

print("Transforming enrichment scores to data frame...")
res <- ESToMatrix(ES)


exp.name <- tools::file_path_sans_ext(basename((sig.path)))

showDialog("ssGSEA", "Select a directory to store the results in...")
outfolder <- selectDirectory()
outdir <- normalizePath(here(outdir,exp.name), winslash = "/", mustWork = FALSE)

print(paste0("Saving results to ", outdir))
dir.create(outdir, showWarnings = F, recursive = T)
# saveRDS(res, here(outdir, paste0(exp.name, ".RDS")))
write.csv(res, here(outdir, paste0(exp.name, ".csv")), row.names = F)
