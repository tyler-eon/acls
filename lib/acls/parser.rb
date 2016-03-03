module ACLS
  class Parser
    class << self

      def parse(base_dir, namespace=nil)
        parse_tree(Tree.new(nil, namespace, base_dir))
      end

      private

      def parse_tree(parent)
        Dir.entries(parent.directory).each do |entry|
          next if entry[0] == '.'
          full_path = "#{parent.directory}/#{entry}"
          name = entry.sub(".rb", "").strip.camelize
          if File.directory?(full_path)
            child = parent.make_child(name, full_path)
            parse_tree(child)
          else
            class_name = guess_classname(name, full_path)
            parent.make_child(class_name, parent.directory, full_path)
          end
        end
        parent
      end

      def guess_classname(name, file)
        process_classname_matches( scan_classnames(file), name )
      end

      def scan_classnames(file)
        contents = File.read(file)
        contents.scrub! if (contents.respond_to?(:scrub!))
        contents.scan(/(class|module)\s+([^\n\r<]+)/)
      end

      def process_classname_matches(matches, name)
        if match = best_classname_match(matches, name)
          base_classname(match[1])
        else
          name
        end
      end

      def best_classname_match(matches, name)
        return nil unless matches
        matches.drop_while { |match| !match_classname(match[1], name) }.first
      end

      def match_classname(match, name)
        base_classname(match).downcase == name.downcase
      end

      def base_classname(name)
        name.split("::").last.strip
      end
    end
  end
end
