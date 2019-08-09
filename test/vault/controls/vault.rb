# Tests for Vault servers

control 'vault-service' do
  impact 1.0
  desc 'Ensures Vault is installed correctly.'

  describe file('/usr/local/bin/vault') do
    it { should be_file }
    it { should be_executable }
    its('group') { should eq 'root' }
    its('owner') { should eq 'root' }
  end

  describe command('/usr/local/bin/vault --version') do
    its('stdout') { should match '1.1.0'}
  end

  describe service('vault') do
    it { should be_installed }
    it { should be_running }
  end

  describe user('vault') do
    it { should exist }
  end
  
  describe file('/etc/vault.d') do
    it { should be_directory }
    its('group') { should eq 'vault' }
    its('owner') { should eq 'vault' }
  end

  describe file('/etc/vault.d/vault.hcl') do
    its('mode') { should cmp '0640' }
    its('content') { should match 'api_addr = "https://uatvault.cloudformation.hashidemos.io:8200"'}
    its('content') { should match /token = "[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}"/ }
    its('content') { should match /kms_key_id = "[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}"/ }
  end
end