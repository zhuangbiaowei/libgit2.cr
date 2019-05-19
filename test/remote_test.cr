require "../src/git"
require "./fixture_repo"
require "minitest/autorun"
require "http"

class RemoteNetworkTest < Minitest::Test
  def setup
    @repo = FixtureRepo.from_libgit2("testrepo.git")
  end

  def repo
    @repo.as(Git::Repo)
  end

  def skip_if_unreachable
    # ret = `curl -I -s https://github.com`
    # if ret == ""
    #  skip "github is not reachable"
    # end
  end

  def test_remote_network_connect
    skip_if_unreachable
    remote = repo.remotes.create_anonymous("git://github.com/libgit2/libgit2.git")
    ls = remote.as(Git::Remote).ls
    assert ls.as(Array(Hash(Symbol, Bool | String | Nil))).any?
  end

  def test_remote_check_connection_fetch
    skip_if_unreachable
    remote = repo.remotes.create_anonymous("git://github.com/libgit2/libgit2.git")
    assert remote.as(Git::Remote).check_connection(:fetch)
  end

  def test_remote_check_connection_push
    skip_if_unreachable
    remote = repo.remotes.create_anonymous("git://github.com/libgit2/libgit2.git")
    assert !remote.as(Git::Remote).check_connection(:push)
  end

  def test_remote_check_connection_push_credentials
    skip_if_unreachable
    remote = repo.remotes.create_anonymous("https://github.com/libgit2-push-test/libgit2-push-test.git")
    credentials = Git::Credentials::UserPassword.new({username: "libgit2-push-test", password: "123qwe123"})
    assert remote.check_connection(:push, {credentials: credentials})
  end
end

class RemoteTest < Minitest::Test

  def setup
    @repo = FixtureRepo.from_libgit2("testrepo.git")
  end

  def repo
    @repo.as(Git::Repo)
  end

  def test_list_remote_names
    #assert_equal ["empty-remote-pushurl", "empty-remote-url", "joshaber", "test", "test_with_pushurl"], repo.remotes.each_name.sort
  end

  def test_list_remotes
    #assert repo.remotes.kind_of? Enumerable
    #assert_equal ["empty-remote-pushurl", "empty-remote-url", "joshaber", "test", "test_with_pushurl"], repo.remotes.map(&:name).sort
  end

  def test_remote_new_name
    remote = repo.remotes.create_anonymous("git://github.com/libgit2/libgit2.git")
    assert_nil remote.name
    assert_equal "git://github.com/libgit2/libgit2.git", remote.url
  end

  def test_remote_new_invalid_url
    repo.remotes.create_anonymous("libgit2")
  end

  def test_remote_delete
    repo.remotes.delete("test")
    assert_nil repo.remotes["test"]
  end

  def test_push_url
    assert_equal "git://github.com/libgit2/pushlibgit2", repo.remotes["test_with_pushurl"].as(Git::Remote).push_url
    assert_nil repo.remotes["joshaber"].as(Git::Remote).push_url
  end

end
