# ANALYTICAL WORKFLOW OF "SCALABLE AND EFFICIENT FUNCTIONAL CONNECTIVITY MODELLING"

### _*By*_ XXXXXXXXXXXXXXXXX

## Description of Repository

This code repository contains the code of the analytical workflow implemented in XXXXXXXX (in review).

### Paper citation

XXXXXXXXXXXXXXXXXXX (in review). Scalable and efficient functional connectivity modelling. XXXXXXXXXXXXXXXXXXXXXXXX.

### Asbtract

*Rationale*: Maintaining, enhancing, and restoring ecological connectivity is central to conservation policy and practice. Modelling connectivity at fine spatial resolutions can meaningfully capture species’ movement and guide spatial planning by identifying corridors and barriers, particularly in heterogenous landscapes. However, existing approaches that promise connectivity modelling at fine resolutions and large extents (“large scale”) suffer from accuracy loss and high computational demands, limiting their reliability and computational feasibility.

*Aims*: We developed a tiling approach for large-scale connectivity modelling that preserves spatial accuracy while maintaining computational feasibility.

*Methods*: Our approach integrates a unifying functional connectivity framework—the spatial absorbing Markov chain (SAMC)—within a tiling pipeline. The approach comprises four steps: (1) partitioning landscapes into spatial tiles; (2) adding buffers to each tile, with buffer distances informed by species-specific dispersal kernels; (3) modelling connectivity independently within each buffered tile using SAMC; and (4) merging outputs into a landscape-wide connectivity map. We apply our approach to a large landscape comprising 1 million pixels (100,000 km2 extent at 100-m resolution). We assessed sensitivity of spatial accuracy to tile number and buffer size, and benchmarked runtime and memory use across increasing tile number and under parallelisation.

*Results*: Spatial accuracy was effectively preserved when buffer distances equalled or exceeded the 95th percentile of species’ dispersal kernels and regardless of tile number, producing outputs nearly identical to those from non-tiled models. Increasing tile number resulted in up to ~2.35× speed-up in runtime (from ~7.09 to ~3.16 hours) and ~76.5% decrease in max memory usage (from 36.73 to 8.64 GB). Parallelisation further sped-up runtime up to ~25.08× (down to 18 minutes) and with up to ~11.7% (down to 32.44 GB) decrease in max memory usage.

*Conclusion*: Our tiling approach enables reliable and computationally feasible large-scale connectivity modelling, addressing long-standing methodological and computational barriers and supporting more scalable connectivity conservation planning.


### Repository structure

To reproduce the workflow, make sure to create the following folders within the repository, and download data files at (https://figshare.com/s/afb7eae2e031ed01fb5b)

>*./data/*_ # contains subfolders of the modelling landscape  ([?]_stack.tif) and metadata ([?].rds).
>*./figures*_ # path for figures
>*./functions*_ # contains functions
>*./functions/SAMC_tiling.R # function for tiling and bufferingthe landscape (Steps 1 and 2 of our tiling approach).
>*./functions/SAMC_benchmarking.R # function for modelling the connectivity on each tile and merging tiled outputs (Steps 3 and 4 of our tiling approach). Included are scripts for benchmarking runtime of the tiling pipeline. Note: bechmarking memory was only possible through hpc's slurm job accounting.
>*./input*_ # contains subfolders of buffered tiles of the modelling landscape.
>*./output*_ # contains the raw outputs of our tiling approach (merged connectivity maps) and the results of the sensitivity and benchmarking analysis.
>*./scripts*_ # contains scripts
>*./scripts*_
>*./scripts/0_dataPreparation.Rmd*_ # This script contains the R pipeline for creating modelling landscapes. For demonstration, we showed here how to create neutral landscape (10 million grid cells).
>*./scripts/01_TilingandBuffering.Rmd*_ # This script contains the R pipeline for tiling and buffering the landscape, which is steps 1 and 2 of our tiling approach.
>*./scripts/02_SAMCandMerging.Rmd*_ # This script contains the R pipeline for modelling connectivity on each buffered tile and merging the outputs of buffered tiles, which correspond to steps 3 and 4 of our tiling approach.
>*./scripts/03_SensitivityAnalysis.Rmd*_ # This script contains the R pipeline for the sensitivity analysis of spatial accuracy due to tiling and buffering.
>*./scripts/04_benchmarking.Rmd*_ # This script contains the R pipeline for the benchmarking of runtime and maximum memory usage.
