require "pronto/querly/version"
require "pronto"
require "querly"

module Pronto
  class Querly < Runner
    attr_reader :stderr

    def initialize(patches, commit=nil, stderr: STDERR)
      super(patches, commit)
      @stderr = stderr
    end

    def run
      repo_path = @patches.repo.path

      config = begin
        yaml = YAML.load(config_path.read)
        ::Querly::Config.load(yaml, config_path: config_path, root_dir: repo_path, stderr: stderr)
      rescue => exn
        stderr.puts "[pronto-querly] Failed to load Querly config from #{config_path.relative_path_from(repo_path)}: #{exn.inspect}"
        return []
      end

      path_to_patch = @patches.each.with_object({}) do |patch, hash|
        hash[patch.new_file_full_path] = patch
      end

      analyzer = ::Querly::Analyzer.new(config: config, rule: nil)
      ::Querly::ScriptEnumerator.new(paths: [repo_path], config: config).each do |path, script|
        case script
        when ::Querly::Script
          if path_to_patch.key?(path)
            analyzer.scripts << script
          end
        when StandardError, LoadError
          stderr.puts "[pronto-querly] Failed to load Ruby script from #{path.relative_path_from(repo_path)}: #{script.inspect}"
        end
      end

      [].tap do |messages|
        analyzer.run do |script, rule, pair|
          line_range = pair.node.loc.first_line..pair.node.loc.last_line
          patch = path_to_patch[script.path]

          if (intersection_line = patch.added_lines.find {|line| line_range.cover?(line.line.new_lineno) })
            src = pair.node.loc.expression.source.split(/\n/).first.strip
            message = "[#{rule.id}] #{rule.messages.join("\n").split(/\n/).first} (#{src})"
            relative_path = script.path.relative_path_from(repo_path)

            messages << Message.new(relative_path, intersection_line, :warning, message, nil, self.class)
          end
        end
      end
    end

    def config_path
      repo_path = @patches.repo.path
      [
        repo_path + Pathname("querly.yml"),
        repo_path + Pathname("querly.yaml")].compact.find(&:file?) || Pathname(options[:config]
      )
    end
  end
end

