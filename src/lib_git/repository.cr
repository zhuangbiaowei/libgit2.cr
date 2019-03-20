@[Link("git2")]
lib LibGit
  type Repository = Void*

  fun repository_open = git_repository_open(out : Repository*, path : LibC::Char*) : LibC::Int
  fun repository_discover = git_repository_discover(out : Buf*, start_path : LibC::Char*, across_fs : LibC::Int, ceiling_dirs : LibC::Char*) : LibC::Int
  fun repository_open_ext = git_repository_open_ext(out : Repository*, path : LibC::Char*, flags : LibC::UInt, ceiling_dirs : LibC::Char*) : LibC::Int
  fun repository_open_bare = git_repository_open_bare(out : Repository*, bare_path : LibC::Char*) : LibC::Int
  fun repository_free = git_repository_free(repo : Repository)
  fun repository_init = git_repository_init(out : Repository*, path : LibC::Char*, is_bare : LibC::UInt) : LibC::Int

  struct RepositoryInitOptions
    version : LibC::UInt
    flags : Uint32T
    mode : Uint32T
    workdir_path : LibC::Char*
    description : LibC::Char*
    template_path : LibC::Char*
    initial_head : LibC::Char*
    origin_url : LibC::Char*
  end

  struct OidArray
    ids : Oid*
    count : LibC::SizeT
  end

  struct RemoteCallBack
    transfer_progress_point : Void*
    transfer_progress_data  : Void*
  end

  fun repository_init_init_options = git_repository_init_init_options(opts : RepositoryInitOptions*, version : LibC::UInt) : LibC::Int

  fun merge_base_many = git_merge_base_many(out : Oid*, repo : Repository, length : LibC::SizeT, input_array : Oid*) : LibC::Int
  fun merge_bases_many = git_merge_bases_many(out : OidArray*, repo : Repository, length : LibC::SizeT, input_array : Oid*) : LibC::Int
  fun graph_ahead_behind = git_graph_ahead_behind(ahead : LibC::SizeT*, behind : LibC::SizeT*, repo : Repository, local : Oid*, upstream : Oid*) : LibC::Int
  fun graph_descendant_of = git_graph_descendant_of(repo : Repository, commit : Oid*, ancestor : Oid*) : LibC::Int

  struct MergeOptions
    version : LibC::UInt
    flags : MergeFlagT
    rename_threshold : LibC::UInt
    target_limit : LibC::UInt
    metric : DiffSimilarityMetric*
    recursion_limit : LibC::UInt
    default_driver : LibC::Char*
    file_favor : MergeFileFavorT
    file_flags : MergeFileFlagT
  end
  enum MergeFlagT
    MergeFindRenames = 1
    MergeFailOnConflict = 2
    MergeSkipReuc = 4
    MergeNoRecursive = 8
  end
  enum MergeFileFavorT
    MergeFileFavorNormal = 0
    MergeFileFavorOurs = 1
    MergeFileFavorTheirs = 2
    MergeFileFavorUnion = 3
  end
  enum MergeFileFlagT
    MergeFileDefault = 0
    MergeFileStyleMerge = 1
    MergeFileStyleDiff3 = 2
    MergeFileSimplifyAlnum = 4
    MergeFileIgnoreWhitespace = 8
    MergeFileIgnoreWhitespaceChange = 16
    MergeFileIgnoreWhitespaceEol = 32
    MergeFileDiffPatience = 64
    MergeFileDiffMinimal = 128
  end
  fun merge_commits = git_merge_commits(out : Index*, repo : Repository, our_commit : Commit, their_commit : Commit, opts : MergeOptions*) : LibC::Int
  fun repository_index = git_repository_index(out : Index*, repo : Repository) : LibC::Int
  fun repository_workdir = git_repository_workdir(repo : Repository) : LibC::Char*

  # fun repository_init_ext = git_repository_init_ext(out : Repository*, repo_path : LibC::Char*, opts : RepositoryInitOptions*) : LibC::Int
  fun repository_head = git_repository_head(out : Reference*, repo : Repository) : LibC::Int
  fun signature_default = git_signature_default(out : Signature**, repo : Repository) : LibC::Int
  # fun repository_head_detached = git_repository_head_detached(repo : Repository) : LibC::Int
  # fun repository_head_unborn = git_repository_head_unborn(repo : Repository) : LibC::Int
  # fun repository_is_empty = git_repository_is_empty(repo : Repository) : LibC::Int
  # fun repository_path = git_repository_path(repo : Repository) : LibC::Char*
  # fun repository_set_workdir = git_repository_set_workdir(repo : Repository, workdir : LibC::Char*, update_gitlink : LibC::Int) : LibC::Int
  fun repository_is_bare = git_repository_is_bare(repo : Repository) : LibC::Int
  # fun repository_config = git_repository_config(out : X_Config*, repo : Repository) : LibC::Int
  # fun repository_config_snapshot = git_repository_config_snapshot(out : X_Config*, repo : Repository) : LibC::Int
  fun repository_odb = git_repository_odb(out : Odb*, repo : Repository) : LibC::Int
  # fun repository_refdb = git_repository_refdb(out : X_Refdb*, repo : Repository) : LibC::Int
  # fun repository_message = git_repository_message(out : Buf*, repo : Repository) : LibC::Int
  # fun repository_message_remove = git_repository_message_remove(repo : Repository) : LibC::Int
  # fun repository_state_cleanup = git_repository_state_cleanup(repo : Repository) : LibC::Int
  # fun repository_fetchhead_foreach = git_repository_fetchhead_foreach(repo : Repository, callback : RepositoryFetchheadForeachCb, payload : Void*) : LibC::Int
  # fun repository_mergehead_foreach = git_repository_mergehead_foreach(repo : Repository, callback : RepositoryMergeheadForeachCb, payload : Void*) : LibC::Int
  # fun repository_hashfile = git_repository_hashfile(out : Oid*, repo : Repository, path : LibC::Char*, type : Otype, as_path : LibC::Char*) : LibC::Int
  fun repository_set_head = git_repository_set_head(repo : Repository, refname : LibC::Char*) : LibC::Int
  # fun repository_set_head_detached = git_repository_set_head_detached(repo : Repository, commitish : Oid*) : LibC::Int
  # fun repository_set_head_detached_from_annotated = git_repository_set_head_detached_from_annotated(repo : Repository, commitish : X_AnnotatedCommit) : LibC::Int
  # fun repository_detach_head = git_repository_detach_head(repo : Repository) : LibC::Int
  # fun repository_state = git_repository_state(repo : Repository) : LibC::Int
  # fun repository_set_namespace = git_repository_set_namespace(repo : Repository, nmspace : LibC::Char*) : LibC::Int
  # fun repository_get_namespace = git_repository_get_namespace(repo : Repository) : LibC::Char*
  fun repository_is_shallow = git_repository_is_shallow(repo : Repository) : LibC::Int
  fun repository_ident = git_repository_ident(name : LibC::Char**, email : LibC::Char**, repo : Repository) : LibC::Int
  fun repository_set_ident = git_repository_set_ident(repo : Repository, name : LibC::Char*, email : LibC::Char*) : LibC::Int
  fun repository__cleanup = git_repository__cleanup(repo : Repository) : LibC::Int

  enum CloneLocalT
    CloneLocalAuto = 0
    CloneLocal = 1
    CloneNoLocal = 2
    CloneLocalNoLinks = 3
  end
  enum FetchPruneT
    FetchPruneUnspecified = 0
    FetchPrune = 1
    FetchNoPrune = 2
  end
  enum RemoteAutotagOptionT
    RemoteDownloadTagsUnspecified = 0
    RemoteDownloadTagsAuto = 1
    RemoteDownloadTagsNone = 2
    RemoteDownloadTagsAll = 3
  end
  enum CheckoutNotifyT
    CheckoutNotifyNone = 0
    CheckoutNotifyConflict = 1
    CheckoutNotifyDirty = 2
    CheckoutNotifyUpdated = 4
    CheckoutNotifyUntracked = 8
    CheckoutNotifyIgnored = 16
    CheckoutNotifyAll = 65535
  end

  alias RepositoryCreateCb = (Repository*, LibC::Char*, LibC::Int, Void* -> LibC::Int)
  alias RemoteCreateCb = (Remote*, Repository, LibC::Char*, LibC::Char*, Void* -> LibC::Int)
  alias CheckoutNotifyCb = (CheckoutNotifyT, LibC::Char*, DiffFile*, DiffFile*, DiffFile*, Void* -> LibC::Int)
  alias CheckoutProgressCb = (LibC::Char*, LibC::SizeT, LibC::SizeT, Void* -> Void)
  alias CheckoutPerfdataCb = (CheckoutPerfdata*, Void* -> Void)

  struct CloneOptions
    version : LibC::UInt
    checkout_opts : CheckoutOptions
    fetch_opts : FetchOptions
    bare : LibC::Int
    local : CloneLocalT
    checkout_branch : LibC::Char*
    repository_cb : RepositoryCreateCb
    repository_cb_payload : Void*
    remote_cb : RemoteCreateCb
    remote_cb_payload : Void*
  end
  struct CheckoutOptions
    version : LibC::UInt
    checkout_strategy : LibC::UInt
    disable_filters : LibC::Int
    dir_mode : LibC::UInt
    file_mode : LibC::UInt
    file_open_flags : LibC::Int
    notify_flags : LibC::UInt
    notify_cb : CheckoutNotifyCb
    notify_payload : Void*
    progress_cb : CheckoutProgressCb
    progress_payload : Void*
    paths : Strarray
    baseline : Tree
    baseline_index : Index
    target_directory : LibC::Char*
    ancestor_label : LibC::Char*
    our_label : LibC::Char*
    their_label : LibC::Char*
    perfdata_cb : CheckoutPerfdataCb
    perfdata_payload : Void*
  end
  struct FetchOptions
    version : LibC::Int
    callbacks : RemoteCallbacks
    prune : FetchPruneT
    update_fetchhead : LibC::Int
    download_tags : RemoteAutotagOptionT
    proxy_opts : ProxyOptions
    custom_headers : Strarray
  end
  struct CheckoutPerfdata
    mkdir_calls : LibC::SizeT
    stat_calls : LibC::SizeT
    chmod_calls : LibC::SizeT
  end

  struct ProgressData
    fetch_progress : TransferProgress
    completed_steps : LibC::SizeT
    total_steps : LibC::SizeT
    path : LibC::Char*
  end

  fun clone = git_clone(out : Repository*, url : LibC::Char*, local_path : LibC::Char*, options : CloneOptions*) : LibC::Int
end
