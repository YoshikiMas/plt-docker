FROM nvidia/cuda:10.2-cudnn7-devel

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV CUDNN_VERSION 8.2.0.53

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo gosu ssh \
    build-essential cmake clang \
    tmux byobu git curl wget vim tree htop zip unzip \
    libopenblas-base libopenblas-dev liblapack-dev libatlas-base-dev\
    libfftw3-dev libfftw3-doc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


ARG ROOT_PASSWORD="password"
RUN echo "root:$ROOT_PASSWORD" | chpasswd

WORKDIR /opt
RUN wget --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh
RUN sh /opt/Miniconda3-py39_4.9.2-Linux-x86_64.sh -b -p /opt/miniconda3 && \
    rm -f Miniconda3-py39_4.9.2-Linux-x86_64.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc
    
ENV PATH /opt/miniconda3/bin:$PATH

RUN conda update -n base -c defaults conda
RUN conda create -n pytorch-lightning python==3.7.7
RUN conda init bash

SHELL ["conda", "run", "-n", "pytorch-lightning", "/bin/bash", "-c"]

RUN conda install -y -c pytorch pytorch==1.9.1 torchvision=0.10.1 torchaudio=0.9.1 cudatoolkit=10.2
RUN conda install -y -c conda-forge pytorch-lightning==1.4.9

RUN conda install -y -c conda-forge jupyterlab_widgets=1.0.2
RUN conda install -y -c conda-forge ipywidgets=7.6.5
RUN conda install -y -c conda-forge matplotlib=3.4.3
RUN conda install -y -c conda-forge seaborn=0.11.2
RUN conda install -y -c conda-forge tabulate=0.8.9

RUN conda install -y -c intel cython=0.29.23
RUN conda install -y -c intel numpy=1.20.3
RUN conda install -y -c intel scipy=1.6.2
RUN conda install -y -c intel opt_einsum=3.3.0
RUN conda install -y -c intel pandas=1.2.0

RUN conda install -y -c conda-forge scikit-learn=1.0
RUN conda install -y -c conda-forge umap-learn 
RUN conda install -y -c conda-forge pandas-profiling=3.1.0
RUN conda install -y -c conda-forge lightgbm=3.2.1
RUN conda install -y -c conda-forge pulp=2.5.1

RUN conda install -y -c conda-forge pysoundfile=0.10.3.post1
RUN conda install -y -c conda-forge librosa=0.8.1
RUN conda install -y -c conda-forge hydra-core=1.0.6
RUN conda install -y -c conda-forge optuna=2.9.1

RUN conda install -y -c pyg -c conda-forge pyg
RUN conda clean --all

RUN pip install --no-cache-dir pyroomacoustics
RUN pip install --no-cache-dir cookiecutter
RUN pip install --no-cache-dir museval
RUN pip install --no-cache-dir pesq
RUN pip install --no-cache-dir torch_optimizer
RUN pip install --no-cache-dir torchinfo

# User Setting
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
