# HAI
Haplotype-based Artificial Intelligence (HAI) for SARS-COV-2 variant predictions

SARS-COV-2 is continuously evolving in the world. As the virus replicates itself, 
it continuously acquire new mutations in the viral genome. While most mutations 
are random and have limited impact on viral viability, some mutations may be functional: 
elevating the viral transmissibility, evading acquired host immunity, or increasing virulence. 
From time to time, such viruses with worrisome mutations become emerging variants that are 
classified by WHO and CDC as variant being monitored (VBM), variant of concern (VOC), or Variant of High Consequence (VOHC).

Mutations could rise as recombinants of existing variants due to co-infection, since many variants are circulating in the population. 
Other mutations could be recombinants of existing variants with new mutations, or are completely new mutations.

To detect emerging variants as soon as possible, we have developed a haplotype-based Artificial Intelligence (HAI) 
to predict new variants, automatically based on mutating amino acids in viral sequences. This HAI consists of 
multiple analytics, including data processing, temporality modeling, unsupervised learning, haplotype analysis, 
Bayes' probability calculation, and post-prediction processing. This work is reported in a manuscript (Zhao et al 2022, in preparation).

To ease the application, HAI takes in a set of viruses with GISAID ID, or 
takes in the GISAID metadata. HAI can process your own viral sequence data, if corresponding data elements are 
organized in a format similar to those GISAID, especially, for the "AA.Substitutions" column.  

GISAID is probably the most important data repository of all SARS-COV-2 sequence and metadata (https://www.gisaid.org/). 
Please contact GISAID for accessing underlying data.  All users, who apply HAI to GISAID, are consenting to all rules
and regulations of GISAID and have permissions to access GISAID data.
