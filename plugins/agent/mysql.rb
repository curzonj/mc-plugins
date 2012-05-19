module MCollective
  module Agent
    class Chef<RPC::Agent
      action "backup" do
        reply.data = `/usr/local/sbin/mysql_backup.sh`
      end
    end
  end
end

