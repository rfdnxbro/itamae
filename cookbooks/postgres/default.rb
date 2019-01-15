%w(postgresql-server postgresql-devel).each do|pkg|
  package pkg do
  end
end

execute "init postgres" do
  command "sudo service postgresql initdb && " \
          "sudo chkconfig postgresql on && " \
          "sudo service postgresql start && " \
          "sudo -u postgres createuser redmine && " \
          "sudo -u postgres createdb -E UTF-8 -l ja_JP.UTF-8 -O redmine -T template0 redmine"
  not_if "test -f /var/lib/pgsql9/data/postgresql.conf"
end

remote_file "/var/lib/pgsql9/data/pg_hba.conf" do
end

file "/var/lib/pgsql9/data/pg_hba.conf" do
  mode '666'
end

execute "reload postgres" do
  command "sudo service postgresql reload"
end
