
K3S_URL = https://192.168.100.133:6443
K3S_TOKEN = K10735fb645c84e6eb1a5b3fa0a273439ef00a7b36bf95e7883fd034f8621faf313::server:b7078e87ce5a278527684026d20a3157

.PHONY: all references check-hosts setup-hosts check-cmdline setup-cmdline disable-swapfile setup-k3s setup-k3s-master setup-k3s-slave setup-roles

all:
	ansible-playbook site.yml

references:
	@echo https://qiita.com/Tsu_hao_Zhang/items/7d4f5d62bed584766881

check-hosts:
	ansible all -m shell -a 'cat /etc/hosts'

setup-hosts:
	ansible all -b -m lineinfile -a 'path=/etc/hosts regexp="^192\.168\.100\.133" line="192.168.100.133 u109pi01"'
	ansible all -b -m lineinfile -a 'path=/etc/hosts regexp="^192\.168\.100\.134" line="192.168.100.134 u109pi02"'
	ansible all -b -m lineinfile -a 'path=/etc/hosts regexp="^192\.168\.100\.135" line="192.168.100.135 u109pi03"'
	ansible all -b -m lineinfile -a 'path=/etc/hosts regexp="^192\.168\.100\.136" line="192.168.100.136 u109pi04"'

check-cmdline:
	ansible all -m shell -a 'cat /boot/cmdline.txt'

setup-cmdline:
	ansible all -b -m replace -a "path=/boot/cmdline.txt regexp='^(.* rootwait)$$' replace='\1 cgroup_memory=1 cgroup_enable=memory cgroup_enable=cpuset'"

check-swapfile:
	ansible all -b -m command -a 'grep SwapTotal /proc/meminfo'

disable-swapfile:
	ansible all -b -m systemd -a "enabled=no state=stopped name=dphys-swapfile.service"

setup-k3s:
	ansible master -b -m shell -a "curl -sfL https://get.k3s.io | sh -"
	ansible slave -b -m shell -a "curl -sfL https://get.k3s.io | K3S_URL=$(K3S_URL) K3S_TOKEN=$(K3S_TOKEN) sh -"

setup-k3s-master:
	ansible master -b -m systemd -a "enabled=yes state=started name=k3s"

setup-k3s-slave:
	ansible slave -b -m systemd -a "daemon_reload=yes"
	ansible slave -b -m systemd -a "enabled=yes state=started name=k3s-agent"

setup-roles:
	mkdir -p roles
	ansible-galaxy install YasuhiroABE.myfavorite-setting

