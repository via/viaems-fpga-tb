set -e

SERV=/home/via/dev/serv

yosys -l design_ys.log -p 'synth_gowin -json design.json' \
  top.v \
  uart.v \
  parser.v \
  fifo.v \
  clock.v \
  gowinpll.v

nextpnr-himbaechel --log top.tim \
                   --device GW2AR-LV18QN88C8/I7 \
                   --vopt family=GW2A-18C \
                   --vopt cst=gowin.cst \
                   --json design.json \
                   --write design.pnr.json

gowin_pack -d GW2A-18C -o design.bit design.pnr.json 
