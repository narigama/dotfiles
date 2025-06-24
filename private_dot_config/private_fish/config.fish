# plugins ----------------------------------------------------------------------
if not type -q fisher
    echo "Installing Fisher and Friends"
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
    fisher install jethrokuan/fzf
end

# settings ---------------------------------------------------------------------
set fish_greeting

# editors ----------------------------------------------------------------------
set -gx VISUAL nvim
set -gx EDITOR nvim

# paths ------------------------------------------------------------------------
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin

# aliases ----------------------------------------------------------------------
alias cb 'xsel -b'
alias lg lazygit
alias l 'eza -lagh --git'
alias ll 'eza -lgh --git'
alias :q exit
alias :e code
alias qr 'qrencode -t utf8'
alias venv 'source .venv/bin/activate.fish'
alias ontime 'docker run --rm -d --name=ontime -p 4001:4001 -e TZ=Europe/London getontime/ontime'
alias esphome 'docker run --rm -it --name esphome -P -v $HOME/esphome:/config ghcr.io/esphome/esphome'
alias sysupdate 'paru -Syu --noconfirm'
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'

# vpn stuff --------------------------------------------------------------------
function vpnlist
    openvpn3 configs-list -v
end

function vpnsessions
    openvpn3 sessions-list
end

function vpnstart -a name
    openvpn3 session-start --config $name
end

function vpnstop -a name
    openvpn3 session-manage --config $name --disconnect
end

# monitors ---------------------------------------------------------------------
function brightness -a value
    ddcutil setvcp 10 $value -d 1
    ddcutil setvcp 10 $value -d 2
end

function theme -a image
    uvx --from=pywal wal -q -i $image
    swww img --transition-type=fade --transition-fps=120 --transition-duration=1 $image
end

# docker / helm ----------------------------------------------------------------
function docker-vars -a name
    docker exec -t $name env | sort
end

function docker-port -a name -a port
  echo $name".docker.localhost:"$(docker port $name $port | head -n1 | cut -d: -f2)
end

alias ks 'kubectl run --rm -it --image alpine tmp-alpine'  # drop a shell on the cluster
alias kc 'kubectl config use-context'
alias kl 'kubectl config get-contexts'
alias kd 'kubectl describe'

function kn -a namespace
    kubectl config set-context --current --namespace=$namespace
end

# tooling management -----------------------------------------------------------
source $HOME/.asdf/asdf.fish

# zola -------------------------------------------------------------------------
function zola
    docker run --rm -it -u $(id -u):$(id -g) -v $PWD:/app --workdir /app --name zola -p 1111:1111 ghcr.io/getzola/zola:v0.17.1 $argv
end

# python -----------------------------------------------------------------------
function pyclean
    # remove all instances of __pycache__, skip the .venv
    find . -type d -name __pycache__ | grep -Ev '^\./\.venv' | xargs rm -r
end

# prompt -----------------------------------------------------------------------
zoxide init fish | source
atuin gen-completions --shell fish | source
atuin init fish --disable-up-arrow | source
starship init fish | source
starship config git_metrics.disabled false
starship config kubernetes.disabled false

# jupyter / livebook / appsmith -------------------------------------------------
alias notebook "docker run --name tensorflow-notebook -it --rm -p 8888:8888 -u (id -u):(id -g) -v (pwd):/home/jovyan jupyter/tensorflow-notebook"
alias livebook "docker run --name livebook --rm -it -p 8080:8080 -p 8081:8081 --pull always -u (id -u):(id -g) -v (pwd):/data ghcr.io/livebook-dev/livebook"

function docker-wait-for -a name
    echo -n "Waiting for $name to become available"
    while [ (docker inspect -f {{.State.Health.Status}} $name) != "healthy" ]
        sleep 1
        echo -n "."
    end
end

function appsmith
    docker run -d -P --rm --name appsmith appsmith/appsmith-ee
    docker-wait-for appsmith
    xdg-open http://localhost:$(docker port appsmith 80 | head -n1 | cut -d: -f2)
end

# postgres ---------------------------------------------------------------------
function pglist
    docker ps | grep -i postgres | cat
end

function pgenv -a name
    set pgport (docker port postgres-$name 5432 | head -n1 | cut -d: -f2)
    set -gx DATABASE_URL "postgres://postgres:postgres@localhost:$pgport/postgres?sslmode=disable"
    echo $DATABASE_URL
end

function pgstart -a name
    docker run --rm -d -P --name postgres-$name \
        -e POSTGRES_PASSWORD=postgres \
        postgres:17-alpine \
        postgres \
        -c shared_preload_libraries=pg_stat_statements \
        -c pg_stat_statements.track=all \
        -c fsync=off \
        -c full_page_writes=off \
        -c synchronous_commit=off \
        -c bgwriter_lru_maxpages=0 \
        -c jit=off

    pgenv $name
end

function pgstart-inmemory -a name
    docker run --rm -d -P --name postgres-$name \
        --tmpfs /var/lib/postgresql/data \
        -e PGDATA=/var/lib/postgresql/data \
        -e POSTGRES_PASSWORD=postgres \
        postgres:17-alpine \
        -c shared_preload_libraries=pg_stat_statements \
        -c pg_stat_statements.track=all \
        -c fsync=off \
        -c full_page_writes=off \
        -c synchronous_commit=off \
        -c bgwriter_lru_maxpages=0 \
        -c jit=off

    pgenv $name
end

function pgstop -a name
    docker stop postgres-$name
    set -u DATABASE_URL
end

function pgshell -a name
    docker exec -it postgres-$name psql -Upostgres -h127.0.0.1
end

function pgcli -a name
    set pgport (docker port postgres-$name 5432 | head -n1 | cut -d: -f2)
    uvx pgcli "postgres://postgres:postgres@localhost:$pgport/postgres?sslmode=disable"
end

# redis ------------------------------------------------------------------------
function rdlist
    docker ps | grep -i redis | cat
end

function rdenv -a name
    set rdport (docker port redis-$name 6379 | head -n1 | cut -d: -f2)
    set -gx REDIS_URL "redis://localhost:$rdport"
    echo $REDIS_URL
end

function rdstart -a name
    # start redis and disable persistance
    docker run --rm -d -P --name redis-$name redis:alpine
    docker exec redis-$name redis-cli config set save "" > /dev/null
    docker exec redis-$name redis-cli config set appendonly no > /dev/null
    rdenv $name
end

function rdstop -a name
    docker stop redis-$name
    set -u REDIS_URL
end

function rdshell -a name
    docker exec -it redis-$name redis-cli
end

function rdcli -a name
    set rdport (docker port redis-$name 6379 | head -n1 | cut -d: -f2)
    uvx iredis --url "redis://localhost:$rdport"
end

# rmq --------------------------------------------------------------------------
function rmqlist
    docker ps | grep -i rmq | cat
end

function rmqenv -a name
    # display the http port
    set rmqport (docker port rmq-$name 15672 | head -n1 | cut -d: -f2)
    echo "http://localhost:$rmqport/"

    # and the amqp port, whilst also setting it as AMQP_URL
    set rmqport (docker port rmq-$name 15675 | head -n1 | cut -d: -f2)
    set -gx MQTT_URL "ws://guest:guest@localhost:$rmqport/ws"
    echo $MQTT_URL

    # and the amqp port, whilst also setting it as AMQP_URL
    set rmqport (docker port rmq-$name 5672 | head -n1 | cut -d: -f2)
    set -gx AMQP_URL "amqp://guest:guest@localhost:$rmqport"
    echo $AMQP_URL

end

function rmqstart -a name
    docker run --rm -d -P -p :15675 --name rmq-$name rabbitmq:3-management-alpine
    sleep 3  # wait otherwise the next command running too early shuts rmq down
    docker exec rmq-$name ash -c 'rabbitmq-plugins enable rabbitmq_web_mqtt'
    rmqenv $name
end

function rmqstop -a name
    docker stop rmq-$name
    set -u AMQP_URL
end

function rmqshell -a name
    docker exec -it rmq-$name ash
end

# minio ------------------------------------------------------------------------
function mnlist
    docker ps | grep -i minio | cat
end

function mnstart -a name
    set mnpass (openssl rand -hex 4)
    docker run --rm -d --name minio-$name \
        -P \
        -e MINIO_ROOT_USER=$name \
        -e MINIO_ROOT_PASSWORD=$mnpass \
        bitnami/minio:latest

    set mnport (docker port minio-$name 9001 | head -n1 | cut -d: -f2)
    echo "Admin Dashboard:  http://localhost:$mnport ($name:$mnpass)"

    set mnport (docker port minio-$name 9000 | head -n1 | cut -d: -f2)
    set -gx BUCKET_URL "http://localhost:$mnport"
    echo "Bucket URL:       $BUCKET_URL"
end

function mnstop -a name
    docker stop minio-$name
end

# machine specific config ------------------------------------------------------
touch $HOME/.secret_stuff
source $HOME/.secret_stuff
