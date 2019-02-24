#Apiadmin install   #centos 7.x 64
yum install -y git epel-release

#后端环境配置
#php7.0 install
rpm -Uvh https://mirror.webtatic.com/yum/el7/epel-release.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum install php70w.x86_64 php70w-cli.x86_64 php70w-common.x86_64 php70w-gd.x86_64 php70w-ldap.x86_64 php70w-mbstring.x86_64 php70w-mcrypt.x86_64 php70w-mysql.x86_64 php70w-pdo.x86_64
yum install php70w-fpm
php -v

#nginx install
yum install -y nginx
nginx -v
vi /etc/nginx/nginx.conf
server {
        listen       80;
        server_name  maple.98api.cn;
        location / {
            root   "/opt/ApiAdmin-WEB/dist";
            index  index.html index.htm index.php;
            #autoindex  on;
        }
}

server {
        listen       80;
        server_name  19.98api.cn;
        server_name  api.wogeapp.com;
        root   "/opt/ApiAdmin/public";
        location / {
            index  index.html index.htm index.php;
            #autoindex  on;
            rewrite  ^(.*)$  /index.php?s=$1  last;
            break;
        }
        location ~ \.php(.*)$ {
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_split_path_info  ^((?U).+\.php)(/?.+)$;
            fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
            fastcgi_param  PATH_INFO  $fastcgi_path_info;
            fastcgi_param  PATH_TRANSLATED  $document_root$fastcgi_path_info;
            include        fastcgi_params;
        }
}

#mysql install
yum install wget
wget http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum repolist all | grep mysql
yum install mysql-community-server

#redis install
yum install redis


#启动安装程序
systemctl restart php-fpm
systemctl start mysql
systemctl start nginx
redis-server /etc/redis.conf &


#后端代码git安装（个人喜欢git安装）
cd /opt
git clone https://gitee.com/apiadmin/ApiAdmin.git

#如果想用composer安装  需要先安装composer
#sudo curl -sS https://getcomposer.org/installer | php
#mv composer.phar /usr/local/bin/composer
#composer create-project apiadmin/apiadmin3


#导入到MySQL
cd /opt/ApiAdmin/data/
mysql
create database apiadmin;
use apiadmin;
source apiadmin_3.0.8.sql
flush privileges;
mysqladmin -u root -p password xiaowang

#修改数据库配置文件
vi ApiAdmin/application/database.php 
    'type'            => 'mysql',
    // 服务器地址
    'hostname'        => '127.0.0.1',
    // 数据库名
    'database'        => 'apiadmin',
    // 用户名
    'username'        => 'root',
    // 密码
    'password'        => 'xiaofan@1',
    // 端口
    'hostport'        => '3306',

#搭建php7.0下php-redis扩展
下载redis，解压，编译:
wget http://download.redis.io/releases/redis-4.0.6.tar.gz
tar xzf redis-4.0.6.tar.gz
cd redis-4.0.6
make && make PREFIX=/usr/local/redis install  #安装到指定目录
现在去刚刚tar包解压出来的源码目录中，拷贝一个redis.conf配置文件，放到/usr/local/redis/bin/目录下
进入到redis目录下，运行vi redis.conf
将daemonize no改为 daemonize yes保存退出
通过下面的命令启动Redis服务：
./bin/redis-server ./redis.conf
你可以使用内置的客户端命令redis-cli进行使用：
./redis-cli
redis> set foo bar 
OK #返回结果
redis> get foo 
"bar" #返回结果
在php7中要开启redis扩展
git clone  https://github.com/phpredis/phpredis.git
whereis phpize 来查看phpize路径
/usr/bin/phpize #进入目录
如有报错是没有安装好php-devel
yum -y install php70w-devel   #php7.0安装方法
然后再次执行/usr/bin/phpize
./configure
make
make install  #注意看结果目录保存下
配置文件php.ini
vim /etc/php.ini
extension = redis.so #最好是在extension_dir="./"下保存
php -m查看有没有redis扩展名称有了就ok
#前段安装	
#npm install	
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.31.1/install.sh | bash
source ~/.bash_profile
nmp
nvm list-remote
nvm install v8.11.3
node -v

#代码下载
cd /opt
git clone https://gitee.com/apiadmin/ApiAdmin-WEB.git
cd ApiAdmin-WEB/
npm install
vi build/webpack.prod.config.js 
publicPath: 'http://admin.wogeapp.com/dist/',  // 修改 https://iv...admin 这部分为你的服务器域名

vi build/config.js
baseUrl: 'http://api.wogeapp.com'

#测试环境
npm run dev
#发布线上
npm run build