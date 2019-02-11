@[Link("git2")]
lib LibGit
  type Index = Void*
  struct IndexEntry
    ctime : IndexTime
    mtime : IndexTime
    dev : Uint32T
    ino : Uint32T
    mode : Uint32T
    uid : Uint32T
    gid : Uint32T
    file_size : Uint32T
    id : Oid
    flags : Uint16T
    flags_extended : Uint16T
    path : LibC::Char*
  end
  struct IndexTime
    seconds : Int32T
    nanoseconds : Uint32T
  end
  alias X__Int32T = LibC::Int
  alias Int32T = X__Int32T

  fun index_open = git_index_open(out : Index*, index_path : LibC::Char*) : LibC::Int
  fun index_free = git_index_free(index : Index)
  fun index_entrycount = git_index_entrycount(index : Index) : LibC::SizeT

  fun index_iterator_new = git_index_iterator_new(iterator_out : IndexIterator*, index : Index) : LibC::Int
  type IndexIterator = Void*
  fun index_iterator_next = git_index_iterator_next(out : IndexEntry**, iterator : IndexIterator) : LibC::Int
  fun index_iterator_free = git_index_iterator_free(iterator : IndexIterator)
  fun index_clear = git_index_clear(index : Index) : LibC::Int
  fun index_remove = git_index_remove(index : Index, path : LibC::Char*, stage : LibC::Int) : LibC::Int
  fun index_remove_directory = git_index_remove_directory(index : Index, dir : LibC::Char*, stage : LibC::Int) : LibC::Int
  fun index_get_byindex = git_index_get_byindex(index : Index, n : LibC::SizeT) : IndexEntry*
  fun index_get_bypath = git_index_get_bypath(index : Index, path : LibC::Char*, stage : LibC::Int) : IndexEntry*
  fun index_has_conflicts = git_index_has_conflicts(index : Index) : LibC::Int
end
