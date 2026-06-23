# Crystract in Action: Advanced CIF Batch Processing for Structural Analysis

[![R](https://img.shields.io/badge/R-276DC3?style=flat-square&logo=R&logoColor=white)](https://www.r-project.org/)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

**Crystract in Action** is the companion repository for the manuscript: *"CRYSTRACT IN ACTION: ADVANCED CIF BATCH PROCESSING FOR STRUCTURAL ANALYSIS IN MATERIALS SCIENCE AND MINERALOGY"* by Anirudh Prabhu, Don Ngo, Shaunna Morrison, and Julia-Maria Hübner.

This repository demonstrates the real-world application of the open-source [`crystract`](https://github.com/PrabhuLab/ml-crystals/tree/main/packages/crystract) R package. `crystract` is designed for the automated calculation and statistical treatment of interatomic distances and bond angles—processing anything from a single CIF file to thousands of crystal structures in parallel. 

## 📖 About the Package & Methodology

While multiple tools support the structural analysis of individual CIF files, `crystract` enables **scriptable, high-throughput batch processing** directly into machine-learning workflows. It bridges the gap between large theoretical databases and experimental realizations.

* **Automated Environment Generation:** Automatically extracts asymmetric units, applies symmetry operations, and constructs 3x3x3 supercells to compute all neighbor distances and angles with exact mathematical error propagation.
* **Disorder Handling:** Real materials often feature positional or occupational disorder. `crystract`'s `filter_ghost_distances()` function identifies and removes non-physical "ghost" distances based on the sum of covalent radii and a defined tolerance margin.
* **Advanced Bonding Algorithms:** Offers robust neighbor-identification algorithms, including Minimum Distance (MinimumDistanceNN), Brunner's Method (BrunnerNN), Hoppe's Effective Coordination Number (EConNN), Voronoi (VoronoiNN), and CrystalNN.
* **Post-Processing Statistics:** Accurately calculates occupancy-corrected coordination numbers (Weighted CN) and Wyckoff site-scaled average network distances.

---

## 🔬 Case Studies

This repository contains the data, scripts, and results for two distinct case studies showcasing the utility of `crystract`.

### 1. Materials Science: Clathrate I Type Compounds (`materials/`)
In intermetallic clathrates, the covalent framework forms polyhedral cages that trap guest atoms. The distances within this lattice govern cage size and flexibility, directly influencing thermoelectric properties.
* **Goal:** Confirm the linear scaling relationship between the lattice parameter and the average covalent network distance.
* **Process:** Analyzed **704 CIF files** from the ICSD database. Because multiple crystallographic models represent the same clathrate topology (e.g., *6c-16i-24k* vs *24k-48l*), occupational and positional disorder is prevalent. We applied the `MinimumDistanceNN` algorithm and utilized the ghost filter to remove over 5.2 million non-physical artifacts.
* **Result:** Processed all 704 files in ~155 seconds on a standard laptop. The analysis confirmed the linear structural trend and successfully identified the intrinsic network chemistry offset for "inverse" clathrates.

### 2. Mineralogy: Chalcogen Ores (`minerals/`)
A large-scale structural analysis of naturally occurring Sulfides, Selenides, and Tellurides to investigate systematic variations in X–X bond distances as a function of cation size, coordination number, and chalcogen species.
* **Goal:** Isolate the effects of anionic size, electronegativity, and covalency on bond distances across a wide redox spectrum.
* **Process:** Starting from an initial pool of 21,720 AMCSD CIF files, we filtered for S, Se, or Te (excluding O). The resulting dataset was validated against the official IMA database via the `OpenMindat` API, yielding **1,045 naturally occurring, formula-verified minerals**. We utilized the **EConNN** algorithm—which outperformed others in handling mixed environments and complex multi-center bonding—to calculate occupancy-weighted coordination numbers (WCN).
* **Result:** Mapped systematic variations in local geometries. For example, large, low-charge-density cations (Cs, K, Ba) exhibited the largest average interatomic distances and coordination numbers, consistent with established crystal-chemical principles.

---

## 📊 Interactive Visualizations

Explore the standalone interactive Plotly visualizations exported directly from our automated workflows. **Click any link below to open the interactive chart:**

### 🧱 Materials Science: Clathrates
* [Clathrate I Type: Lattice Parameter vs. Average Network Bond Length](materials/interactive_report_files/interactive_clathrate_plot.html)

### 🪨 Mineralogy: Chalcogen Ores
#### Global Visualization
* [7.1 Pairwise Bond Lengths](minerals/plotly_exports/7_1_pairwise_lengths.html)
* [7.2 Pairwise Bond Angles](minerals/plotly_exports/7_2_pairwise_angles.html)

#### Coordination Number Analysis
* [8.1 Bond Length vs ECon CN](minerals/plotly_exports/8_1_regular_cn.html)
* [8.2 Bond Length vs Weighted CN](minerals/plotly_exports/8_2_weighted_cn_z.html)
* [8.3 Weighted CN Sorted by Global Bond Length](minerals/plotly_exports/8_3_weighted_cn_len.html)

#### Chalcogen-Specific Analysis (S, Se, Te Centers)
* [9.1 Average Bond Lengths](minerals/plotly_exports/9_1_chalc_center_len.html)
* [9.2 Normalized Bond Lengths](minerals/plotly_exports/9_2_chalc_center_norm_len.html)
* [9.3 ECon Coordination Number](minerals/plotly_exports/9_3_chalc_center_cn.html)
* [9.4 Total vs Specific Weighted CN (All Chalcogens)](minerals/plotly_exports/9_4_chalc_center_wcn.html)
  * [9.4.1 Specific WCN: Sulfur (S)](minerals/plotly_exports/9_4_1_chalc_wcn_s.html)
  * [9.4.2 Specific WCN: Selenium (Se)](minerals/plotly_exports/9_4_2_chalc_wcn_se.html)
  * [9.4.3 Specific WCN: Tellurium (Te)](minerals/plotly_exports/9_4_3_chalc_wcn_te.html)
* [9.5 Bond Angles](minerals/plotly_exports/9_5_chalc_center_angles.html)

#### Advanced Analysis
* [11. Bond Length vs Angle Correlation (Neighbor Families)](minerals/plotly_exports/11_advanced_scatter.html)

---

## 🚀 Quick Start / Basic Workflow

The `crystract` package provides granular functions for every step of crystallographic analysis, unified under the `analyze_cif_files()` wrapper.

```R
library(crystract)

# 1. Run the core pipeline on a target CIF file
cif_path <- system.file("extdata", "ICSD422.cif", package = "crystract")
analysis_results <- analyze_cif_files(cif_path)

# 2. Extract distance metrics with rigorous error propagation
distances <- analysis_results$distances[[1]]

# 3. Clean non-physical distances caused by crystallographic disorder
filtered_result <- filter_ghost_distances(
  distances = distances,
  atomic_coordinates = analysis_results$atomic_coordinates[[1]],
  tolerance = 0.4 
)
clean_distances <- filtered_result$kept

# 4. Calculate the true occupancy-weighted average network distance
weighted_avg_dist <- calculate_weighted_average_network_distance(
  distances = clean_distances,
  atomic_coordinates = analysis_results$atomic_coordinates[[1]],
  wyckoff_symbols = "4c"
)
```

---

## 📚 Citation & Data Availability

If you use `crystract` or the workflows provided in this repository, please cite:

> Prabhu, A., Ngo, D., Morrison, S. M., Hübner, J.-M. (2026). *CRYSTRACT IN ACTION: ADVANCED CIF BATCH PROCESSING FOR STRUCTURAL ANALYSIS IN MATERIALS SCIENCE AND MINERALOGY*. [Journal/DOI pending].

**Data & Code:**
* The core `crystract` R package source code is hosted at [PrabhuLab/ml-crystals](https://github.com/PrabhuLab/ml-crystals/tree/main/packages/crystract) and can be installed via CRAN (`install.packages("crystract")`).
* The CIF files used for these case studies are derived from the Inorganic Crystal Structure Database (ICSD) and the American Mineralogist Crystal Structure Database (AMCSD).

## 🤝 Acknowledgements
JMH gratefully acknowledges discussions with Michael Baitinger, as well as funding by the Joachim Herz Foundation. DN has been supported by the Earth and Planetary Science Interdisciplinary Internship at Carnegie Science (a National Science Foundation REU). AP acknowledges funding and support for this project provided by Carnegie Science and a private foundation.
