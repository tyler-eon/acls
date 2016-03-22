module ACLS
  class Loader
    class << self
      # Use one or more paths to autoload a set of Ruby source files.
      def auto(paths, opts={})
        opts = default_opts.merge(opts)
        autoload_trees(build_trees(paths, opts), opts)
      end

      def default_opts
        {root_ns: false, exclude: [], immediate: []}
      end

      private

      def build_trees(paths, opts)
        paths = [paths] unless paths.respond_to?(:map)
        paths.map { |path| Parser.parse(path) }
      end

      def autoload_statement(tree)
        "autoload :#{tree.name}, \"#{tree.source}\""
      end

      def autoload_tree(mod, tree, opts)
        unless exclude?(tree, opts)
          if tree.children.empty?
            mod.module_eval(autoload_statement(tree))
          else
            mod = submodule(mod, tree.name)
          end
          tree.children.map { |child| autoload_tree(mod, child, opts) }
        end
      end

      def autoload_trees(trees, opts)
        trees.map do |tree|
          root = Object
          tree.children.map do |node|
            autoload_tree(root, node, opts)
          end
        end
      end

      def exclude?(tree, opts)
        opts[:exclude].each do |pattern|
          if pattern.is_a?(String)
            return true if pattern == File.basename(tree.path, ".rb")
          else
            return true if pattern.match(tree.path)
          end
        end
        false
      end

      def submodule(parent, child)
        parent.const_get(child, false)
      rescue NameError
        parent.const_set(child, Module.new)
      end

    end
  end
end
