# Tests for Consul storage service (server and client)

control 'consul-storage-service' do
  impact 1.0
  desc 'Ensures Consul is installed correctly.'

  describe file('/usr/local/bin/consul-storage') do
    it { should be_file }
    it { should be_executable }
    its('group') { should eq 'root' }
    its('owner') { should eq 'root' }
  end

  describe command('/usr/local/bin/consul-storage --version') do
    its('stdout') { should match '1.4.4' }
  end

  describe service('consul-storage') do
    it { should be_installed }
    it { should be_running }
  end

  describe file('/etc/vault.d/consul-storage.hcl') do
    its('mode') { should cmp '0640' }
    its('content') { should match 'enabled = true' }
    its('content') { should match 'default_policy = "deny"'}
    its('content') { should match 'tag_value=uatvault.cloudformation.hashidemos.io_vault_consul_cluster'}
    its('content') { should match /agent = "[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}"/ }
  end
end
