import re
import argparse
import sys
import os

def generate_wrapper(original_verilog):
    # 1. Extract the Module Name and Port List
    mod_match = re.search(r'^\s*module\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\((.*?)\)\s*;', original_verilog, re.MULTILINE | re.DOTALL)
    if not mod_match:
        raise ValueError("Could not find a valid module declaration in the input file.")
    
    module_name = mod_match.group(1)
    port_list_str = mod_match.group(2)
    
    # Clean up any weird spacing or newlines in the port list string
    clean_port_list = re.sub(r'\s+', ' ', port_list_str).strip()
    
    # 2. Extract Port Declarations (inputs, outputs, inouts)
    # This matches scalars: "input c_in;" and buses: "output [7:0] data_out;"
    port_pattern = r'^\s*(input|output|inout)\s+(?:\[(\d+):(\d+)\]\s+)?([a-zA-Z_][a-zA-Z0-9_]*)\s*;'
    
    ports = []
    for match in re.finditer(port_pattern, original_verilog, re.MULTILINE):
        direction = match.group(1)
        msb = match.group(2)
        lsb = match.group(3)
        name = match.group(4)
        
        if msb is not None and lsb is not None:
            # It's a bus. Find the min and max bits.
            start = min(int(msb), int(lsb))
            end = max(int(msb), int(lsb))
            original_range = f"[{msb}:{lsb}]" # Keep original [7:0] or [0:7] format
            ports.append({'name': name, 'dir': direction, 'bus': True, 'start': start, 'end': end, 'range': original_range})
        else:
            # It's a scalar (single bit).
            ports.append({'name': name, 'dir': direction, 'bus': False})
            
    if not ports:
        raise ValueError("Could not find any input/output declarations.")

    # 3. Build the Wrapper Code
    wrapper = f"// Auto-generated LEC wrapper for {module_name}\n\n"
    wrapper += f"module {module_name}_wrapper({clean_port_list});\n"
    
    # Re-declare original ports
    for p in ports:
        if p['bus']:
            wrapper += f"  {p['dir']} {p['range']} {p['name']};\n"
        else:
            wrapper += f"  {p['dir']} {p['name']};\n"
            
    wrapper += f"\n  // Instantiate the sanitized, bit-blasted module\n"
    wrapper += f"  {module_name} sanitized_inst (\n"
    
    # Map the ports to the bit-blasted sanitized module
    mappings = []
    for p in ports:
        if p['bus']:
            # Map every bit of the bus: .data_in_0(data_in[0])
            for i in range(p['start'], p['end'] + 1):
                mappings.append(f"    .{p['name']}_{i}({p['name']}[{i}])")
        else:
            # Map the scalar directly: .c_in(c_in)
            mappings.append(f"    .{p['name']}({p['name']})")
            
    # Join all mappings with a comma and newline
    wrapper += ",\n".join(mappings)
    wrapper += "\n  );\nendmodule\n"
    
    return wrapper

def main():
    parser = argparse.ArgumentParser(description="Generate a wrapper for Equivalence Checking of bit-blasted Verilog.")
    parser.add_argument('--input', required=True, help="Path to the ORIGINAL (Golden) Yosys synthesized .v file")
    parser.add_argument('--output', required=True, default="wrapper.v", help="Path to save the generated wrapper.v file")
    args = parser.parse_args()

    if not os.path.isfile(args.input):
        print(f"Error: Input file '{args.input}' not found.")
        sys.exit(1)

    try:
        with open(args.input, 'r') as infile:
            original_verilog = infile.read()
    except Exception as e:
        print(f"Error reading {args.input}: {e}")
        sys.exit(1)

    print(f"Parsing '{args.input}' and generating wrapper...")
    
    try:
        wrapper_code = generate_wrapper(original_verilog)
        with open(args.output, 'w') as outfile:
            outfile.write(wrapper_code)
        print(f"Success! Wrapper saved to '{args.output}'.")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
