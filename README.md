# ssGSVAui

# ssGSVA
This is just a simple wrapper for the single sample method of the GSVA package. It offers an interactive code that prompts the user for neccesary inputs. The packages should be automatically installed, if necessary please do install any other dependencies. <br>

---

Usage:

To use the script simply open it using Rstudio and go to "code -> run region -> run all" or press "ctrl + alt + r" shortcut and run the whole script. 

Inputs:

- RNA-Seq expression matrix FPKM normalised (if not available count data will do).
- A molecular signature in the ".gct" format. Signatures can be downloaded from https://www.gsea-msigdb.org/gsea/msigdb

Outputs:
- A csv file with normalised enrichment scores per sample

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
