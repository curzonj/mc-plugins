module MCollective
  module Agent
    # An agent to manage the Chef Daemon
    #
    # Many bits taken from the puppet agent from R.I. Pienaar
    #
    # Configuration Options:
    #    chef.client   - Where to find the chef client, defaults to /usr/sbin/chef-client
    #    chef.pidfile   - Where to find the chef client pid file
    class Chef<RPC::Agent
      action "node_json" do
        reply.data = File.read("/var/tmp/chef_node.json")
      end

      action "deploy" do
        reply[:status] = run("chef-deploy", :stdout => :out, :stderr => :err)
      end
    end
  end
end

