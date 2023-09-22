#!/bin/bash
# Author: Jrohy
# github: https://github.com/Jrohy/multi-v2ray

#Registre la ruta donde se ejecutó el script por primera vez
begin_path=$(pwd)

#Método de instalación, 0 es una instalación nueva, 1 es mantener la actualización de la configuración de v2ray
install_way=0

#Defina la variable operativa, 0 significa no, 1 significa sí
help=0

remove=0

chinese=0

#base_source_path="https://multi.netlify.app"
base_source_path="https://raw.githubusercontent.com/emirjorge/multi-v2ray-x3/master"


util_path="/etc/v2ray_util/util.cfg"

util_cfg="$base_source_path/v2ray_util/util_core/util.cfg"

bash_completion_shell="$base_source_path/v2ray"

clean_iptables_shell="$base_source_path/v2ray_util/global_setting/clean_iptables.sh"

#Centos cancela temporalmente el alias
[[ -f /etc/redhat-release && -z $(echo $SHELL|grep zsh) ]] && unalias -a

[[ -z $(echo $SHELL|grep zsh) ]] && env_file=".bashrc" || env_file=".zshrc"

#######color code########
red="31m"
green="32m"
yellow="33m"
blue="36m"
fuchsia="35m"

colorEcho(){
    color=$1
    echo -e "\033[${color}${@:2}\033[0m"
}

#######get params#########
while [[ $# > 0 ]];do
    key="$1"
    case $key in
        --remove)
        remove=1
        ;;
        -h|--help)
        help=1
        ;;
        -k|--keep)
        install_way=1
        colorEcho ${blue} "Mantener la configuración al actualizar\n"
        ;;
        --zh)
        chinese=1
        colorEcho ${blue} "Instalar la versión china..\n"
        ;;
        *)
                # unknown option
        ;;
    esac
    shift # past argument or value
done
#############################

help(){
    echo "bash v2ray.sh [-h|--help] [-k|--keep] [--remove]"
    echo "  -h, --help           Show help"
    echo "  -k, --keep           keep the config.json to update"
    echo "      --remove         remove v2ray,xray && multi-v2ray"
    echo "                       no params to new install"
    return 0
}

removeV2Ray() {
    #Desinstalar el script V2ray
    #bash <(curl -L -s https://multi.netlify.app/go.sh) --remove >/dev/null 2>&1
    bash <(curl -L -s https://raw.githubusercontent.com/emirjorge/multi-v2ray-x3/master/go.sh) --remove >/dev/null 2>&1
    rm -rf /etc/v2ray >/dev/null 2>&1
    rm -rf /var/log/v2ray >/dev/null 2>&1

    #Desinstalar el script de Xray
    #bash <(curl -L -s https://multi.netlify.app/go.sh) --remove -x >/dev/null 2>&1
    bash <(curl -L -s https://raw.githubusercontent.com/emirjorge/multi-v2ray-x3/master/go.sh) --remove -x >/dev/null 2>&1
    rm -rf /etc/xray >/dev/null 2>&1
    rm -rf /var/log/xray >/dev/null 2>&1

    #Limpiar reglas de iptable relacionadas con v2ray
    bash <(curl -L -s $clean_iptables_shell)

    #Desinstalar multi-v2ray
    pip uninstall v2ray_util -y
    rm -rf /usr/share/bash-completion/completions/v2ray.bash >/dev/null 2>&1
    rm -rf /usr/share/bash-completion/completions/v2ray >/dev/null 2>&1
    rm -rf /usr/share/bash-completion/completions/xray >/dev/null 2>&1
    rm -rf /etc/bash_completion.d/v2ray.bash >/dev/null 2>&1
    rm -rf /usr/local/bin/v2ray >/dev/null 2>&1
    rm -rf /etc/v2ray_util >/dev/null 2>&1
    rm -rf /etc/profile.d/iptables.sh >/dev/null 2>&1
    rm -rf /root/.iptables >/dev/null 2>&1

    #Eliminar la tarea de actualización programada de v2ray
    crontab -l|sed '/SHELL=/d;/v2ray/d'|sed '/SHELL=/d;/xray/d' > crontab.txt
    crontab crontab.txt >/dev/null 2>&1
    rm -f crontab.txt >/dev/null 2>&1

    if [[ ${package_manager} == 'dnf' || ${package_manager} == 'yum' ]];then
        systemctl restart crond >/dev/null 2>&1
    else
        systemctl restart cron >/dev/null 2>&1
    fi

    #Eliminar variables de entorno multi-v2ray
    sed -i '/v2ray/d' ~/$env_file
    sed -i '/xray/d' ~/$env_file
    source ~/$env_file

    rc_service=`systemctl status rc-local|grep loaded|egrep -o "[A-Za-z/]+/rc-local.service"`

    rc_file=`cat $rc_service|grep ExecStart|awk '{print $1}'|cut -d = -f2`

    sed -i '/iptables/d' ~/$rc_file

    colorEcho ${green} " \e[91m\e[43mV2RAY DESINSTALADO!\e[0m"
}

closeSELinux() {
    #Deshabilitar SELinux
    if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
    fi
}

checkSys() {
    #Comprueba si es Root
    [ $(id -u) != "0" ] && { colorEcho ${red} "Error: Debes ser Root para ejecutar este script"; exit 1; }

    if [[ `command -v apt-get` ]];then
        package_manager='apt-get'
    elif [[ `command -v dnf` ]];then
        package_manager='dnf'
    elif [[ `command -v yum` ]];then
        package_manager='yum'
    else
        colorEcho $red "SO No soportado!"
        exit 1
    fi
}

#Instalar dependencias
installDependent(){
    if [[ ${package_manager} == 'dnf' || ${package_manager} == 'yum' ]];then
        ${package_manager} install socat crontabs bash-completion which -y
    else
        ${package_manager} update
        ${package_manager} install socat cron bash-completion ntpdate gawk -y
    fi

    #install python3 & pip
    #source <(curl -sL https://python3.netlify.app/install.sh)
    source <(curl -sL https://raw.githubusercontent.com/emirjorge/Premium-V2/master/python3-pip/install.sh)
}

updateProject() {
    [[ ! $(type pip 2>/dev/null) ]] && colorEcho $red "pip no instalado!" && exit 1

    [[ -e /etc/profile.d/iptables.sh ]] && rm -f /etc/profile.d/iptables.sh

    rc_service=`systemctl status rc-local|grep loaded|egrep -o "[A-Za-z/]+/rc-local.service"`

    rc_file=`cat $rc_service|grep ExecStart|awk '{print $1}'|cut -d = -f2`

    if [[ ! -e $rc_file || -z `cat $rc_file|grep iptables` ]];then
        local_ip=`curl -s http://api.ipify.org 2>/dev/null`
        [[ `echo $local_ip|grep :` ]] && iptable_way="ip6tables" || iptable_way="iptables" 
        if [[ ! -e $rc_file || -z `cat $rc_file|grep "/bin/bash"` ]];then
            echo "#!/bin/bash" >> $rc_file
        fi
        if [[ -z `cat $rc_service|grep "\[Install\]"` ]];then
            cat >> $rc_service << EOF

[Install]
WantedBy=multi-user.target
EOF
            systemctl daemon-reload
        fi
        echo "[[ -e /root/.iptables ]] && $iptable_way-restore -c < /root/.iptables" >> $rc_file
        chmod +x $rc_file
        systemctl restart rc-local
        systemctl enable rc-local

        $iptable_way-save -c > /root/.iptables
    fi

    pip install -U v2ray_util

    if [[ -e $util_path ]];then
        [[ -z $(cat $util_path|grep lang) ]] && echo "lang=en" >> $util_path
    else
        mkdir -p /etc/v2ray_util
        curl $util_cfg > $util_path
    fi

    [[ $chinese == 1 ]] && sed -i "s/lang=en/lang=zh/g" $util_path

    rm -f /usr/local/bin/v2ray >/dev/null 2>&1
    ln -s $(which v2ray-util) /usr/local/bin/v2ray
    rm -f /usr/local/bin/xray >/dev/null 2>&1
    ln -s $(which v2ray-util) /usr/local/bin/xray

    #Eliminar el antiguo script v2ray bash_completion
    [[ -e /etc/bash_completion.d/v2ray.bash ]] && rm -f /etc/bash_completion.d/v2ray.bash
    [[ -e /usr/share/bash-completion/completions/v2ray.bash ]] && rm -f /usr/share/bash-completion/completions/v2ray.bash

    #Script v2ray bash_completion actualizado, BASH_COMPLETION_SHELL="https://raw.githubusercontent.com/emirjorge/multi-v2ray-x3/master/v2ray"
    curl $bash_completion_shell > /usr/share/bash-completion/completions/v2ray
    curl $bash_completion_shell > /usr/share/bash-completion/completions/xray
    if [[ -z $(echo $SHELL|grep zsh) ]];then
        source /usr/share/bash-completion/completions/v2ray
        source /usr/share/bash-completion/completions/xray
    fi
    
    #Instalar el programa principal V2ray
    [[ ${install_way} == 0 ]] && bash <(curl -L -s https://raw.githubusercontent.com/emirjorge/multi-v2ray-x3/master/go.sh)
}

#Sincronización horaria
timeSync() {
    if [[ ${install_way} == 0 ]];then
        echo -e "${Info} Sincronizando fecha.. ${Font}"
        if [[ `command -v ntpdate` ]];then
            ntpdate pool.ntp.org
        elif [[ `command -v chronyc` ]];then
            chronyc -a makestep
        fi

        if [[ $? -eq 0 ]];then 
            colorEcho $green "Sincronización de Hora exitosa"
            colorEcho $blue "Fecha: `date -R`"
        fi
    fi
}

profileInit() {

    #Limpiar las variables de entorno del módulo v2ray
    [[ $(grep v2ray ~/$env_file) ]] && sed -i '/v2ray/d' ~/$env_file && source ~/$env_file

    #Resuelva el problema de visualización chino de Python3
    [[ -z $(grep PYTHONIOENCODING=utf-8 ~/$env_file) ]] && echo "export PYTHONIOENCODING=utf-8" >> ~/$env_file && source ~/$env_file

    #Nueva configuración para una instalación nueva
    [[ ${install_way} == 0 ]] && v2ray new

    echo ""
}

installFinish() {
    #Retorna al principio
    cd ${begin_path}

    [[ ${install_way} == 0 ]] && WAY="instalacion" || WAY="actualiacion"
    colorEcho  ${green} "${WAY} multi-v2ray exitosa!\n"

    if [[ ${install_way} == 0 ]]; then
        clear

        v2ray info

        echo -e " \e[91m\e[43m ESCRIBE 'v2ray' PARA ENTRAR AL MENÚ V2RAY\e[0m\n"
    fi
}


main() {

    [[ ${help} == 1 ]] && help && return

    [[ ${remove} == 1 ]] && removeV2Ray && return

    [[ ${install_way} == 0 ]] && colorEcho ${blue} "NUEVA INSTALACION\n"

    checkSys

    installDependent

    closeSELinux

    timeSync

    updateProject

    profileInit

    installFinish
}

main
