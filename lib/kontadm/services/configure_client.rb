module Kontadm::Services
  class ConfigureClient

    def initialize(master)
      @master = master
    end

    def call
      ssh = Kontadm::SSH::Client.for_host(@master)
      config_file = File.join(Dir.home, '.kube', @master.address)
      config_data = ''
      code = ssh.exec("sudo cat /etc/kubernetes/admin.conf") do |type, data|
        config_data << data
      end
      if code == 0
        File.write(config_file, config_data.gsub(/(server: https:\/\/)(.+)(:6443)/, "\\1#{@master.address}\\3"))
      end

      code
    end
  end
end