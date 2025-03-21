set -eu
export CONDA_SETUP=$1
export CONDA_PREFIX=$2

(
bash ${CONDA_SETUP} -b -p ~/miniconda3
eval "$(~/miniconda3/bin/conda shell.bash hook)"
conda init
)

(
grep "$CONDA_PREFIX" ~/.bashrc || echo "conda activate ${CONDA_PREFIX}" >> ~/.bashrc

cp -r /rsd/data/shell_data ~
)
