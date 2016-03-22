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

    # If a source file is specified, returns the path to the source file.
    def path
      @source || @directory
    end

    # Find the first child with a given name, including the calling node in the
    # search.
    def find(name)
      return self if @name == name
      @children.find { |child| child.find(name) }
    end

    def to_s(level=0)
      tab = '**' * 2 * level
      <<EOS
#{tab}     level: #{level}
#{tab}      name: #{@name}
#{tab}    source: #{@source}
#{tab} directory: #{@directory}
#{tab}  children => [
#{@children.map { |child| child.to_s(level+1) }.join}
#{tab}  ]
EOS
    end

  end
end
