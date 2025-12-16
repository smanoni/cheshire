source .bashrc
export PATH=/usr/local/bin:$PATH
export MGC_HOME=/sw/CAD/Mentor/questa
export PATH=/sw/CAD/Mentor/questa/2022.4/questasim/bin:$PATH
export PATH=/sw/riscV64/riscv64-gcc-13.2.0/bin:$PATH

python3.9 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

#python3.9 datagen.py
make all