require "test_helper"

class Pronto::QuerlyTest < Minitest::Test
  include ShellHelper

  def prepare_worktree(dir)
    push_dir(dir) do
      sh!(%w{git init .})
      sh!(%w{bundle exec querly init})
      sh!(%w{mkdir lib})
      (dir + "lib/foo.rb").write(<<EOS)
class Foo
  def test()
    raise Exception
  end
end
EOS
      sh!(%w{git add .})
      sh!(%w{git commit -m Commit1 })

      sh!(%w{mkdir spec})
      (dir + "spec/foo_spec.rb").write(<<EOS)
RSpec.describe Foo do
  it "raises" do
    p Foo.new
    expect { Foo.new.test }.to raises_error
  end
end
EOS

      sh!(%w{git checkout -b feature})
      (dir + "lib/foo.rb").write(<<EOS)
class Foo
  def test()
    raise Exception
  end
end

io = File.open('output.txt')
io.puts Foo.test
io.close
EOS

      (dir + ".pronto.yml").write(<<EOS)
all:
  exclude:
    - 'spec/**/*'
EOS
      sh!(%w{git add .})
      sh!(%w{git commit -m Commit2})

      yield
    end
  end

  def test_pronto_success
    Dir.mktmpdir do |dir|
      path = Pathname(dir)
      prepare_worktree path do
        stdout, stderr = sh!(%w{bundle exec pronto run})

        assert stdout.lines.any? {|line| line =~ /^lib\/foo\.rb:7/ }
        refute stdout.lines.any? {|line| line =~ /^lib\/foo\.rb:3/ }
        refute stdout.lines.any? {|line| line =~ /^spec\/foo_spec\.rb:3/ }

        assert_equal "", stderr
      end
    end
  end

  def test_handling_syntax_error_in_ruby
    Dir.mktmpdir do |dir|
      path = Pathname(dir)
      prepare_worktree path do
        (path + "lib/bar.rb").write(<<EOS)
class Bar
  def foo
    Syntax Error
EOS
        sh!(%w{git add .})
        sh!(%w{git commit -m Commit3})

        stdout, stderr = sh!(%w{bundle exec pronto run})

        assert stdout.lines.any? {|line| line =~ /^lib\/foo\.rb:7/ }
        refute stdout.lines.any? {|line| line =~ /^lib\/foo\.rb:3/ }
        refute stdout.lines.any? {|line| line =~ /^spec\/foo_spec\.rb:3/ }

        assert_match /^\[pronto-querly\] Failed to load Ruby script from lib\/bar\.rb:/, stderr
      end
    end
  end

  def test_handling_syntax_error_in_config
    Dir.mktmpdir do |dir|
      path = Pathname(dir)
      prepare_worktree path do
        (path + "querly.yml").write(<<EOS)
aaaa bbb ccc
foo:
    bar
  - 1 2 3
EOS
        sh!(%w{git add .})
        sh!(%w{git commit -m Commit3})

        stdout, stderr = sh!(%w{bundle exec pronto run})

        assert_equal "", stdout
        assert_match /\[pronto-querly\] Failed to load Querly config from querly\.yml:/, stderr
      end
    end
  end
end
