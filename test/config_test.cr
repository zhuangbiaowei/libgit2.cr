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

  def teardown
    FileUtils.rm_r(repo.path)
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

  def test_transaction
    config = Git::Config.new(File.join(repo.path, "config"))
    config["section.name"] = "value"

    config2 = Git::Config.new(File.join(repo.path, "config"))

    config.transaction do
      config["section.name"] = "other value"
      config["section2.name3"] = "more value"

      assert_equal "value", config2["section.name"]
      assert_nil config2["section2.name3"]

      assert_equal "value", config["section.name"]
      assert_nil config["section2.name3"]
    end

    assert_equal "other value", config["section.name"]
    assert_equal "more value", config["section2.name3"]
    assert_equal "other value", config2["section.name"]
    assert_equal "more value", config2["section2.name3"]
  end
end

class ConfigWriteTest < Minitest::Test
  def setup
    @repo = FixtureRepo.clone(FixtureRepo.from_rugged("testrepo.git"))
  end

  def repo
    @repo.as(Git::Repo)
  end

  def teardown
    FileUtils.rm_r(repo.path)
  end

  def test_write_config_values
    config = repo.config
    config["custom.value"] = "my value"

    config2 = repo.config
    assert_equal "my value", config2["custom.value"]

    content = File.read(File.join(repo.path, ".git/config"))
    assert_match(/value = my value/, content)
  end

  def test_delete_config_values
    config = repo.config
    config.delete("core.bare")

    config2 = repo.config
    assert_nil config2.get("core.bare")
  end
end

