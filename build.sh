set -e

SERV=/home/via/dev/serv

yosys -l design_ys.log -p 'synth_lattice -family xo3d -json design.json' \
  top.v \
  uart.v \
  parser.v \
  mock_tlv2553.v \
  fifo.v \
  clock.v \
  pll.v

nextpnr-machxo2 --log top.tim \
                --top top \
                --device LCMXO3D-9400HC-5BG256C \
                --json design.json \
                --lpf machxo2.lpf \
                --textcfg design.config

ecppack --input design.config  --bit design.bit
