require "../src/git"
require "./fixture_repo"
require "minitest/autorun"

class RepoTest < Minitest::Test
  def setup
    @repo = FixtureRepo.from_libgit2 "testrepo.git"
  end

  def repo : Git::Repository
    return @repo.as(Git::Repository)
  end

  def test_last_commit_id
    assert repo.responds_to? :last_commit
    assert "36060c58702ed4c2a40832c51758d5344201d89a", repo.last_commit.oid
  end

  def test_can_check_if_objects_exist
    assert repo.exists?("8496071c1b46c854b31185ea97743be6a8774479")
    assert repo.exists?("1385f264afb75a56a5bec74243be9b367ba4ca08")
    assert !repo.exists?("ce08fe4884650f067bd5703b6a59a8b3b3c99a09")
    assert !repo.exists?("8496071c1c46c854b31185ea97743be6a8774479")
  end

  def test_can_read_a_raw_object
    rawobj = repo.read("8496071c1b46c854b31185ea97743be6a8774479")
    assert_match "tree 181037049a54a1eb5fab404658a3a250b44335d7", rawobj.data
    assert_equal 172, rawobj.len
    assert_equal :commit, rawobj.type
  end

end

