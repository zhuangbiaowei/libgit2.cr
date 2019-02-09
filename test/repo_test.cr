require "../src/git"
require "./fixture_repo"
require "minitest/autorun"

class RepoyTest < Minitest::Test
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

  def test_loading_alternates
    alt_path = File.dirname(__FILE__) + "/fixtures/alternate/objects"
    repo2 = Git::Repository.new(repo.path, {:alternates => [alt_path]})

    assert_equal 1703, repo2.each_id.size
    assert repo2.read("146ae76773c91e3b1d00cf7a338ec55ae58297e2")
  end

  #def test_alternates_with_invalid_path_type
    #assert_raises Git::Error do
    #  Git::Repository.new(repo.path, {:alternates => ["invalid_input"]})
    #end
  #end

  def test_find_merge_base_between_oids
    commit1 = "a4a7dce85cf63874e984719f4fdd239f5145052f"
    commit2 = "a65fedf39aefe402d3bb6e24df4d4f5fe4547750"
    base    = "c47800c7266a2be04c571c04d5a6614691ea99bd"
    assert_equal base, repo.merge_base(commit1, commit2)
  end

  def test_find_merge_base_between_commits
    commit1 = repo.lookup("a4a7dce85cf63874e984719f4fdd239f5145052f")
    commit2 = repo.lookup("a65fedf39aefe402d3bb6e24df4d4f5fe4547750")
    base    = "c47800c7266a2be04c571c04d5a6614691ea99bd"
    assert_equal base, repo.merge_base(commit1, commit2)
  end

  def test_find_merge_base_between_ref_and_oid
    commit1 = "a4a7dce85cf63874e984719f4fdd239f5145052f"
    commit2 = "refs/heads/master"
    base    = "c47800c7266a2be04c571c04d5a6614691ea99bd"
    assert_equal base, repo.merge_base(commit1, commit2)
  end

  def test_find_merge_base_between_many
    commit1 = "a4a7dce85cf63874e984719f4fdd239f5145052f"
    commit2 = "refs/heads/packed"
    commit3 = repo.lookup("a65fedf39aefe402d3bb6e24df4d4f5fe4547750")

    base    = "c47800c7266a2be04c571c04d5a6614691ea99bd"
    assert_equal base, repo.merge_base(commit1, commit2, commit3)
  end

  def test_find_merge_bases_between_oids
    commit1 = "a4a7dce85cf63874e984719f4fdd239f5145052f"
    commit2 = "a65fedf39aefe402d3bb6e24df4d4f5fe4547750"

    assert_equal [
      "c47800c7266a2be04c571c04d5a6614691ea99bd", "9fd738e8f7967c078dceed8190330fc8648ee56a"
    ], repo.merge_bases(commit1, commit2)
  end

  def test_find_merge_bases_between_commits
    commit1 = repo.lookup("a4a7dce85cf63874e984719f4fdd239f5145052f")
    commit2 = repo.lookup("a65fedf39aefe402d3bb6e24df4d4f5fe4547750")

    assert_equal [
      "c47800c7266a2be04c571c04d5a6614691ea99bd", "9fd738e8f7967c078dceed8190330fc8648ee56a"
    ], repo.merge_bases(commit1, commit2)
  end

  def test_find_merge_bases_between_ref_and_oid
    commit1 = "a4a7dce85cf63874e984719f4fdd239f5145052f"
    commit2 = "refs/heads/master"

    assert_equal [
      "c47800c7266a2be04c571c04d5a6614691ea99bd", "9fd738e8f7967c078dceed8190330fc8648ee56a"
    ], repo.merge_bases(commit1, commit2)
  end

  def test_find_merge_bases_between_many
    commit1 = "a4a7dce85cf63874e984719f4fdd239f5145052f"
    commit2 = "refs/heads/packed"
    commit3 = repo.lookup("a65fedf39aefe402d3bb6e24df4d4f5fe4547750")

    assert_equal [
      "c47800c7266a2be04c571c04d5a6614691ea99bd", "9fd738e8f7967c078dceed8190330fc8648ee56a"
    ], repo.merge_bases(commit1, commit2, commit3)
  end

  def test_ahead_behind_with_oids
    ahead, behind = repo.ahead_behind(
      "a4a7dce85cf63874e984719f4fdd239f5145052f",
      "a65fedf39aefe402d3bb6e24df4d4f5fe4547750"
    )
    assert_equal 1, ahead
    assert_equal 2, behind
  end

  def test_ahead_behind_with_commits
    ahead, behind = repo.ahead_behind(
      repo.lookup("a4a7dce85cf63874e984719f4fdd239f5145052f"),
      repo.lookup("a65fedf39aefe402d3bb6e24df4d4f5fe4547750")
    )
    assert_equal 1, ahead
    assert_equal 2, behind
  end

  def test_expand_objects
    expected = {
      "a4a7dce8" => "a4a7dce85cf63874e984719f4fdd239f5145052f",
      "a65fedf3" => "a65fedf39aefe402d3bb6e24df4d4f5fe4547750",
      "c47800c7" => "c47800c7266a2be04c571c04d5a6614691ea99bd"
    }

    assert_equal expected, repo.expand_oids(["a4a7dce8", "a65fedf3", "c47800c7", "deadbeef"])
  end

  def test_expand_and_filter_objects
    assert_equal 2, repo.expand_oids(["a4a7dce8", "1385f264af"]).size
    assert_equal 1, repo.expand_oids(["a4a7dce8", "1385f264af"], :commit).size
    assert_equal 2, repo.expand_oids(["a4a7dce8", "1385f264af"], ["commit", "blob"]).size
    assert_equal 1, repo.expand_oids(["a4a7dce8", "1385f264af"], [:commit, :tag]).size

    assert_raises Git::Error do
      repo.expand_oids(["a4a7dce8", "1385f264af"], [:commit, :tag, :commit]).size
    end

    assert_raises Git::Error do
      repo.expand_oids(["a4a7dce8", "1385f264af"], [:commit]).size
    end
  end

  def test_descendant_of
    # String commit OIDs
    assert repo.descendant_of?("a65fedf39aefe402d3bb6e24df4d4f5fe4547750", "be3563ae3f795b2b4353bcce3a527ad0a4f7f644")
    assert !repo.descendant_of?("be3563ae3f795b2b4353bcce3a527ad0a4f7f644", "a65fedf39aefe402d3bb6e24df4d4f5fe4547750")

    # Rugged::Commit instances
    commit = repo.lookup("a65fedf39aefe402d3bb6e24df4d4f5fe4547750")
    ancestor = repo.lookup("be3563ae3f795b2b4353bcce3a527ad0a4f7f644")

    assert repo.descendant_of?(commit, ancestor)
    assert !repo.descendant_of?(ancestor, commit)
  end
end

