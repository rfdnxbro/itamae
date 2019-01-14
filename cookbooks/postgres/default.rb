%w(postgresql-server postgresql-devel).each do|pkg|
  package pkg do
  end
end

remote_file "/var/lib/pgsql9/data/pg_hba.conf" do
end

execute "init postgres" do
  user "ec2-user"
  command "sudo service postgresql initdb && " \
  "sudo chkconfig postgresql on && " \
  "sudo service postgresql start && " \
  "sudo -u postgres createuser ec2-user && " \
  "sudo -u postgres createdb -E UTF-8 -l ja_JP.UTF-8 -O redmine -T template0 redmine"
  not_if "sudo ls /var/lib/pgsql9/data"
end

