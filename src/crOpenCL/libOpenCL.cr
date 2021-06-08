module CrOpenCL

{% if flag? :darwin %}
  @[Link(framework: "OpenCL")]
{% else %}
  @[Link("OpenCL")]
{% end %}
  lib LibOpenCL
    # Investigate actual types in OpenCL
    alias Kernel = Void*
    alias PlatformID = UInt64
    alias DeviceID = UInt64
    alias Context = Void*
    alias CommandQueue = Void*
    alias Mem = Void*
    alias Program = Void*
    alias Event = Void*
    alias Sampler = Void*

    # Constants
    CL_SUCCESS = 0
    CL_INVALID_EVENT = -58
    CL_PROFILING_INFO_NOT_AVAILABLE = -7
    CL_PROFILING_COMMAND_QUEUED = 4736i64
    CL_PROFILING_COMMAND_SUBMIT = 4737i64
    CL_PROFILING_COMMAND_START = 4738i64
    CL_PROFILING_COMMAND_END = 4739i64
    CL_EVENT_COMMAND_EXECUTION_STATUS = 4563i64
    CL_PROGRAM_BUILD_LOG = 4483
    CL_COMPLETE = 0
    CL_RUNNING = 1
    CL_SUBMITTED = 2
    CL_QUEUED = 3

    # Programs
    fun clCreateProgramWithSource(context : Context, count : UInt32, strings : UInt8**, lengths : UInt8*, errcode_ret : Int32*) : Program
    fun clBuildProgram(program : Program, num_devices : UInt32, device_list : DeviceID*, options : UInt8*, pfn_notify : (Program, Void* -> Void), user_data : Void*) : Int32
    # FIXME: param_name is actrually a cl_program_build_info enum
    fun clGetProgramBuildInfo(program : Program, device : DeviceID, param_name : Int64, param_value_size : UInt64, param_value : Void*, param_value_size_ret : UInt64*) : Int32
    fun clReleaseProgram(program : Program) : Int32

    # Contexts
    # FIXME: properties is actually a cl_context_properties enum *
    fun clCreateContext(properties : Int64*, num_devices : UInt32, devices : DeviceID*, pfn_notify : (UInt8*, Void*, UInt64, Void* -> Void), user_data : Void*, errcode_ret : Int32*) : Context
    fun clReleaseContext(context : Context) : Int32

    # Command Queues
    # FIXME: properties is actually a cl_command_queue_properties enum
    fun clCreateCommandQueue(context : Context, device : DeviceID, properties : Int64, errcode_ret : Int32*) : CommandQueue
    fun clReleaseCommandQueue(command_queue : CommandQueue) : Int32
    fun clFinish(command_queue : CommandQueue) : Int32

    # Kernels
    fun clCreateKernel(program : Program, kernel_name : UInt8*, errcode_ret : Int32*) : Kernel
    fun clReleaseKernel(kernel : Kernel) : Int32
    fun clSetKernelArg(kernel : Kernel, arg_index : Int32, arg_size : UInt64, arg_value : Void*) : Int32
    fun clEnqueueNDRangeKernel(command_queue : CommandQueue, kernel : Kernel, work_dim : UInt32, global_work_offset : UInt64*, global_work_size : UInt64*,
                               local_work_size : UInt64*, num_events_in_wait_list : Int32, event_wait_list : Event*, event : Event) : Int32
    # FIXME: param_name is actually a cl_kernel_work_group_info enum
    fun clGetKernelWorkGroupInfo(kernel : Kernel, device : DeviceID, param_name : Int64, param_value_size : UInt64, param_value : Void*, param_value_size_ret : UInt64*) : Int32

    # Memory
    # FIXME: flags is actually a cl_mem_flags enum
    fun clCreateBuffer(context : Context, flags : UInt64, size : UInt64, host_ptr : Void*, errcode_ret : Int32*) : Mem
    # FIXME: blocking_write is a cl_bool enum
    fun clEnqueueWriteBuffer(command_queue : CommandQueue, buffer : Mem, blocking_write : Int32, offset : UInt64, cb : UInt64, ptr : Void*,
                             num_events_in_wait_list : UInt32, event_wait_list : Event*, event : Event) : Int32
    # FIXME: blocking_read is a cl_bool enum
    fun clEnqueueReadBuffer(command_queue : CommandQueue, buffer : Mem, blocking_read : Int32, offset : UInt64, cb : UInt64, ptr : Void*,
                            num_events_in_wait_list : UInt32, event_wait_list : Event*, event : Event) : Int32
    fun clReleaseMemObject(memobj : Mem) : Int32

    # Events
    # FIXME: param_name is actually a cl_profiling_info enum
    fun clGetEventProfilingInfo(event : Event, param_name : Int64, param_value_size : UInt64, param_value : Void*, param_value_size_ret : UInt64*) : Int32
    fun clGetEventInfo(event : Event, param_name : Int64, param_value_size : UInt64, param_value : Void*, param_value_size_ret : UInt64*) : Int32
    fun clReleaseEvent(event : Event)

    # Device
    # FIXME: device_type is a cl_device_type enum
    fun clGetDeviceIDs(platform : PlatformID, device_type : Int64, num_entries : Int32, devices : DeviceID*, num_devices : UInt32*) : Int32
    # FIXME: param_name is a cl_device_info enum
    fun clGetDeviceInfo(device : DeviceID, param_name : UInt64, param_value_size : UInt64, param_value : Void*, param_value_size_ret : UInt64*) : Int32

    # Platform
    fun clGetPlatformIDs(num_entries : Int32, platforms : PlatformID*, num_platforms : UInt32*) : Int32
    fun clGetPlatformInfo(device : PlatformID, param_name : UInt64, param_value_size : UInt64, param_value : Void*, param_value_size_ret : UInt64*) : Int32

    enum Error : Int32
      SUCCESS = 0
      DEVICE_NOT_FOUND = -1
      DEVICE_NOT_AVAILABLE = -2
      COMPILER_NOT_AVAILABLE = -3
      MEM_OBJECT_ALLOCATION_FAILURE = -4
      OUT_OF_RESOURCES = -5
      OUT_OF_HOST_MEMORY = -6
      PROFILING_INFO_NOT_AVAILABLE = -7
      MEM_COPY_OVERLAP = -8
      IMAGE_FORMAT_MISMATCH = -9
      IMAGE_FORMAT_NOT_SUPPORTED = -10
      BUILD_PROGRAM_FAILURE = -11
      MAP_FAILURE = -12
      MISALIGNED_SUB_BUFFER_OFFSET = -13
      EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST = -14
      COMPILE_PROGRAM_FAILURE = -15
      LINKER_NOT_AVAILABLE = -16
      LINK_PROGRAM_FAILURE = -17
      DEVICE_PARTITION_FAILED = -18
      KERNEL_ARG_INFO_NOT_AVAILABLE = -19
      INVALID_VALUE = -30
      INVALID_DEVICE_TYPE = -31
      INVALID_PLATFORM = -32
      INVALID_DEVICE = -33
      INVALID_CONTEXT = -34
      INVALID_QUEUE_PROPERTIES = -35
      INVALID_COMMAND_QUEUE = -36
      INVALID_HOST_PTR = -37
      INVALID_MEM_OBJECT = -38
      INVALID_IMAGE_FORMAT_DESCRIPTOR = -39
      INVALID_IMAGE_SIZE = -40
      INVALID_SAMPLER = -41
      INVALID_BINARY = -42
      INVALID_BUILD_OPTIONS = -43
      INVALID_PROGRAM = -44
      INVALID_PROGRAM_EXECUTABLE = -45
      INVALID_KERNEL_NAME = -46
      INVALID_KERNEL_DEFINITION = -47
      INVALID_KERNEL = -48
      INVALID_ARG_INDEX = -49
      INVALID_ARG_VALUE = -50
      INVALID_ARG_SIZE = -51
      INVALID_KERNEL_ARGS = -52
      INVALID_WORK_DIMENSION = -53
      INVALID_WORK_GROUP_SIZE = -54
      INVALID_WORK_ITEM_SIZE = -55
      INVALID_GLOBAL_OFFSET = -56
      INVALID_EVENT_WAIT_LIST = -57
      INVALID_EVENT = -58
      INVALID_OPERATION = -59
      INVALID_GL_OBJECT = -60
      INVALID_BUFFER_SIZE = -61
      INVALID_MIP_LEVEL = -62
      INVALID_GLOBAL_WORK_SIZE = -63
      INVALID_PROPERTY = -64
      INVALID_IMAGE_DESCRIPTOR = -65
      INVALID_COMPILER_OPTIONS = -66
      INVALID_LINKER_OPTIONS = -67
      INVALID_DEVICE_PARTITION_COUNT = -68
      INVALID_PIPE_SIZE = -69
      INVALID_DEVICE_QUEUE = -70
      INVALID_SPEC_ID = -71
      MAX_SIZE_RESTRICTION_EXCEEDED = -72
    end
  end
end
