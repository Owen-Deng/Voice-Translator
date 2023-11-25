wget https://bootstrap.pypa.io/get-pip.py && python3.10 get-pip.py --user
python3.10 -m pip install git+https://github.com/coqui-ai/TTS.git
wget https://github.com/git-lfs/git-lfs/releases/download/v3.4.0/git-lfs-linux-amd64-v3.4.0.tar.gz
tar xvf git-lfs-linux-amd64-v3.4.0.tar.gz
cd git-lfs-3.4.0
chmod +x install.sh
# "prefix="/users/chuanqid/final/git-lfs"
vim install.sh
sh install.sh
export PATH="${PATH}:/users/chuanqid/final/git-lfs/bin"
git lfs install
git clone https://huggingface.co/coqui/XTTS-v2

python3.10 -m pip install uvicorn[standard]
python3.10 -m pip install fastapi