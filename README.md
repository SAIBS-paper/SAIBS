1. [About](#About)
2. [Installation](#[Installation])
3. [Required](#[Required])



# About

These softwares are for analysing finch vocalizations.



# Installation

Installation will be completed instantly.

**Clone this repository**

```bash
$ git clone https://github.com/SAIBS-paper/SAIBS.git
```


**fragment syllables**

Prepare over 2000 song files recorded in SAP2011, etc.

Execute a_make_data_plus_edge.m on MATLAB. Changing the threshold of Prewitt may improve syllable determination.


**Cluster the fragmented syllables**

Execute b_tsne_DBSCAN.m. Changing each parameter of DBSCAN may improve clustering.


**Generate a learning machine**

Execute c_AIC_CNN.m.


**Translate song files into text**

Execute d_corpas_plus_edge.m. Please align all parameters such as Prewitt's threshold with a_make_data_plus_edge.m.

The entire process takes about 30 minutes in total.

**Translate real-time voicing**

Please execute syllable_detecter_edge.m on a computer connected to a microphone. At that time, please place the generated learning machine in the same directory.



# Required

**MATLAB 2020b**

Audio Toolbox

Deep Learning Toolbox

DSP System Toolbox

Image Processing Toolbox

Signal Processing Toolbox

Statistics and Machine Learning Toolbox

