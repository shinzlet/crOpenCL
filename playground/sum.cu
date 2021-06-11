__kernel void sum(__global int *input, __global int *output, const int size)
{
  int global_id = get_global_id(0);
  int local_id = get_local_id(0);

  
  int step_size = 1;

  int block_size = get_local_size(0)

  int num_elements = block_size;
  int thread_count = num_elements >> 1;

  while (thread_count > 0) {
    if (id < thread_count) {
      int idx_1 = id * step_size * 2;
      int idx_2 = idx_1 + step_size;
      input[idx_1] += input[idx_2];
    }

    // Wait for all threads to complete
    barrier(CLK_GLOBAL_MEM_FENCE);

    // Update step size and thread count for next iteration
    step_size <<= 1;
    num_elements = (num_elements + 1) >> 1;
    thread_count = num_elements >> 1;
  }
}