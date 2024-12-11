FROM jupyter/scipy-notebook:6c3390a9292e
RUN pip install --pre jupyterhub==1.0.0
RUN pip install gripql
USER root
RUN apt-get update && apt-get install -y graphviz graphviz-dev gcc
USER $NB_UID
RUN pip install pygraphviz==1.5
