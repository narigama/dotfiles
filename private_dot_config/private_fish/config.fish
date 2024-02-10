# plugin management ------------------------------------------------------------
if not type -q fisher
    echo "fisher is not installed, fetching..."
    curl -sL https://git.io/fisher | source
    fisher install jorgebucaran/fisher
    fisher install jethrokuan/fzf
end

# settings ---------------------------------------------------------------------
set -gx FZF_LEGACY_KEYBINDINGS 0

# editors ----------------------------------------------------------------------
set -gx VISUAL nvim
set -gx EDITOR nvim

# paths ------------------------------------------------------------------------
set -gx PATH $HOME/.cargo/bin:$PATH
set -gx PATH $HOME/.local/bin:$PATH

# aliases ----------------------------------------------------------------------
alias lg lazygit
alias l 'exa -lagh --git'
alias :q exit
alias :e code
alias esphome 'docker run --rm -it --name esphome -P -v $HOME/esphome:/config ghcr.io/esphome/esphome'
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'

# schemaspy --------------------------------------------------------------------
function schemaspy -a host port username password db
    mkdir -p schemaspy/tables
    docker run --rm -it -v (pwd)/schemaspy:/output schemaspy/schemaspy -t pgsql11 -host $host -port $port -u $username -p $password -db $db 
end

# docker / helm ----------------------------------------------------------------
function docker-vars -a name
    docker exec -t $name env | sort
end

function docker-port -a name -a port
  echo $name".docker.localhost:"$(docker port $name $port | cut -d: -f2)
end

alias ks 'kubectl run --rm -it --image alpine tmp-alpine'  # drop a shell on the cluster
alias kc 'kubectl config use-context'
alias kl 'kubectl config get-contexts'
alias kd 'kubectl describe'

function kn -a namespace
    kubectl config set-context --current --namespace=$namespace
end

# rust -------------------------------------------------------------------------
function add-mold
    echo [target.x86_64-unknown-linux-gnu]
    echo linker = "clang"
    echo rustflags = ["-C", "link-arg=-fuse-ld=$(which mold)"]
end

# tooling management -----------------------------------------------------------
source $HOME/.asdf/asdf.fish

# zola -------------------------------------------------------------------------
function zola
    docker run --rm -it -u $(id -u):$(id -g) -v $PWD:/app --workdir /app --name zola -p :1111 ghcr.io/getzola/zola:v0.17.1 $argv
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

# poetry -----------------------------------------------------------------------
function po-a -a name
    poetry add $name@\* $argv[2..-1]
end

function po-ad -a name
    poetry add --group dev $name@\* $argv[2..-1]
end

function po-r -a name
    poetry add $name@\* $argv[2..-1]
end

function po-rd -a name
    poetry add --group dev $name@\* $argv[2..-1]
end

# postgres ---------------------------------------------------------------------
function pglist
    docker ps | grep -i postgres | cat
end

function pgenv -a name
    set pgport (docker port postgres-$name 5432 | cut -d: -f2)
    set -gx DATABASE_URL "postgres://postgres:postgres@localhost:$pgport/postgres?sslmode=disable"
    echo $DATABASE_URL
end

function pgstart -a name
    docker run --rm -d -P --name postgres-$name \
        -e POSTGRES_PASSWORD=postgres \
        supabase/postgres

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
    set rdport (docker port redis-$name 6379 | cut -d: -f2)
    set -gx REDIS_URL "redis://localhost:$rdport"
    echo $REDIS_URL
end

function rdstart -a name
    docker run --rm -d -P --name redis-$name redis:alpine
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
    set rmqport (docker port rmq-$name 15672 | cut -d: -f2)
    echo "http://localhost:$rmqport/"

    # and the amqp port, whilst also setting it as AMQP_URL
    set rmqport (docker port rmq-$name 15675 | cut -d: -f2)
    set -gx MQTT_URL "ws://guest:guest@localhost:$rmqport/ws"
    echo $MQTT_URL

    # and the amqp port, whilst also setting it as AMQP_URL
    set rmqport (docker port rmq-$name 5672 | cut -d: -f2)
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

    set mnport (docker port minio-$name 9001 | cut -d: -f2)
    echo "Admin Dashboard:  http://localhost:$mnport ($name:$mnpass)"

    set mnport (docker port minio-$name 9000 | cut -d: -f2)
    set -gx BUCKET_URL "http://localhost:$mnport"
    echo "Bucket URL:       $BUCKET_URL"
end

function mnstop -a name
    docker stop minio-$name
end

# machine specific config ------------------------------------------------------
touch $HOME/.secret_stuff
source $HOME/.secret_stuff

