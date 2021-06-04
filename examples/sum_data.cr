require "../src/crOpenCL.cr"
require "random"

# Generate random inputs
total = 190
in1 = Array.new(total) {|x| Random.rand(-10.0...10.0).to_i32 }
in2 = Array.new(total) {|x| Random.rand(-10.0...10.0).to_i32 }
expected = in1.map_with_index { |el, idx| in2[idx] + el }

# Prompts the user to choose a platform & device
context = CrOpenCL.create_some_context
queue = CrOpenCL::CommandQueue.new context, context.device, CrOpenCL::CommandQueue::Properties::EnableProfiling

# Compile our OpenCL kernel
program = CrOpenCL::Program.new context, <<-PROGRAM

__kernel void sum(__global int * result, __global int * in1, __global int * in2, const int len)
{
  int idx = get_global_id(0);
  if (idx < len)
  {
    result[idx] = in1[idx] + in2[idx];
  }
}

PROGRAM

xin1 = CrOpenCL::Event.new "Transfer 1 In"
xin2 = CrOpenCL::Event.new "Transfer 2 In"
kern = CrOpenCL::Event.new "Kernel"
xout = CrOpenCL::Event.new "Transfer Out"

# Transfer inputs to device
d_in1 = CrOpenCL::Buffer.new(context, CrOpenCL::Memory::ReadOnly, hostbuf: in1)
d_in2 = CrOpenCL::Buffer.new(context, CrOpenCL::Memory::ReadOnly, hostbuf: in2)
d_in1.set queue, event: xin1
d_in2.set queue, event: xin2
# Allocate output buffer
d_result = CrOpenCL::Buffer(Int32).new(context, CrOpenCL::Memory::WriteOnly, length: total)

# Run program
program.sum(queue, {total}, kern, nil, d_result, d_in1, d_in2, total)

# Get result back to host
result = d_result.get queue, event: xout

result.each_with_index do |result_el, idx|
  if result_el != expected[idx]
    puts "mismatch at index #{idx}: #{result_el} (openCL) != #{expected[idx]} (crystal)"
  end
end

# Look at the runtimes of transfer and kernel
events = { xin1, xin2, kern, xout }

events.each do |event|
  info = event.profiling_info
  puts "#{event.name} (#{event.execution_status}): #{(info[:finish] - info[:start]) / 1000} µs"
end
