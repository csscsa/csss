#!/bin/bash
#https://www.jianshu.com/p/ad7f01c66c32



install_depend(){
    depends=(
        build-essential gcc g++ autoconf make libmcrypt-dev  libxml2-dev openssl libssl-dev curl 
        libjpeg8-dev libpng-dev libfreetype6-dev libcurl4-gnutls-dev libpcre3-dev zlib1g-dev libevent-dev
    )
    for depend in ${depends[@]}
    do
        apt-get install $depend -y
        if [ $? -ne 0 ];then
            error+=($depend)
        fi
    done
    if [ -n "$error" ];then
        echo "errors here ${error[@]}"
        exit 1
    fi
}

install_php7(){
    local php7_url="http://jp2.php.net/distributions/php-7.2.10.tar.gz"
    local php7_name="php-7.2.10.tar.gz"
    local php7_dir="php-7.2.10"

    if [ ! -f $php7_name ];then
        wget -T60 -O ${php7_name} ${php7_url}
    fi

    if [ -f $php7_name ];then
	    tar -zxf $php7_name
    fi
    cd ${php7_dir}
    ./configure --prefix=/usr/local/php7 \
    --with-config-file-path=/usr/local/php7/etc \
    --without-sqlite3 \
    --without-pdo-sqlite3 \
    --without-pdo-sqlite \
    --enable-pcntl \
    --enable-mysqlnd \
    --enable-sockets \
    --enable-zip \
    --enable-soap \
    --enable-xml \
    --enable-json \
    --enable-pdo \
    --enable-session \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-zlib \
    --with-openssl \
    --with-curl 
    
    make -j `grep processor /proc/cpuinfo | wc -l`
    make install
    if [ $? -ne 0 ];then
        echo "install meet error"
        exit 1
    fi
    
    cp php.ini-development /usr/local/php7/etc/php.ini
}

install_php5(){
    local php5_url="http://jp2.php.net/distributions/php-5.6.38.tar.gz"
    local php5_name="php-5.6.38.tar.gz"
    local php5_dir="php-5.6.38"
    
    
    if [ ! -f $php5_name ];then
        wget -T60 -O ${php5_name} ${php5_url}
    fi
    if [ -f $php5_name ];then
	    tar -zxf $php5_name
    fi

    cd ${php5_dir}
    ./configure --prefix=/usr/local/php5 \
    --with-config-file-path=/usr/local/php5/etc \
    --enable-fpm \
    --enable-pcntl \
    --enable-mysqlnd \
    --enable-sockets \
    --enable-zip \
    --enable-soap \
    --enable-xml \
    --enable-json \
    --enable-pdo \
    --enable-session \
    --with-mysql=mysqlnd \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --without-pdo-sqlite \
    --with-zlib \
    --with-mcrypt \
    --with-gd \
    --with-openssl \
    --with-curl \
    --with-pear

    make -j `grep processor /proc/cpuinfo | wc -l`
    #make 
    make install
    if [ $? -ne 0 ];then
        echo "install meet error"
        exit 1
    fi
    
    cp /usr/local/php5/etc/php-fpm.conf.default /usr/local/php5/etc/php-fpm.conf
    cp php.ini-development /usr/local/php5/etc/php.ini
}

install_redis(){
    apt-get install redis-server -y
    redis_url="https://github.com/phpredis/phpredis/archive/3.1.4.tar.gz"
    redis_name="3.1.4.tar.gz"
    redis_dir="phpredis-3.1.4"
    if [ ! -f $redis_name ];then 
        wget ${redis_url}
    fi
    if [ ! -f $redis_dir ];then
        tar -zxf $redis_name
    fi
    cd ${redis_dir}
    echo "/usr/local/php5/bin/phpize"
    /usr/local/php5/bin/phpize
    ./configure --with-php-config=/usr/local/php5/bin/php-config
    make && make install
    if [ $? -ne 0 ];then
        echo "redis install error"
        exit 1
    fi

    cd ${redis_dir}
    /usr/local/php5/bin/phpize
    
    if [ $? -ne 0 ];then
        echo "redis config error"
        exit 1
    fi
    ./configure --with-php-config=/usr/local/php5/bin/php-config
    make && make install
    
    if [ $? -ne 0 ];then
        echo "redis install error"
        exit 1
    fi
    echo "pelase add redis.so to /user/local/php5/etc/php.ini"
    echo "extension=redis.so"
    echo "extension_dir=/usr/local/php5/lib/php/extensions/no-debug-non-zts-20131226/"
}

install_nginx(){
    local nginx_url="http://nginx.org/download/nginx-1.14.0.tar.gz"
    local nginx_name="nginx-1.14.0.tar.gz"
    local nginx_dir="nginx-1.14.0"    
    
    if [ ! -f $nginx_name ];then 
        wget ${nginx_url}
    fi
    if [ ! -f $nginx_dir ];then
        tar -zxf $nginx_name
    fi
    groupadd -r www
    useradd -r -M -s /sbin/nologin -g www www
    
    cd $nginx_dir
    ./configure --prefix=/usr/local/nginx \
    --user=www \
    --group=www \
    --with-http_v2_module \
    
    make && make install
    if [ $? -ne 0 ];then
        echo "nginx install error"
        exit 1
    fi

#edit    
#location ~ \.php$ {
#    root           /var/wwwroot/test.com/;
#    fastcgi_pass   127.0.0.1:9000;
#    fastcgi_index  index.php;
#    fastcgi_param  SCRIPT_FILENAME $DOCUMENT_ROOT$fastcgi_script_name;
#    include        fastcgi_params;
#}
}

helps(){
    echo "redis:"
    echo "pelase add redis.so to /user/local/php5/etc/php.ini"
    echo "extension=redis.so"
    echo "extension_dir=/usr/local/php5/lib/php/extensions/no-debug-non-zts-20131226/"
    echo "---------------------------------------------------------------"
    echo 
    echo "php5"
    echo "edit /usr/local/php5/etc/fpm.conf  replace user and group for www www"
    echo "---------------------------------------------------------------"
    echo 
    echo "nginx"
    echo "
        location ~ \.php$ {
            root           /var/wwwroot/test.com/;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME \$DOCUMENT_ROOT\$fastcgi_script_name;
            include        fastcgi_params;
        }
    "
    echo "---------------------------------------------------------------"
    echo 
    
}

option=$1
case $option in
    php5)
        install_depend
        install_php5
        ;;
    php7)
        install_depend
        install_php7
        ;;
    redis)
        install_redis
        ;;
    nginx)
        install_depend
        install_nginx 
        ;;
    start)
        start_all
        ;;
    help)
        helps
        ;;
    *)
        echo "arguments error1"
        ;;
esac
#install_depend
#install_php5
#install_redis
#install_nginx

#install_php7
