# Compgen Course 2025

Here I collect relevant course material for the Computational Genomics Course (10-16 March 2025), Module 3.
In this module, we learn about how to use deep learning models to integrate multi-omics data in the context of precision oncology applications. 

# Info

- Course outline: https://docs.google.com/document/d/1rh2U0i7fYPJrZpzBXxgrGZCVgAebgxC5Oo2RnYnbsn8/edit?tab=t.0#heading=h.hgvwi6d1s3pv
- Slides: https://docs.google.com/presentation/d/1Z3m8JOQY0JidM7gIJNFWaOfCaTH-rU47y4zCu5Bk6mE/
- Google Classroom: https://classroom.google.com/c/NzQ5MTExMDU2Njkz
- Flexynesis: https://github.com/BIMSBbioinfo/flexynesis
    - Command-line tutorial: https://bimsbstatic.mdc-berlin.de/akalin/buyar/flexynesis/site/getting_started/
    - Jupyter notebooks: https://github.com/BIMSBbioinfo/flexynesis/tree/main/examples/tutorials

# Docker

docker build -t borauyar/flexynesis_image . 
docker push borauyar/flexynesis_image:latest

docker pull borauyar/flexynesis_image:latest

docker run -it -p 8888:8888 borauyar/flexynesis_image 

jupyter lab --ip=0.0.0.0 --no-browser --allow-root 

Open your browser and go to http://localhost:8888 

 
# Contact

- Bora Uyar, bora.uyar@mdc-berlin.de
