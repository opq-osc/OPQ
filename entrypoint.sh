#!/bin/sh

run_args=()

if [[ "$token" == "" ]] ; then
    echo "注意，你没有配置 Token"
else
    run_args+=("-token" "$token")
fi

if [[ "$port" == "" ]] ; then
    echo "将默认运行在 8086 ，注意安全组和防火墙情况，若仅内网使用，请关闭端口防止渗透"
else
    echo "将运行在 $port 端口"
    run_args+=("-port" "$port")
fi

if [[ "$wsserver" != "" ]] ; then
    echo "ws server: $wsserver"
    run_args+=("-wsserver" "$wsserver")
fi

if [[ "$wthread" != "" ]] ; then
    echo "ws thread: $wthread"
    run_args+=("-wthread" "$wthread")
fi

echo "开始运行 OPQBot"

echo "运行参数: ${run_args[@]}"
exec ./opqbot/OPQBot "${run_args[@]}"
