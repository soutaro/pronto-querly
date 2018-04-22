$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "pronto/querly"
require "open3"

require "minitest/autorun"

module ShellHelper
  attr_reader :dirs

  def push_dir(dir)
    @dirs ||= []

    @dirs.push dir
    yield
  ensure
    @dirs.pop
  end

  def current_dir
    @dirs&.last
  end

  def sh!(command_line)
    stdout, stderr, status = Open3.capture3(*command_line, chdir: current_dir.to_s)
    unless status.success?
      puts command_line.join(" ")
      puts stdout
      puts stderr
      raise
    end
    [stdout, stderr]
  end
end
