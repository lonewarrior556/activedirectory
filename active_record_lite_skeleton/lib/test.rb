class Test

  def self.columns
    [:x,:y,:z]
  end


  self.columns.each do |column|
    define_method(column) do
      self.attributes[column]
    end
    define_method((column.to_s+"=").to_sym) do |block|
      self.attributes[column] = block
    end
  end

  def attributes
    @attributes
  end

  def initialize
    @attributes = {x:5}
end



{id: 1, name:"gizmo", owner:1}.dup.delete(:id).to_s.gsub(":","").gsub(">","")
