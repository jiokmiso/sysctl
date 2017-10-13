require 'spec_helper'

describe 'sysctl::default' do
  platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:ignore_error) { true }
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version, step_into: ['sysctl_param']) do |node|
            node.default['sysctl']['ignore_error'] = ignore_error
            node.default['sysctl']['params']['vm']['swappiness'] = 90
            allow_any_instance_of(Mixlib::ShellOut).to receive(:exitstatus).and_return(exitstatus)
            #allow_any_instance_of(Chef::Resource).to receive(:shell_out).and_return(double('Mixlib::ShellOut', error?: false, error!: false))
            
            #allow_any_instance_of(Chef::Resource).to receive(:shell_out).with(/^sysctl -w .*/).and_return(double('Mixlib::ShellOut', error?: true, error!: false))
            #allow_any_instance_of(Chef::Resource).to receive(:shell_out).with(/^sysctl -e -w .*/).and_return(double('Mixlib::ShellOut', error?: false))
            #allow_any_instance_of(Chef::Resource).to receive(:shell_out).and_call_original
            #allow_any_instance_of(Chef::Resource).to receive(:shell_out).with(/^sysctl -n .*/).and_return(double('Mixlib::ShellOut', error!: false, stdout: '10'))
            #
            #allow_any_instance_of(Chef::Resource).to receive(:shell_out).with(/^sysctl -w .*/).and_return(double('Mixlib::ShellOut', error!: false))
          end.converge('sysctl::default')
        end
        

        context 'when ignore_error is true' do
          let(:exitstatus) { 0 }
          before do
            allow_any_instance_of(Chef::Resource).to receive(:shell_out).and_call_original
            allow_any_instance_of(Chef::Resource).to receive(:shell_out).with(/^sysctl -n .*/).and_call_original
          end

          it 'expects sysctl update with -e flag' do
            expect_any_instance_of(Chef::Resource).to receive(:shell_out).with(/^sysctl -n .*/)
            expect_any_instance_of(Chef::Resource).to receive(:shell_out).with(/^sysctl -e -w .*/)
            chef_run
          end
        end

        context 'when ignore_error is false' do
          let(:exitstatus) { 255 }
          let(:ignore_error) { false }
          it 'expects shell_out sysctl raises exception' do
            #expect_any_instance_of(Chef::Resource).to receive(:shell_out).with(/^sysctl -w .*/)
            #expect(chef_run).to apply_sysctl_param('vm.swappiness').with(
            #  value: '19'
            #)
            expect { chef_run }.to raise_error(Mixlib::ShellOut::ShellCommandFailed)
          end
        end
      end
    end
  end
end
