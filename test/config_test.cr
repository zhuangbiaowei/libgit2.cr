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

  def test_read_config_file
    config = repo.config
    assert_equal "false", config["core.bare"]
    assert_nil config["not.exist"]
  end

  def test_read_config_from_path
    config = Git::Config.new(File.join(repo.path, "config"))
    assert_equal "false", config["core.bare"]
  end

  def test_read_global_config_file
    config = Git::Config.global
    refute_nil config["user.name"]
    assert_nil config["core.bare"]
  end

  def test_snapshot
    config = Git::Config.new(File.join(repo.path, "config"))
    config["old.value"] = 5

    snapshot = config.snapshot
    assert_equal "5", snapshot["old.value"]

    config["new.value"] = 42
    config["old.value"] = 1337

    assert_equal "5", snapshot["old.value"]
    assert_nil snapshot["new.value"]
  end
end
