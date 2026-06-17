# Crystract in Action: Advanced CIF Batch Processing for Structural Analysis 

**Crystract in Action** is the companion repository for the manuscript: *"CRYSTRACT IN ACTION: ADVANCED CIF BATCH PROCESSING FOR STRUCTURAL ANALYSIS IN MATERIALS SCIENCE AND MINERALOGY"* by Anirudh Prabhu, Don Ngo, Shaunna Morrison, and Julia-Maria Hübner.

This repository demonstrates the real-world application of the [`crystract`](https://cran.r-project.org/web/packages/crystract/index.html) R package. `crystract` is an open-source tool designed for the automated calculation and statistical treatment of interatomic distances, bond angles, and coordination environments across thousands of Crystallographic Information Files (CIFs) simultaneously.

## 📖 About the Package

While many existing tools support the structural analysis of individual CIF files, `crystract` bridges the gap for **large-scale, batch processing** necessary for machine-learning workflows and big-data crystallography. 

**Key Features:**
*   **Batch Processing:** Analyze thousands of experimental or theoretical CIFs in parallel.
*   **Disorder Handling:** Automatically resolves occupational and positional disorder, filtering out non-physical "ghost" distances using customizable atomic radii thresholds.
*   **Advanced Bonding Algorithms:** Supports multiple coordination number (CN) algorithms including ECon (Effective Coordination Number), Brunner's Method, Voronoi, Minimum Distance, and CrystalNN.
*   **Uncertainty Propagation:** Rigorously propagates experimental uncertainties from cell parameters and fractional coordinates to the final bond distances and angles.
*   **Occupancy-Weighted Metrics:** Calculates occupancy-corrected coordination numbers (WCN) and site-scaled average network distances.

---

## 🔬 Case Studies

This repository contains the data, scripts, and results for two distinct case studies demonstrating `crystract`'s capability to bridge the gap between theoretical predictions and experimental realizations.

### 1. Materials Science: Clathrate I Type Compounds (`clathrates/`)
Interatomic distances in clathrates govern cage size, flexibility, and thermoelectric properties. We used `crystract` to process >700 CIF files of intermetallic clathrate-I compounds from the ICSD database.
*   **Goal:** Investigate the linear scaling relationship between the lattice parameter and the average covalent network distance.
*   **Process:** Handled complex Wyckoff site disorder (e.g., *6c-16i-24k* vs *24k-48l*) and applied the `filter_ghost_distances` logic to remove over 5.2 million artifact distances before computing the `calculate_weighted_average_network_distance`.
*   **Result:** Processed all 700+ files in ~155 seconds, confirming the structural trends and identifying intrinsic differences in framework chemistry for "inverse" clathrates.

### 2. Mineralogy: Chalcogen Ores (`minerals/`)
A large-scale analysis of naturally occurring Sulfides, Selenides, and Tellurides to quantify how cationic environments and chalcogen chemistry control the formation of anion-anion bonds (e.g., S-S, Se-Se, Te-Te).
*   **Goal:** Isolate the effects of anionic size and covalency on bond distances across a wide redox spectrum.
*   **Process:** Filtered >21,000 AMCSD files down to ~1,000 verified natural chalcogenides (cross-referenced with the official IMA mineral database via the `OpenMindat` API). Utilized the **ECon algorithm** to compute continuous and Weighted Coordination Numbers (WCN).
*   **Result:** Mapped systematic variations in local geometries and generated interactive structural diagnostics.

---

## 📊 Interactive Crystract Visualizations

Explore the standalone interactive Plotly visualizations exported directly from our Chalcogenide analysis workflow. **Click any link below to open the interactive chart:**

### 7. Global Visualization
* [7.1 Pairwise Bond Lengths](minerals/plotly_exports/7_1_pairwise_lengths.html)
* [7.2 Pairwise Bond Angles](minerals/plotly_exports/7_2_pairwise_angles.html)

### 8. Coordination Number Analysis
* [8.1 Bond Length vs ECon CN](minerals/plotly_exports/8_1_regular_cn.html)
* [8.2 Bond Length vs Weighted CN](minerals/plotly_exports/8_2_weighted_cn_z.html)
* [8.3 Weighted CN Sorted by Global Bond Length](minerals/plotly_exports/8_3_weighted_cn_len.html)

### 9. Chalcogen-Specific Analysis (S, Se, Te Centers)
* [9.1 Average Bond Lengths](minerals/plotly_exports/9_1_chalc_center_len.html)
* [9.2 Normalized Bond Lengths](minerals/plotly_exports/9_2_chalc_center_norm_len.html)
* [9.3 ECon Coordination Number](minerals/plotly_exports/9_3_chalc_center_cn.html)
* [9.4 Total vs Specific Weighted CN (All Chalcogens)](minerals/plotly_exports/9_4_chalc_center_wcn.html)
  * [9.4.1 Specific WCN: Sulfur (S)](minerals/plotly_exports/9_4_1_chalc_wcn_s.html)
  * [9.4.2 Specific WCN: Selenium (Se)](minerals/plotly_exports/9_4_2_chalc_wcn_se.html)
  * [9.4.3 Specific WCN: Tellurium (Te)](minerals/plotly_exports/9_4_3_chalc_wcn_te.html)
* [9.5 Bond Angles](minerals/plotly_exports/9_5_chalc_center_angles.html)

### 11. Advanced Analysis
* [11. Bond Length vs Angle Correlation (Neighbor Families)](minerals/plotly_exports/11_advanced_scatter.html)

---

## 📚 Citation & Data Availability

If you use `crystract` or the workflows provided in this repository, please cite:

> Prabhu, A., Ngo, D., Morrison, S. M., Hübner, J.-M. (2026). *CRYSTRACT IN ACTION: ADVANCED CIF BATCH PROCESSING FOR STRUCTURAL ANALYSIS IN MATERIALS SCIENCE AND MINERALOGY*. [Journal/DOI pending].

**Data & Code:**
* The core `crystract` R package source code is hosted at [PrabhuLab/ml-crystals](https://github.com/PrabhuLab/ml-crystals/tree/main/packages/crystract).
* The CIF files used for these case studies are derived from the Inorganic Crystal Structure Database (ICSD) and the American Mineralogist Crystal Structure Database (AMCSD).

## 🤝 Acknowledgements
JMH gratefully acknowledges discussions with Michael Baitinger, as well as funding by the Joachim Herz Foundation. DN has been supported by the Earth and Planetary Science Interdisciplinary Internship at Carnegie Science (a National Science Foundation REU). AP acknowledges funding and support for this project provided by Carnegie Science and a private foundation.
