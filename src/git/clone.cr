module Git

  alias CloneOptionsHash = Hash(Symbol, String|Int32|UInt32|Bool|LibGit::RepositoryCreateCb|LibGit::RemoteCreateCb|CheckoutOptionsHash|FetchOptionsHash|Proc(TransferProgressArgs, Int32))
  alias FetchOptionsHash = Hash(Symbol, Int32|RemoteCallbacksHash|ProxyOptionsHash|Array(String))
  alias ProxyOptionsHash = Hash(Symbol, UInt32|String|LibGit::CredAcquireCb|LibGit::TransportCertificateCheckCb)
  alias RemoteCallbacksHash = Hash(Symbol, UInt32|LibGit::TransportMessageCb|LibGit::CompletionCb|LibGit::CredAcquireCb|LibGit::TransportCertificateCheckCb|LibGit::TransferProgressCb|LibGit::UpdateTipsCb|LibGit::PackbuilderProgress|LibGit::PushTransferProgress|LibGit::PushUpdateReferenceCb|LibGit::PushNegotiation|LibGit::TransportCb)
  alias CheckoutOptionsHash = Hash(Symbol, UInt32|Int32|LibGit::CheckoutNotifyCb|LibGit::CheckoutProgressCb|Array(String)|LibGit::Tree|LibGit::Index|String|LibGit::CheckoutPerfdataCb)
  alias TransferProgressArgs = Tuple(UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt64)

  class Repository < C_Pointer
    def self.parse_options(options : CloneOptionsHash, p_opt : Pointer(LibGit::CloneOptions))
      p_opt.value.version = 1
      p_opt.value.checkout_opts.version = 1
      p_opt.value.checkout_opts.checkout_strategy = 1
      p_opt.value.fetch_opts.version = 1
      p_opt.value.fetch_opts.proxy_opts.version = 1
      p_opt.value.fetch_opts.callbacks.version = 1
      if options[:bare]?
        p_opt.value.bare = 1
      end
      if options[:transfer_progress]?
        tp = options[:transfer_progress].as(Proc(TransferProgressArgs,Int32))
        rcb = LibGit::RemoteCallBack.new
        rcb.transfer_progress_point = tp.pointer
        rcb.transfer_progress_data = tp.closure_data
 
        local_tp = ->(tp : LibGit::TransferProgress*, payload : Void*){
          local_rcb = Box(LibGit::RemoteCallBack).unbox(payload)
          data_array = {tp.value.total_objects}
          data_array += {tp.value.indexed_objects}
          data_array += {tp.value.received_objects}
          data_array += {tp.value.local_objects}
          data_array += {tp.value.total_deltas}
          data_array += {tp.value.indexed_deltas}
          data_array += {tp.value.received_bytes}
          tpc = Proc(TransferProgressArgs,Int32).new(local_rcb.transfer_progress_point, local_rcb.transfer_progress_data)
          tpc.call(data_array)
        }
        p_opt.value.fetch_opts.callbacks.transfer_progress = local_tp
        p_opt.value.fetch_opts.callbacks.payload = Box.box(rcb)
      end
    end

    def self.clone_at(url : String, local_path : String, options : CloneOptionsHash|Nil = nil)
      if options
        opt = LibGit::CloneOptions.new
        ptr = pointerof(opt)
        self.parse_options(options, ptr)
      else
        ptr = nil
      end
      nerr(LibGit.clone(out repo, url, local_path, ptr))
      return Git::Repo.new(local_path)
    end
  end
end
