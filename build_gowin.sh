set -e

SERV=/home/via/dev/serv

yosys -l design_ys.log -p 'synth_gowin -json design.json' \
  top.v

nextpnr-himbaechel --log top.tim \
                   --device GW2AR-LV18QN88C8/I7 \
                   --vopt family=GW2A-18C \
                   --json design.json \
                   --write design.pnr.json

gowin_pack -d GW2A-18C -o design.bit design.pnr.json 
