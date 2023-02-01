# plugin management ------------------------------------------------------------
if not type -q fisher
    echo "fisher is not installed, fetching..."
    curl -sL https://git.io/fisher | source
    fisher install jorgebucaran/fisher
    fisher install jethrokuan/fzf
end

# settings ---------------------------------------------------------------------
set -U FZF_LEGACY_KEYBINDINGS 0

# editors ----------------------------------------------------------------------
set -gx EDITOR 'code -w'
set -gx VISUAL 'code -w'

# paths ------------------------------------------------------------------------
set -gx PATH $HOME/.cargo/bin:$PATH
set -gx PATH $HOME/.local/bin:$PATH

# aliases ----------------------------------------------------------------------
alias l 'exa -lagh --git'
alias :q exit
alias :e code
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'

# docker / helm ----------------------------------------------------------------
function docker-vars -a name
    docker exec -t $name env | sort
end

alias ks 'kubectl run --rm -it --image alpine tmp-alpine'  # drop a shell on the cluster
alias kd 'kubectl describe'

function kc -a cluster
    kubectl config use-context $cluster
end

function kn -a namespace
    kubectl config set-context --current --namespace=$namespace
end

function kl
    kubectl config get-contexts
end

# rust -------------------------------------------------------------------------
function add-mold
    echo [target.x86_64-unknown-linux-gnu]
    echo linker = "clang"
    echo rustflags = ["-C", "link-arg=-fuse-ld=$(which mold)"]
end

# prompt -----------------------------------------------------------------------
zoxide init fish | source
starship init fish | source
starship config git_metrics.disabled false
starship config kubernetes.disabled false

# postgres ---------------------------------------------------------------------
function pglist
    docker ps | grep -i postgres | cat
end

function pgstart -a name
    set pgpass (openssl rand -hex 8)
    docker run --rm -d -P --name postgres-$name \
        -e POSTGRES_USER=$name \
        -e POSTGRES_PASSWORD=$pgpass \
        -e POSTGRES_DB=$name \
        postgres:alpine

    set pgport (docker port postgres-$name 5432 | cut -d: -f2)
    set -gx DATABASE_URL "postgres://$name:$pgpass@localhost:$pgport/$name?sslmode=disable"
    echo $DATABASE_URL
end

function pgstop -a name
    docker stop postgres-$name
end

function pgshell -a name
    docker exec -it postgres-$name psql -U$name $name
end

# redis ------------------------------------------------------------------------
function rdlist
    docker ps | grep -i redis | cat
end

function rdstart -a name
    docker run --rm -d -P --name redis-$name redis:alpine
    set rdport (docker port redis-$name 6379 | cut -d: -f2)
    set -gx REDIS_URL "redis://localhost:$rdport"
    echo $REDIS_URL
end

function rdstop -a name
    docker stop redis-$name
end

function rdshell -a name
    docker exec -it redis-$name redis-cli
end

# minio ------------------------------------------------------------------------
function mnlist
    docker ps | grep -i minio | cat
end

function mnstart -a name
    set mnpass (openssl rand -hex 4)
    docker run --rm -d --name minio-$name \
        -p 0:9000 \
        -p 0:9001 \
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
