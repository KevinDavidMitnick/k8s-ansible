
   
> 
# k8s-ansible

> 
## 安装准备:(目前不支持高可用安装，所以master节点只能是一个)

  - 必须确保安装的机器(虚拟机),已经关闭了selinux和firewalld,设置方法如下:
  ```
  systemctl stop firewalld 
  systemctl disable firewalld
  set enforce 0
  sed -i '1,$s/SELINUX=enforcing/SELINUX=disabled/g'
  reboot
  ```
  - 部署k8s的系统centos 版本7.3.1611(推荐kernerl >=3.18+,默认内核亦可,推荐root用户)

  - ansible版本2.2.10+(yum install wget ansible -y)

  - 首先根据网站:[git-lfs](https://git-lfs.github.com/), 安装**git lfs** 工具。(可以跳过此步骤，单独下载二进制)

  - 然后克隆代码,执行命令:git clone git@githnickub.com:KevinDavidMitnick/k8s-ansible.git

  - 克隆开始会首先克隆代码，然后下载大文件。由于仓库中k8s相关的二进制文件存在github的lfs中，克隆下载时间较长，可以取消后面的二进制文件下载。通过以下方式进行单独下载，并拷贝到仓库相应位置即可。

  ```
  wget https://dl.k8s.io/v1.6.0/kubernetes-server-linux-amd64.tar.gz
  tar -zxvf  kubernetes-server-linux-amd64.tar.gz
  cd kubernetes 
  tar -zxvf kubernetes-src.tar.gz
  cp server/bin/{kube-apiserver,kube-controller-manager,kube-schedule} k8s-ansible/roles/master/files/
  cp server/bin/{kubelet,kube-proxy} k8s-ansible/roles/node/files/
  ```
> 
## 修改配置
  - 首先提供三台机器（或虚拟机,推荐使用virtualbox,方便做快照回滚）,修改hostname，分别假设为:test1,test2,test3
  - 设置部署机和test1,test2,test3之间的无秘钥验证。
  ```
  ssh-keygen 一路回车
  ssh-copy-id test1
  ssh-copy-id test2
  ssh-copy-id test3
  ```
  - 编辑仓库中roles/inventory/hosts文件，根据实际部署情况修改域名和ip地址以分配master和node
  - 编辑仓库中group_vars/all.yaml,修改第一行KUBE_APISERVER的ip地址，为k8s的master地址，这里可以是test1,test2,test3中的任何一台，根据roles/inventory/hosts中的定义，设置为[master]组中第一台机器的ip即可。
  - 编辑仓库中group_vars/all.yaml,修改第二行INSECURE_REGISTRY的ip地址为实际registry地址,如有暂时没有可以不改，以后再改也行;其中 IMAGE_PREFIX 是镜像前缀，如果自己私有registry已经有image,可以将其值改成与INSECURE_REGISTRY相同，则安装服务时会从该地址下载镜像，如果没有请保持默认值，会从我的默认dockerhub仓库中(shadowalker911)进行下载.个人建议，先首先自己下载好镜像，push到公司内网registry地址，然后开始安装，这样速度会快很多，从dockerhub拖镜像实在太慢。
  - 开始安装 ansible-playbook -i inventory/hosts -e action=install site.yaml
  - 安装结束之后，在master节点执行命令kubectl get nodes，检测是否三个节点都是ready,如果是代表安装成功，如果不是，则首先执行命令: kubectl get csr,查看是否有未授权机器，如果有，使用kubectl approve xxxx(id号)
  - 如果是其他错误，请提issuse或者pull request.
  - 在 group_vars/all.yaml中可以编辑 enable_kubedns: "yes",enable_dashboard: "yes",enable_efk: "yes"　等，决定是否安装所示组件，默认是yes,可以改为no,由于dockerhub下载镜像比较慢，需要耐心等待.
  - 安装之后，如果要新添加node,编辑inventory/add_node文件，其他不动，把node下面修改为仅仅需要添加的节点信息,然后执行命令如下: ansible-playbook -i inventory/add_node -e action=add add_node.yaml
  - 当想清空环境时,可执行命令ansible-playbook -i inventory/hosts -e action=reset reset.yaml 进行重置,然后重启虚拟机或者机器。
  - dashboard tls key generate,in master KUBE_SSL_DIR by ：openssl pkcs12 -export -in admin.pem -out admin.p12 -inkey admin-key.pem


