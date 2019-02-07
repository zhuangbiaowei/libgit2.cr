@[Link("git2")]
lib LibGit
  type Odb = Void*
  type OdbBackend = Void*
  type OdbObject = Void*
  type OdbStream = Void*
  type OdbWritepack = Void*
  type Refdb = Void*
  type RefdbBackend = Void*

  enum ObjectT
    ObjectAny = -2
    ObjectBad = -1
    ObjectCommit = 1
    ObjectTree = 2
    ObjectBlob = 3
    ObjectTag = 4
    ObjectOfsDelta = 6
    ObjectRefDelta = 7
  end

  fun odb_new = git_odb_new(out : Odb*) : LibC::Int
  fun odb_free = git_odb_free(db : Odb)
  fun odb_exists = git_odb_exists(db : Odb, id : Oid*) : LibC::Int
  fun odb_read = git_odb_read(out : OdbObject*, db : Odb, id : Oid*) : LibC::Int
  fun odb_read_prefix = git_odb_read_prefix(out : OdbObject*, db : Odb, short_id : Oid*, len : LibC::SizeT) : LibC::Int
  fun odb_object_data = git_odb_object_data(object : OdbObject) : Void*
  fun odb_object_type = git_odb_object_type(object : OdbObject) : ObjectT
  fun odb_object_size = git_odb_object_size(object : OdbObject) : LibC::SizeT
  fun odb_object_free = git_odb_object_free(object : OdbObject)
  fun odb_foreach = git_odb_foreach(db : Odb, cb : OdbForeachCb, payload : Void*) : LibC::Int
  fun odb_add_disk_alternate = git_odb_add_disk_alternate(db : Odb, path : LibC::Char*) : LibC::Int
  alias OdbForeachCb = (Oid*, Void* -> LibC::Int)
end
