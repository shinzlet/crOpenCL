require "../src/crOpenCL.cr"
require "random"
require "benchmark"

MAX_WORK_GROUP_SIZE = 0x1004

# Generate random inputs

total = 10000000
input = Array.new(total) {|x| x} # Random.rand(-10.0...10.0).to_i32 }

sum = 0f32

Benchmark.bm do |x|
  x.report "CPU sum" do
    sum = input.sum
  end
end

puts
puts sum
puts

# Prompts the user to choose a platform & device
context = CrOpenCL.create_some_context
queue = CrOpenCL::CommandQueue.new context, context.device, CrOpenCL::CommandQueue::Properties::EnableProfiling

# Compile our OpenCL kernel
program = CrOpenCL::Program.new context, <<-PROGRAM

kernel void sum(__global int *input,
            __global int *sum,
            __local float *scratch)
{
    uint local_id = get_local_id(0);
    sum[get_group_id(0)] = work_group_reduce_add(scratch[local_id]);
}

PROGRAM

xin = CrOpenCL::Event.new "Transfer In"
kern = CrOpenCL::Event.new "Kernel"
xout = CrOpenCL::Event.new "Transfer Out"

# Transfer inputs to device
d_buffer = CrOpenCL::Buffer.new(context, CrOpenCL::Memory::ReadOnly, hostbuf: input)
d_buffer.set queue, event: xin

d_output = CrOpenCL::Buffer(Int32).new(context, CrOpenCL::Memory::WriteOnly, length: total)

max_wg_size = uninitialized UInt64
max_wg_type_size = uninitialized UInt64


      # err = LibOpenCL.clGetDeviceInfo(@id, DeviceParameters::MaxWorkGroupSize, sizeof(UInt64), pointerof(max_work_group_size), nil)
      # raise CLError.new("clGetDeviceInfo failed.") unless err == LibOpenCL::CL_SUCCESS
      # @max_work_group_size = max_work_group_size

max_wg_size = context.device.max_work_group_size
# CrOpenCL::LibOpenCL.clGetDeviceInfo(context.device, MAX_WORK_GROUP_SIZE, 8, pointerof(max_wg_size), nil)#MAX_WORK_GROUP_SIZE)
# puts max_wg_type_size
puts "size: #{max_wg_size}"

# clSetKernelArg(kernel, 2, max_wg_size * sizeof(cl_float), NULL);
            #  ^ program?                       ^ reduction result type (T in Array(T))


target_buffer = CrOpenCL::Buffer(Int32).new(context, CrOpenCL::Memory::WriteOnly, length: max_wg_size)

# Run program
program.sum(queue, {total}, kern, nil, d_buffer, d_output, CrOpenCL::LocalMemory(Int32).auto)

# Get result back to host
result = d_buffer.get queue, event: xout
puts
puts res = result.sum
puts

puts sum - res

# result.each_with_index do |result_el, idx|
#   if result_el != expected[idx]
#     puts "mismatch at index #{idx}: #{result_el} (openCL) != #{expected[idx]} (crystal)"
#   end
# end

# Look at the runtimes of transfer and kernel
{xin, kern, xout}.each do |event|
  info = event.profiling_info
  puts "#{event.name} (#{event.execution_status}): #{(info[:finish] - info[:start]) / 1000} µs"
end
