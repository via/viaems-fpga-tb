set -e

SERV=/home/via/dev/serv

yosys -l design_ys.log -p 'synth_gowin -json design.json' \
  top.v \
  uart.v \
  parser.v \
  fifo.v \
  clock.v \
  mock_tlv2553.v \
  capture.v \
  gowinpll.v

nextpnr-himbaechel --log top.tim \
                   --device GW1N-UV4LQ100C6/I5 \
                   --vopt family=GW1N-4 \
                   --vopt cst=gowin.cst \
                   --json design.json \
                   --write design.pnr.json

gowin_pack -d GW2A-18C -o design.bit design.pnr.json 
