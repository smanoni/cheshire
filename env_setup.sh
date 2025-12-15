source .bashrc
export PATH=/usr/local/bin:$PATH
export MGC_HOME=/sw/CAD/Mentor/questa
export PATH=/sw/CAD/Mentor/questa/2022.4/questasim/bin:$PATH
export PATH=/sw/riscV64/riscv64-gcc-13.2.0/bin:$PATH
export https_proxy="http://192.168.6.254:3128"
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export http_proxy="http://192.168.6.254:3128"

python3.9 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt