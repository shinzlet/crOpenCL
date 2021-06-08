# This script reads the openCL header `cl.h`, and generates an
# enum from the error code directives within. Uses a subset of the
# lines after the block comment /* Error Codes */ and before the
# block comment introducing the next section.

START_LINE = "/* Error Codes */"
PREFIX = "enum Error : Int32"
POSTFIX = "end"

filepath = ARGV[0]? || "/usr/include/CL/cl.h"
in_error = false

data = File.each_line(filepath) do |line|
  if in_error
    if line.includes?("/*")
      break
    end

    words = line.gsub("\t", " ").squeeze(' ').split(' ')

    if words[0] == "#define"
      puts "  #{words[1][3..]} = #{words[2]}"
    end
  end

  if line == START_LINE
    in_error = true
    puts PREFIX
  end
end

puts POSTFIX
