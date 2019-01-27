require "../src/git"
require "./fixture_repo"
require "minitest/autorun"
#obj = git.read("a72d5e35f768a9a0dba3a7bbe06b635b4eac4d37")
#puts obj[:type]
#puts obj[:len]
#puts obj[:data]

class RepoTest < Minitest::Test
  def setup
    @repo = FixtureRepo.from_libgit2 "testrepo.git"
  end

  def test_last_commit_id
    commit_id=`git log -1 --pretty=format:"%H"`
    git = Git::Repository.open(".")
    oid = git.last_commit.oid
    assert_equal commit_id, oid
    assert_equal true, git.exists?(oid)
  end
end

