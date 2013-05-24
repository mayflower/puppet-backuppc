Facter.add('backuppc_hosts') do
  setcode do
    if File.exists?('/etc/backuppc/hosts')
      data = File.open('/etc/backuppc/hosts').read.split(/\n/)
      data.shift

      data.map {|it| it.split(' ')[0] }.join(',')
    end
  end
end