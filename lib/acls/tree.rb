module ACLS
  class Tree
    attr_accessor :name, :directory, :source, :parent, :children

    def initialize(parent, name, directory, source=nil)
      @parent = parent
      @name = name
      @directory = directory
      @source = source
      @children = []
    end

    def make_child(name, directory, source=nil)
      child = Tree.new(self, name, directory, source)
      @children << child
      child
    end

    def path
      @source || @directory
    end

    def to_s
      "name: #{@name}, source: #{@source}, directory: #{@directory}, parent: #{@parent}, children: #{@children.length}"
    end

  end
end
