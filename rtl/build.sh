set -e

yosys -l design_ys.log -p 'synth_lattice -family xo3d -json design.json' \
  top.v \
  core.v \
  ft2232_sync_fifo.v \
  parser.v \
  mock_tlv2553.v \
  capture.v \
  encoder.v \
  fifo.v

nextpnr-machxo2 --log top.tim \
                --top top \
                --device LCMXO3D-9400HC-6SG72I \
                --json design.json \
                --lpf testharness.lpf \
                --textcfg design.config

ecppack --input design.config  --bit design.bit --svf design.svf --jed design.jed
