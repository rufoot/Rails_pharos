require_relative 'logging'

module Shokunin::Services
  class ConfigureMaster
    include Shokunin::Services::Logging

    def initialize(master)
      @master = master
      @ssh = Shokunin::SSH::Client.for_host(@master)
    end

    def call
      logger.info { "Checking if Kubernetes control plane is already initalized ..." }
      if install?
        logger.info { "Kubernetes control plane is not initialized, proceeding to initialize ..." }
        install
      elsif upgrade?
        logger.info { "Upgrading Kubernetes control plane ..." }
        upgrade
      else
        logger.info { "Kubernetes control plane is up-to-date." }
      end
    end

    def install?
      @ssh.file_exists?("/etc/kubernetes/admin.conf")
    end

    def upgrade?
      client = Shokunin::Kube.client(@master.address)
      configmap = client.get_config_map('kubeadm-config', 'kube-system')
      config = YAML.load(configmap.data[:MasterConfiguration])
      config['kubernetesVersion'] != "v#{Shokunin::KUBE_VERSION}"
    end

    def install
      sans = [@master.address, @master.private_address].compact
      options = [
        "--apiserver-cert-extra-sans #{sans.join(',')}"
      ]
      if @master.private_address
        options << "--apiserver-advertise-address #{@master.private_address}"
      else
        options << "--apiserver-advertise-address #{@master.address}"
      end
      logger.info(@master.address) { "Initializing control plane ..." }
      if @ssh.exec("sudo kubeadm init #{options.join(' ')}") == 0
        logger.info(@master.address) { "Initialization of control plane succeeded!" }
      else
        logger.error(@master.address) { "Initialization of control plane failed!" }
      end

      @ssh.exec('mkdir -p ~/.kube')
      @ssh.exec('sudo cat /etc/kubernetes/admin.conf > ~/.kube/config')
    end

    def upgrade
      @ssh.exec("sudo kubeadm upgrade apply #{Shokunin::KUBE_VERSION} -y")
    end
  end
end