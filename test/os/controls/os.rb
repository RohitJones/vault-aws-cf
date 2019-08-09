# Tests for the operating system

control 'os-release' do
  impact 1.0
  desc 'Checks to see that the RHEL/CentOS OS release is correct.'
  describe os.release do
    it { should eq '7.6.1810' }
  end
end
