Download and unpack data 

```
wget https://bimsbstatic.mdc-berlin.de/akalin/buyar/flexynesis-benchmark-datasets/ccle_vs_gdsc.tgz
tar -xzvf ccle_vs_gdsc.tgz 
```

Define bash script to run multiple experiments:
=> see run_experiments.sh

```
mkdir output
srun --gpus=1 bash run_experiments.sh > log 

```

Final report: See analyse_experiments.ipynb

If you'd like to see a more elaborate pipeline that addresses such a benchmarking exercise, check out our benchmarking pipeline for Flexynesis:
https://github.com/BIMSBbioinfo/flexynesis-benchmarks




