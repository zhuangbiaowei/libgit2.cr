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

  def test_fails_to_open_unexisting_repos
    assert_raises Git::Error do
      Git::Repository.new("fakepath/123/")
    end
    assert_raises Git::Error do
      Git::Repository.new("test")
    end
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

  def test_can_read_object_headers
    hash = repo.read_header("8496071c1b46c854b31185ea97743be6a8774479")
    assert_equal 172, hash[:len]
    assert_equal :commit, hash[:type]
  end

  def test_check_reads_fail_on_missing_objects
    assert_raises Git::Error do
      repo.read("a496071c1b46c854b31185ea97743be6a8774471")
    end
  end

  def test_check_read_headers_fail_on_missing_objects
    assert_raises Git::Error do
      repo.read_header("a496071c1b46c854b31185ea97743be6a8774471")
    end
  end

  def test_walking_with_block
    oid = "a4a7dce85cf63874e984719f4fdd239f5145052f"
    list = [] of Git::Commit
    repo.walk(oid) { |c| list << c }
    assert list.map {|c| c.oid[0,5] }.join('.'), "a4a7d.c4780.9fd73.4a202.5b5b0.84960"
  end

  def test_walking_without_block
    commits = repo.walk("a4a7dce85cf63874e984719f4fdd239f5145052f")

    assert commits.is_a?(Enumerable)
    assert commits.size > 0
  end


  def test_lookup_object
    object = repo.lookup("8496071c1b46c854b31185ea97743be6a8774479")
    assert object.is_a?(Git::Commit)
  end

  def test_find_reference
    ref = repo.ref("refs/heads/master")

    assert ref.is_a?(Git::Reference)
    assert_equal "refs/heads/master", ref.name
  end

  def test_match_all_refs
    refs = repo.refs "refs/heads/*"
    assert_equal 12, refs.size
  end

  def test_return_all_ref_names
    refs = repo.ref_names
    refs.each {|name| assert name.is_a?(String)}
    assert_equal 30, refs.size
  end

  def test_return_all_tags
    tags = repo.tags
    assert_equal 7, tags.size
  end

  def test_return_matching_tags
    assert_equal 1, repo.tags.each("e90810b").size
    assert_equal 4, repo.tags.each("*tag*").size
  end

  def test_return_all_remotes
    remotes = repo.remotes
    assert_equal 5, remotes.size
  end

  def test_lookup_head
    head = repo.head
    assert_equal "refs/heads/master", head.name
    assert_equal "a65fedf39aefe402d3bb6e24df4d4f5fe4547750", head.target_id
    assert_equal :direct, head.type
  end

  def test_set_head_ref
    repo.head = "refs/heads/packed"
    assert_equal "refs/heads/packed", repo.head.name
  end

  def test_set_head_invalid
    assert_raises Git::Error do
      repo.head = "a65fedf39aefe402d3bb6e24df4d4f5fe4547750"
    end
  end

  def test_access_a_file
    sha = "a65fedf39aefe402d3bb6e24df4d4f5fe4547750"
    blob = repo.blob_at(sha, "new.txt")
    assert nil != blob
    assert_equal "my new file\n", blob.as(Git::Blob).content
  end

  def test_access_a_missing_file
    sha = "a65fedf39aefe402d3bb6e24df4d4f5fe4547750"
    blob = repo.blob_at(sha, "file-not-found.txt")
    assert_nil blob
  end

  def test_enumerate_all_objects
    assert_equal 1700, repo.each_id.size
  end
end

