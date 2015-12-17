require 'active_support/inflector'
require_relative './module'

module ACLS
  class Loader
    class << self
      # Use one or more paths to autoload a set of Ruby source files.
      def auto(paths, opts={})
        if paths.respond_to?(:each)
          paths.each { |path| autoload_path(path, opts) }
        else
          autoload_path(paths, opts)
        end
      end

      private

      def get_root_ns(path, opts)
        root_ns = opts[:root_ns]
        root = Object
        if root_ns.is_a?(TrueClass)
          root = root.submodule(File.basename(path).camelize)
        elsif root_ns.is_a?(String)
          root_ns.split('::').each { |ns| root = root.submodule(ns) }
        end
        root
      end

      def autoload_path(path, opts)
        if File.directory?(path)
          root_ns = get_root_ns(path, opts)
          autoload_magic(root_ns, path, opts)
        else
          raise Errno::ENOENT.new(path)
        end
      end

      def autoload_magic(mod, path, opts)
        # TODO: Add opts usage
        Dir.entries(path).each do |entry|
          next if entry[0] == '.'
          full_path = "#{path}/#{entry}"
          name = entry.sub(".rb", "").camelize
          if File.directory?(full_path)
            sub_mod = mod.submodule(name)
            autoload_magic(sub_mod, full_path, opts)
          else
            autoload_for(mod, full_path, name)
          end
        end
      end

      def autoload_for(mod, path, name)
        klass = guess_classname(path, name)
        code = "autoload :#{klass}, \"#{path}\""
        if mod.nil?
          eval(code)
        else
          mod.module_eval(code)
        end
      end

      def guess_classname(file, name)
        if matches = File.read(file).scan(/(class|module)\s+([^\n\r<]+)/)
          matches.each do |data|
            potential = data[1].split("::").last
            if potential.downcase.index(name.downcase)
              return potential
            end
          end
        end
        name
      end
    end
  end
end
