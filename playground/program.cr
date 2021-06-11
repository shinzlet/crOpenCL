# class Program
#   def self.build(&block)
#     builder = Builder.new
#     with builder yield
#     puts builder.to_s
#   end
# 
#   private class Builder
#     @string_builder : String::Builder
# 
#     def initialize(capacity)
#       @string_builder 
#     end
#   end
# end
# 
# Program.build do
# end
