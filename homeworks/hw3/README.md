Homework: Building drug response prediction models 
Download data: https://bimsbstatic.mdc-berlin.de/akalin/buyar/flexynesis-benchmark-datasets/ccle_vs_gdsc.tgz
Use flexynesis on the command-line to predict drug responses for “Erlotinib” 
Try a combination of:
multiple architectures: DirectPred, Supervised VAE, GNN 
data type combinations (e.g. mutations, mutations + RNA, mutations + RNA + CNA)
fusion methods: early, intermediate 
Write a bash script to run these experiments 
Collect the results of the experiment and rank based on performance
Which combination yields the best results?
Create a jupyter notebook. Import results from the best model run. Explore embeddings. Get top 10 markers. Do literature search. Are any of the top markers associated to “Erlotinib”?  
Warning: restrict the percentage of features to less than 5% so that all experiments can run on time. 

