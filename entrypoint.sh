#!/bin/sh
if [[ "$token" == "" ]] ; then
    if [[ "$(awk -F= '$1 ~ /^Token.*$/ {gsub(/^\s*|\s*$|"/, "",$2);print $2}' CoreConf.conf)" != "" ]] ; then
        echo "使用配置文件中的Token运行"
    else
        echo "你Token呢？认真读文档啊喂 文档链接: https://github.com/opq-osc/OPQ/wiki/%E9%80%9A%E8%BF%87-Docker-%E5%AE%89%E8%A3%85 "
        exit 1
    fi
else
    sed -i "s/Token\s*=.*/Token = \"${token}\"/g" CoreConf.conf
fi
if [[ "$port" != "" ]] ; then
    sed -i "s/Port\s*=.*/Port = \"${port}\"/g" CoreConf.conf
    echo "已经将机器人地址设置为$port"
fi
echo "开始执行OPQBot"
/apps/OPQBot