#!/bin/bash

echo "#############################################"
echo -e "        憑證管理        "
echo "#############################################"
echo "     1  列出憑證"
echo "     2  新增憑證"
echo "     3  移除憑證"
echo "     4  離開"
echo "#############################################"

read -p "請選擇操作: " option

case $option in
1)
    # 列出憑證
    echo "#############################################"
    echo -e "        憑證列表        "
    echo "#############################################"
    /usr/bin/acme.sh --list
    ;;
2)
    # 新增憑證
    echo "#############################################"
    echo -e "        新增憑證        "
    echo "#############################################"
    read -p "請輸入DNS供應商(dns_dpi、dns_cf): " dns_challenge
    read -p "請輸入Domain安裝目錄名稱: " cert_dir

    ISSUE="/usr/bin/acme.sh --server zerossl --register-account -m ${ACME_EMAIL:-example@gmail.com} --issue --force --log --dns $dns_challenge"
    INSTALL="/usr/bin/acme.sh --install-cert --key-file /cert/$cert_dir/cert.key --fullchain-file /cert/$cert_dir/cert.pem --log"

    domains=()
    while true; do
        read -p "請輸入要簽發憑證的Domain(每次輸入一個、輸入n結束): " domain
        if [[ $domain == "n" ]]; then
            break
        fi
        domains+=("$domain")
    done

    for domain in "${domains[@]}"; do
        ISSUE=$(echo $ISSUE -d "$domain")
        INSTALL=$(echo $INSTALL -d "$domain")
    done
    { # try
        echo "憑證簽發中..."
        $ISSUE
        echo "憑證簽發成功!"
        echo "憑證安裝中..."
        mkdir -p /cert/$cert_dir
        $INSTALL
        echo "憑證安裝成功!"
    } || { # catch
        echo "憑證發行失敗"
    }
    ;;
3)
    # 移除憑證
    echo "#############################################"
    echo -e "        移除憑證        "
    echo "#############################################"
    echo "     0  離開"
    # 列出憑證
    /usr/bin/acme.sh --list | sed '1d' | awk '{print $1}' | sort -u | nl

    read -p "請輸入要移除的憑證編號: " cert_num
    if [[ $cert_num == "0" ]]; then
        exit 0
    fi
    # 獲取憑證名稱
    domain_name=$(/usr/bin/acme.sh --list | sed '1d' | awk '{print $1}' | sort -u | nl | awk 'NR=='$cert_num' {print $2}')

    # 移除憑證
    /usr/bin/acme.sh --remove -d $domain_name

    if [ $? -eq 0 ]; then
        echo "成功移除憑證 $domain_name "
    else
        echo "移除憑證 $domain_name 失敗"
    fi
    ;;
4)
    #退出腳本
    exit 0
    ;;
*)
    echo "無效的選項!"
    ;;
esac
