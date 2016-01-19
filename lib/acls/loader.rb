module ACLS
  class Loader
    class << self
      # Use one or more paths to autoload a set of Ruby source files.
      def auto(paths, opts={})
        trees = build_trees(paths, opts)
        autoload_magic(trees, opts)
      end

      private

      def build_trees(paths, opts)
        if paths.respond_to?(:each)
          paths.map { |path| build_tree(path, opts) }
        else
          [build_tree(paths, opts)]
        end
      end

      def build_tree(path, opts)
        Parser.parse(path)
      end

      def autoload_statement(tree)
        "autoload :#{tree.name}, \"#{tree.source}\""
      end

      def autoload_root(tree, opts)
          root = Object
          if opts[:root_ns].is_a?(TrueClass)
            root = submodule(root, File.basename(tree.directory).camelize)
          elsif opts[:root_ns].is_a?(String)
            opts[:root_ns].split('::').each { |ns| root = submodule(root, ns) }
          end
          root
      end

      def autoload_magic(trees, opts)
        trees.map do |tree|
          root = autoload_root(tree, opts)
          tree.children.map do |node|
            autoload_tree(root, node, opts)
          end
        end
      end

      def autoload_tree(mod, tree, opts)
        if tree.source
          mod.module_eval(autoload_statement(tree))
        else
          sub = submodule(mod, tree.name)
          tree.children.map { |child| autoload_tree(sub, child, opts) }
        end
      end

      def submodule(parent, child)
        parent.const_get(child, false)
      rescue NameError
        parent.const_set(child, Module.new)
      end

    end
  end
end
