Compgen Course 2025
===================

Here I collect relevant course material for the Computational Genomics Course (10-16 March 2025), Module 3.
In this module, we learn about how to use deep learning models to integrate multi-omics data in the context of precision oncology applications.

Info
===================


In this course, we are using two resources to organize the course:

1. **The Google Classroom** for private course-related information, coursework, meeting announcements:
   `Google Classroom <https://classroom.google.com/c/NzQ5MTExMDU2Njkz>`_

   If you have to share private information such as your email address, please use Google Classroom.
   For any other problem that you run into, please use the GitHub Discussions (see below).

2. **GitHub discussions** on this repository to provide help to each other:
   `GitHub Discussions <https://github.com/BIMSBbioinfo/compgen_course_2025_module3/discussions>`_

   We have created different categories for potential issues you may come across.
   Please try to use the relevant category to open a discussion.
   Before opening a new discussion topic, please check if something similar is already open.
   If you know the answer to a question someone else raised, feel free to help your classmates! We appreciate your support.

Compute Environment
===================

Cloud - Rolv.io
---------------

You will be provided usernames and passwords to access the `rolv.io` platform, which comes with prebuilt packages that you will need throughout the course. With this option, you won't need to install any software yourself.

Please check your email that you signed up for the course, use your credentials to sign in: `Rolv.io Platform <https://platform.dev.cloud.rolv.io/>`_.
Then, click on **Compute -> Launch -> Launch JupyterLab**. Wait for the session to be ready (takes a few minutes).
There you will have a JupyterLab environment with all packages installed.
In this session, you can also use the **terminal**.

+++++++++++++++++++++

**Important Note**: Each session you create on Rolv is **limited** to a **total of 3 hours**. 
Please make sure to **backup your work** before terminating your session. 
We recommend creating a github repo and have a backup of your work there. 

+++++++++++++++++++++

Docker Desktop
---------------

We have also built a Docker image that contains the tools you will need.
To be able to use this, you need Docker Desktop, which you can install from here: `Docker Desktop <https://www.docker.com/products/docker-desktop/>`_.

After you install Docker, open a terminal and execute the following code to open a JupyterLab session with all the tools you need:

.. code-block:: bash

   docker pull borauyar/flexynesis_image:latest
   docker run -it -p 8888:8888 borauyar/flexynesis_image
   jupyter lab --ip=0.0.0.0 --no-browser --allow-root

This will create a link that looks like this:

   http://127.0.0.1:8888/lab?token=<.......>

Copy-paste that link into your browser to open a JupyterLab session.

Mamba/pip
---------------

If you want to have more control over your system and you know what you are doing, you can also install **flexynesis** on your system using `pip`.

.. code-block:: bash

   mamba create -n flexenv python==3.11
   mamba activate flexenv
   pip install flexynesis jupyterlab snakemake
   jupyter lab --ip=0.0.0.0 --no-browser --allow-root

This will create a link that looks like this:

   http://127.0.0.1:8888/lab?token=<.......>

Copy-paste that link into your browser to open a JupyterLab session.

