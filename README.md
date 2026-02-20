<h1 align="center">UAV Fault Detection Multirotor Drones</h1>

## Table of Contents 📚 <a name="table-of-contents"></a>

1. [**Project Overview**](#projectoverview)

2. [**Folder Structure**](#folderstructure)

3. [**Requirements**](#requirements)

4. [**Usage**](#usage)

5. [**Legal**](#legal)        
   - [Credits](#credits)
   - [License](#license)

## 1. **Project Overview** <a name="projectoverview"></a> 
This project implements and evaluates machine learning models for detecting and classifying propeller faults in multirotor UAVs using flight telemetry logs.

Two tasks are addressed:

- **Binary classification**
  - Classes: `no-fault` vs `fault`
  - Fault class aggregates: `5% damage` and `10% damage`

- **Ternary classification**
  - Classes: `no-fault`, `fault_5%`, `fault_10%`
  - Objective: discriminate fault severity levels

Additionally, model explainability techniques are used to analyze the trade-off between predictive performance and interpretability.

## 2. **Folder Structure** <a name="folderstructure"></a>

```text
UAV-FD-Fault-Detection-Multirotor-Drones/
├─ scripts/               
│  ├─ compareN.m
│  ├─ create_dataTable_binary.m
│  ├─ create_dataTable_multiclass.m
│  ├─ data_synchronizer.m
│  ├─ diagnosticFeatures.m
│  ├─ diagnostic_feature_pipeline.m
│  └─ synchronizer.m
├─ .gitignore
├─ documents/
│  ├─ Relazione_Progetto.pdf
│  ├─ UAV-FD.pdf
│  ├─ Revisione_no1.pptx
│  ├─ Revisione_no2.pptx
│  └─ Revisione_no3.pptx
├─ LICENSE
└─ README.md
```

## 3. **Requirements** <a name="requirements"></a>

To run the code, the following software is required:

- **MATLAB (tested with R2025b)**
- **Diagnostic Feature Designer** (MATLAB toolbox)
- **Classification Learner** (MATLAB toolbox)

**NOTE**: The dataset used in this project is available in the paper (see the link on page 1).

## 4. **Usage** <a name="usage"></a>
1. **Import the dataset**  
   Place the dataset files into the `raw_data` folder. Ensure the folder structure matches the repository layout.

2. **Preprocess the data**  
   Run the `data_synchronizer.m` to clean and synchronize the raw telemetry logs:
   - The timestamps from all sensors are aligned using the `compareN.m` function.
   - A Zero-Order Hold (ZOH) synchronization is applied to create a uniform time base.
   - The first two seconds and the last two seconds of each flight are trimmed to remove startup and landing transients.  
   - The output produces a separate synchronized file for each original log, saved in the `synchronized_data/` folder.
     
3. **Create dataTable**  
   Depending on the classification task, run the corresponding file to create the dataTable from which features are extracted:

   - **Binary classification** (no-fault vs fault): `create_dataTable_binary.m`  
   - **Ternary classification** (no-fault, fault 5%, fault 10%): `create_dataTable_multiclass.m`

4. **Feature Extraction and Classification Learner Launch**   
    Run the `diagnostic_feature_pipeline.m` script to extract features, clean the data, split the dataset, and launch the *Classification Learner*:
   - The features are extracted using a custom function generated with *Diagnostic Feature Designer*, named as `diagnosticFeatures.m`.    
     Diagnostic Feature Designer allows you to interactively generate and rank features, and export them for machine learning workflows. 
   - After feature extraction, the script performs data cleaning and preprocessing (e.g., handling missing values, normalization).  
   - The dataset is then split into training and test sets to separate model training from evaluation.  
   - Finally, *Classification Learner* is launched with the prepared feature set; this toolbox is used to train and compare classification models.
     
6. **Explainability**  
For analyzing feature importance and model interpretability, you can use the **Explain** section of MATLAB’s **Classification Learner** tool.

**NOTE**: For detailed results and analysis, refer to the project report `Relazione_Progetto.m`. 

## 5 . **Legal** <a name="legal"></a>
### **Credits** <a name="credits"></a>
The project was developed by:   
  - Caterina Sabatini   
  - Matteo Stronati
    
The project was supervised by prof. Alessandro Freddi.
### **License** <a name="license"></a>   
   This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
