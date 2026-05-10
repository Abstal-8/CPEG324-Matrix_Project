Walthrough has the following assumptions:
 - Yosys 0.9 (or better) installed
 - Working on a Ubuntu/Linux machine (22.04 LTS)


Getting to a point in the synthesizing process:
step 1: cd Pipelined
step 2: yosys synthesis_full_lib.ys
step 3: python3 sanitize_netlist.py --input mat8x8_pipe_full_lib_syn.v --output mat8x8_pipe_full_lib_syn_sanitized.v
step 4: python3 generate_wrapper.py --input mat8x8_pipe_full_lib_syn.v --output wrapper.v --top mat8x8_pipe
step 5: yosys verify.ys (This is where it breaks)