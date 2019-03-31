require "../src/git"
require "./fixture_repo"
require "minitest/autorun"
require "http"

class RemoteNetworkTest < Minitest::Test
  def setup
    @repo = FixtureRepo.from_rugged("testrepo.git")
  end

  def repo
    @repo.as(Git::Repo)
  end

  def skip_if_unreachable
    ret = `curl -I https://github.com`
    if ret == ""
      skip "github is not reachable"
    end
  end

  def test_remote_network_connect
    skip_if_unreachable
    remote = repo.remotes.create_anonymous("git://github.com/libgit2/libgit2.git")
    ls = remote.as(Git::Remote).ls
    assert ls.as(Array(Hash(Symbol, Bool | String | Nil))).any?
  end
end
