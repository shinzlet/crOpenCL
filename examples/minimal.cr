require "../src/crOpenCL.cr"

# Generate random inputs
total = 190

def print_binary(pointer, byte_count)
    bytes = Bytes.new(pointer.unsafe_as(Pointer(UInt8)), byte_count)
    puts "hex: " + bytes.map { |byte| byte.to_s(16).rjust(2, '0').center(8, ' ') }.join(" ")
    puts "bin: " + bytes.map { |byte| byte.to_s(2).rjust(8, '0') }.join(" ")
end

# Prompts the user to choose a platform & device
context = CrOpenCL.create_some_context
queue = CrOpenCL::CommandQueue.new context, context.device, CrOpenCL::CommandQueue::Properties::EnableProfiling

# Compile our OpenCL kernel
program = CrOpenCL::Program.new context, <<-PROGRAM

__kernel void sum(__global int * result, const int len)
{
  int idx = get_global_id(0);

  if (idx < len)
  {
    result[idx] = idx;
  }
}

PROGRAM

kern = CrOpenCL::Event.new "Kernel"
xout = CrOpenCL::Event.new "Transfer Out"

# Allocate output buffer
d_result = CrOpenCL::Buffer(Int32).new(context, CrOpenCL::Memory::WriteOnly, length: total)

# Run program
program.sum(queue, {total}, kern, nil, d_result, total)

# Get result back to host
result = d_result.get queue, event: xout

result.each_with_index do |el, idx|
  if el != idx
    puts "mismatch at index #{idx}: found #{el}, not #{idx}"
  end
end

{kern, xout}.each do |event|
  info = event.profiling_info
  puts "#{event.name} (#{event.execution_status}): #{(info[:finish] - info[:start]) / 1000} µs"
end
