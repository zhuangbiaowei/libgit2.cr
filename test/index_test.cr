require "../src/git"
require "./fixture_repo"
require "minitest/autorun"

class IndexTest < Minitest::Test
  def self.new_index_entry
      now = Time.now
      {
        :path => "new_path",
        :oid => "d385f264afb75a56a5bec74243be9b367ba4ca08",
        :mtime => now,
        :ctime => now,
        :file_size => 1000,
        :dev => 234881027,
        :ino => 88888,
        :mode => 33188,
        :uid => 502,
        :gid => 502,
        :stage => 3,
      }
  end

  def setup
    path = File.dirname(__FILE__) + "/fixtures/index-repo.git/index"
    @index = Git::Index.new(path)
  end

  def index
    @index.as(Git::Index)
  end

  def test_iteration
    enu = index.each
    assert enu.is_a? Enumerable

    i = 0
    index.each { |e| i += 1 }
    assert_equal index.count, i
  end

  def test_index_size
    assert_equal 2, index.count
  end

  def test_empty_index
    index.clear
    assert_equal 0, index.count
  end

  def test_remove_entries
    index.remove "new.txt"
    assert_equal 1, index.count
  end

  def test_remove_dir
    index.remove_dir "does-not-exist"
    assert_equal 2, index.count

    index.remove_dir "", 2
    assert_equal 2, index.count

    index.remove_dir ""
    assert_equal 0, index.count
  end

end
