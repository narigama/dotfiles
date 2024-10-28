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
alias esphome 'docker run --rm -it --name esphome -P -v $HOME/esphome:/config ghcr.io/esphome/esphome'
alias qr 'qrencode -t utf8'
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'

# monitors ---------------------------------------------------------------------
function brightness -a value
    ddcutil setvcp 10 $value -d 1
    ddcutil setvcp 10 $value -d 2
end

# schemaspy --------------------------------------------------------------------
function schemaspy -a target
    mkdir -p schemaspy/tables
    set host $(docker inspect postgres-$target -f '{{.NetworkSettings.IPAddress}}')
    docker run --rm -it -v (pwd)/schemaspy:/output schemaspy/schemaspy -t pgsql11 -host $host -port 5432 -u postgres -p postgres -db postgres 
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

# prompt -----------------------------------------------------------------------
zoxide init fish | source
atuin gen-completions --shell fish | source
atuin init fish --disable-up-arrow | source
starship init fish | source
starship config git_metrics.disabled false
starship config kubernetes.disabled false

# jupyter / livebook -----------------------------------------------------------
alias notebook "docker run --name tensorflow-notebook -it --rm -p 8888:8888 -u (id -u):(id -g) -v (pwd):/home/jovyan jupyter/tensorflow-notebook"
alias livebook "docker run --name livebook --rm -it -p 8080:8080 -p 8081:8081 --pull always -u (id -u):(id -g) -v (pwd):/data ghcr.io/livebook-dev/livebook"

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
        postgres:16-alpine

    pgenv $name
end

function pgstart-inmemory -a name
    docker run --rm -d -P --name postgres-$name \
        --tmpfs /var/lib/postgresql/data \
        -e PGDATA=/var/lib/postgresql/data \
        -e POSTGRES_PASSWORD=postgres \
        postgres:16-alpine

    pgenv $name
end

function pgstop -a name
    docker stop postgres-$name
    set -u DATABASE_URL
end

function pgshell -a name
    docker exec -it postgres-$name psql -Upostgres -h127.0.0.1
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
