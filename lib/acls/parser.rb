module ACLS
  class Parser
    class << self

      # Given a base directory, parse all Ruby source files into a custom Tree
      # representation.
      def parse(base_dir)
        parse_tree(Tree.new(nil, nil, base_dir), base_dir)
      end

      private

      # Attempt to parse a collection of module/class names to determine a
      # fully-qualified namespace for a source module/class.
      def parse_names(node, parent, source)
        return parent if node.nil?

        parent = parse_names(node.children.first, parent, source)
        parent.make_child(node.children.last, '', source)
      end

      # Parse an AST to get the top-most parent name and build a module/class
      # chain from there.
      def parse_parent(ast, parent, source)
        name = ast.children.first
        parse_names(name, parent, source)
      end

      # Parse a module. Similar to parsing a class, except you continue to parse
      # child nodes.
      def parse_module(ast, parent, source)
        parent = parse_parent(ast, parent, source)
        ast.children[1..-1].map { |node| parse_ast(node, parent, source) }
      end

      # Parse a class. Similar to parsing a module, except you do not parse any
      # child nodes.
      def parse_class(ast, parent, source)
        parse_parent(ast, parent, source)
      end

      # Parse an AST Node.
      def parse_ast(ast, parent, source)
        return if ast.nil? || !ast.is_a?(::AST::Node)

        if ast.type == :module
          parse_module(ast, parent, source)
        elsif ast.type == :class
          parse_class(ast, parent, source)
        else
          ast.children.each { |node| parse_ast(node, parent, source) }
        end

        parent
      end

      # Convert a source file into an AST and parse it.
      def parse_file(tree, file)
        ast = ::Parser::CurrentRuby.parse(File.read(file))
        parse_ast(ast, tree, file)
      end

      def parse_tree(tree, directory)
        Dir.entries(directory).each do |entry|
          next if entry[0] == '.'
          full_path = "#{directory}/#{entry}"
          if File.directory?(full_path)
            parse_tree(tree, full_path)
          elsif entry.end_with?('.rb')
            parse_file(tree, full_path)
          end
        end
        tree
      end

    end
  end
end
