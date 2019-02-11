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

  def test_get_entry_data
    e = index[0]
    assert_equal "README", e[:path]
    assert_equal "1385f264afb75a56a5bec74243be9b367ba4ca08", e[:oid]
    assert_equal 1273360380, e[:mtime].as(Time).to_unix
    assert_equal 1273360380, e[:ctime].as(Time).to_unix
    assert_equal 4, e[:file_size]
    assert_equal 234881026, e[:dev]
    assert_equal 6674088, e[:ino]
    assert_equal 33188, e[:mode]
    assert_equal 501, e[:uid]
    assert_equal 0, e[:gid]
    assert_equal false, e[:valid]
    assert_equal 0, e[:stage]

    e = index[1]
    assert_equal "new.txt", e[:path]
    assert_equal "fa49b077972391ad58037050f2a75f74e3671e92", e[:oid]
  end

  def test_iterate_entries
    itr_test = index.sort { |a, b| a[:oid].to_s <=> b[:oid].to_s }.map { |e| e[:path] }.join(':')
    assert_equal "README:new.txt", itr_test
  end

end
