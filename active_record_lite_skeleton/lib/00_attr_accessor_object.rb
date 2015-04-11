class AttrAccessorObject

  def self.my_attr_accessor(*args)
    args.each do |arg|
      define_method(arg) do
        instance_variable_get("@"+arg.to_s)
      end
      define_method((arg.to_s+"=").to_sym) do |block|
        instance_variable_set("@"+arg.to_s,block)
      end
    end
  end

  my_attr_accessor(:x,:y)

  def initialize
    @x = 'car'
  end




  #   (*args)
  #   args.each do |arg|
  #     define_method(arg) do
  #       instance_variable_get("@"+arg.to_s)
  #     end
  #     define_method(arg.to_s+"=") do
  #       instance_variable_set("@"+arg.to_s, "hello")
  #     end
  #   end
  # end







end
