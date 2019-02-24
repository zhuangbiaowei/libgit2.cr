require "../src/git"
require "./fixture_repo"
require "minitest/autorun"

class ConfigTest < Minitest::Test
  def setup
    @repo = FixtureRepo.from_rugged("testrepo.git")
  end

  def repo
    @repo.as(Git::Repo)
  end

  def test_multi_fetch
    config = repo.config
    fetches = ["+refs/heads/*:refs/remotes/test_remote/*",
               "+refs/heads/*:refs/remotes/hello_remote/*"]
    assert_equal fetches, config.get_all("remote.test_multiple_fetches.fetch")
  end
end
