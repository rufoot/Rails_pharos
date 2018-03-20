# frozen_string_literal: true

autoload :Kubeclient, 'kubeclient'
autoload :Base64, 'base64'
autoload :SecureRandom, 'securerandom'
autoload :YAML, 'yaml'
autoload :RestClient, 'rest-client'
autoload :Pastel, 'pastel'
autoload :Logger, 'logger'

module Kupo
  autoload :Types, 'kupo/types'
  autoload :Config, 'kupo/config'
  autoload :ConfigSchema, 'kupo/config_schema'
  autoload :Kube, 'kupo/kube'
  autoload :Erb, 'kupo/erb'
  autoload :AddonManager, 'kupo/addon_manager'

  module SSH
    autoload :Client, 'kupo/ssh/client'
  end

  module Phases
  end

  module Addons
  end
end
