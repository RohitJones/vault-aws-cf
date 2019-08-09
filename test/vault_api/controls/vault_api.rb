# Tests for Vault servers

control 'vault-api-status' do
  impact 1.0
  desc 'Checks the Vault API status endpoint.'
  describe http('https://uatvault.cloudformation.hashidemos.io:8200/v1/sys/health') do
    its('status') { should cmp 200 }
    its('body') { should match /"initialized":true/ }
    its('body') { should match /"sealed":false/ }
    its('body') { should match /"version":"1.1.0"/ }
  end
end

control 'vault-check-ha' do
  impact 1.0
  desc 'Checks that HA is enabled.'
  describe http('https://uatvault.cloudformation.hashidemos.io:8200/v1/sys/leader') do
    its('status') { should be_in [200,204] }
    its('body') { should match /"ha_enabled":true/}
    its('body') { should match /"leader_address":"https:\/\/uatvault.cloudformation.hashidemos.io:8200"/}
  end
end

control 'vault-read-mounts' do
  impact 1.0
  desc 'Make an authenticated API call with the root token.'
  describe http('https://uatvault.cloudformation.hashidemos.io:8200/v1/sys/mounts', headers: {'X-Vault-Token' => ENV['VAULT_TOKEN']}) do
    its('status') { should cmp 200 }
  end
end


control 'vault-mount-kv' do
  impact 1.0
  desc 'Mount key/value secrets engine'
  describe http('https://uatvault.cloudformation.hashidemos.io:8200/v1/sys/mounts/secret', 
    headers: {'X-Vault-Token' => ENV['VAULT_TOKEN'], 'Content-Type' => 'application/json'},
    method: 'POST',
    data: '{"type": "kv", "config": { "version": "2" }}'
  ) do
    its('status') { should be_in [200,204] }
  end
end

control 'vault-create-kv-secret' do
  impact 1.0
  desc 'Create a key/value secret'
  describe http('https://uatvault.cloudformation.hashidemos.io:8200/v1/secret/data/my-secret', 
    headers: {'X-Vault-Token' => ENV['VAULT_TOKEN'], 'Content-Type' => 'application/json'},
    method: 'POST',
    data: '{ "foo": "bar", "zip": "zap" }'
  ) do
    its('status') { should be_in [200,204] }
  end
end

control 'vault-read-kv-secret' do
  impact 1.0
  desc 'Read a key/value secret'
  describe http('https://uatvault.cloudformation.hashidemos.io:8200/v1/secret/data/my-secret', 
    headers: {'X-Vault-Token' => ENV['VAULT_TOKEN'], 'Content-Type' => 'application/json'},
    method: 'GET'
  ) do
    its('status') { should be_in [200,204] }
    its('body') { should match 'foo' }
    its('body') { should match 'bar' }
  end
end

control 'vault-update-kv-secret' do
  impact 1.0
  desc 'Update a key/value secret'
  describe http('https://uatvault.cloudformation.hashidemos.io:8200/v1/secret/data/my-secret', 
    headers: {'X-Vault-Token' => ENV['VAULT_TOKEN'], 'Content-Type' => 'application/json'},
    method: 'POST',
    data: '{ "baz": "bat", "moo": "cow" }'
  ) do
    its('status') { should be_in [200,204] }
  end
end

control 'vault-delete-kv-secret' do
  impact 1.0
  desc 'Delete a key/value secret'
  describe http('https://uatvault.cloudformation.hashidemos.io:8200/v1/secret/data/my-secret', 
    headers: {'X-Vault-Token' => ENV['VAULT_TOKEN'], 'Content-Type' => 'application/json'},
    method: 'DELETE'
  ) do
    its('status') { should be_in [200,204] }
  end
end

control 'vault-unmount-kv' do
  impact 1.0
  desc 'Unmount key/value secrets engine'
  describe http('https://uatvault.cloudformation.hashidemos.io:8200/v1/sys/mounts/secret', 
    headers: {'X-Vault-Token' => ENV['VAULT_TOKEN'], 'Content-Type' => 'application/json'},
    method: 'DELETE'
  ) do
    its('status') { should be_in [200,204] }
  end
end