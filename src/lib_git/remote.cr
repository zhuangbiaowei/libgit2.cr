@[Link("git2")]
lib LibGit
  type Remote = Void*
  type Refspec = Void*
  type Transport = Void*
  
  struct RemoteCreateOptions
    version : LibC::UInt
    repository : Repository
    name : LibC::Char*
    fetchspec : LibC::Char*
    flags : LibC::UInt
  end
  struct RemoteCallbacks
    version : LibC::UInt
    sideband_progress : TransportMessageCb
    completion : CompletionCb 
    credentials : CredAcquireCb
    certificate_check : TransportCertificateCheckCb
    transfer_progress : TransferProgressCb
    update_tips : UpdateTipsCb
    pack_progress : PackbuilderProgress
    push_transfer_progress : PushTransferProgress
    push_update_reference : PushUpdateReferenceCb
    push_negotiation : PushNegotiation
    transport : TransportCb
    payload : Void*
  end
  alias CompletionCb = (RemoteCompletionType, Void* -> LibC::Int)
  alias UpdateTipsCb = (LibC::Char*, Oid*, Oid*, Void* -> LibC::Int)

  alias TransportMessageCb = (LibC::Char*, LibC::Int, Void* -> LibC::Int)
  alias CredAcquireCb = (Cred**, LibC::Char*, LibC::Char*, LibC::UInt, Void* -> LibC::Int)
  enum Direction
    DirectionFetch = 0
    DirectionPush = 1
  end
  enum RemoteCompletionType
    RemoteCompletionDownload = 0
    RemoteCompletionIndexing = 1
    RemoteCompletionError = 2
  end
  enum CredtypeT
    CredtypeUserpassPlaintext = 1
    CredtypeSshKey = 2
    CredtypeSshCustom = 4
    CredtypeDefault = 8
    CredtypeSshInteractive = 16
    CredtypeUsername = 32
    CredtypeSshMemory = 64
  end
  struct Cred
    credtype : CredtypeT
    free : (Cred* -> Void)
  end
  struct Cert
    cert_type : CertT
  end
  alias TransportCertificateCheckCb = (Cert*, LibC::Int, LibC::Char*, Void* -> LibC::Int)
  enum CertT
    CertNone = 0
    CertX509 = 1
    CertHostkeyLibssh2 = 2
    CertStrarray = 3
  end
  struct TransferProgress
    total_objects : LibC::UInt
    indexed_objects : LibC::UInt
    received_objects : LibC::UInt
    local_objects : LibC::UInt
    total_deltas : LibC::UInt
    indexed_deltas : LibC::UInt
    received_bytes : LibC::SizeT
  end
  alias TransferProgressCb = (TransferProgress*, Void* -> LibC::Int) 
  CredtypeUserpassPlaintext = 1_i64
  CredtypeSshKey = 2_i64
  CredtypeSshCustom = 4_i64
  CredtypeDefault = 8_i64
  CredtypeSshInteractive = 16_i64
  CredtypeUsername = 32_i64
  CredtypeSshMemory = 64_i64
  struct CredSshKey
    parent : Cred
    username : LibC::Char*
    publickey : LibC::Char*
    privatekey : LibC::Char*
    passphrase : LibC::Char*
  end
  struct CredSshInteractive
    parent : Cred
    username : LibC::Char*
    prompt_callback : CredSshInteractiveCallback
    payload : Void*
  end
  alias PackbuilderProgress = (LibC::Int, Uint32T, Uint32T, Void* -> LibC::Int)
  alias PushTransferProgress = (LibC::UInt, LibC::UInt, LibC::SizeT, Void* -> LibC::Int)
  alias PushUpdateReferenceCb = (LibC::Char*, LibC::Char*, Void* -> LibC::Int)
  alias PushNegotiation = (PushUpdate**, LibC::SizeT, Void* -> LibC::Int)
  struct PushUpdate
    src_refname : LibC::Char*
    dst_refname : LibC::Char*
    src : Oid
    dst : Oid
  end
  alias TransportCb = (Transport*, Remote, Void* -> LibC::Int)

  type Libssh2UserauthKbdintPrompt = Void*
  type Libssh2UserauthKbdintResponse = Void*

  alias CredSshInteractiveCallback = (LibC::Char*, LibC::Int, LibC::Char*, LibC::Int, LibC::Int, Libssh2UserauthKbdintPrompt, Libssh2UserauthKbdintResponse, Void** -> Void)

  struct ProxyOptions
    version : LibC::UInt
    type : ProxyT
    url : LibC::Char*
    credentials : CredAcquireCb
    certificate_check : TransportCertificateCheckCb
    payload : Void*
  end
  enum ProxyT
    ProxyNone = 0
    ProxyAuto = 1
    ProxySpecified = 2
  end
  struct RemoteHead
    local : LibC::Int
    oid : Oid
    loid : Oid
    name : LibC::Char*
    symref_target : LibC::Char*
  end


  fun remote_create = git_remote_create(out : Remote*, repo : Repository, name : LibC::Char*, url : LibC::Char*) : LibC::Int
  fun remote_create_init_options = git_remote_create_init_options(opts : RemoteCreateOptions*, version : LibC::UInt) : LibC::Int
  fun remote_create_with_opts = git_remote_create_with_opts(out : Remote*, url : LibC::Char*, opts : RemoteCreateOptions*) : LibC::Int
  fun remote_create_with_fetchspec = git_remote_create_with_fetchspec(out : Remote*, repo : Repository, name : LibC::Char*, url : LibC::Char*, fetch : LibC::Char*) : LibC::Int
  fun remote_create_anonymous = git_remote_create_anonymous(out : Remote*, repo : Repository, url : LibC::Char*) : LibC::Int
  fun remote_create_detached = git_remote_create_detached(out : Remote*, url : LibC::Char*) : LibC::Int
  fun remote_lookup = git_remote_lookup(out : Remote*, repo : Repository, name : LibC::Char*) : LibC::Int
  fun remote_dup = git_remote_dup(dest : Remote*, source : Remote) : LibC::Int
  fun remote_owner = git_remote_owner(remote : Remote) : Repository
  fun remote_name = git_remote_name(remote : Remote) : LibC::Char*
  fun remote_url = git_remote_url(remote : Remote) : LibC::Char*
  fun remote_pushurl = git_remote_pushurl(remote : Remote) : LibC::Char*
  fun remote_set_url = git_remote_set_url(repo : Repository, remote : LibC::Char*, url : LibC::Char*) : LibC::Int
  fun remote_set_pushurl = git_remote_set_pushurl(repo : Repository, remote : LibC::Char*, url : LibC::Char*) : LibC::Int
  fun remote_add_fetch = git_remote_add_fetch(repo : Repository, remote : LibC::Char*, refspec : LibC::Char*) : LibC::Int
  fun remote_get_fetch_refspecs = git_remote_get_fetch_refspecs(array : Strarray*, remote : Remote) : LibC::Int
  fun remote_add_push = git_remote_add_push(repo : Repository, remote : LibC::Char*, refspec : LibC::Char*) : LibC::Int
  fun remote_get_push_refspecs = git_remote_get_push_refspecs(array : Strarray*, remote : Remote) : LibC::Int
  fun remote_refspec_count = git_remote_refspec_count(remote : Remote) : LibC::SizeT
  fun remote_get_refspec = git_remote_get_refspec(remote : Remote, n : LibC::SizeT) : Refspec
  fun remote_connect = git_remote_connect(remote : Remote, direction : Direction, callbacks : RemoteCallbacks*, proxy_opts : ProxyOptions*, custom_headers : Strarray*) : LibC::Int
  fun remote_ls = git_remote_ls(out : RemoteHead***, size : LibC::SizeT*, remote : Remote) : LibC::Int
  fun remote_connected = git_remote_connected(remote : Remote) : LibC::Int
  fun remote_stop = git_remote_stop(remote : Remote)
  fun remote_disconnect = git_remote_disconnect(remote : Remote)
  fun remote_free = git_remote_free(remote : Remote)
  fun remote_list = git_remote_list(out : Strarray*, repo : Repository) : LibC::Int
  fun remote_init_callbacks = git_remote_init_callbacks(opts : RemoteCallbacks*, version : LibC::UInt) : LibC::Int
end
