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

# rust ----------------------------------------------------------------------
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

function pgstart -a name port -d "start a named postgres server"
    set pgpass (openssl rand -hex 32)
    docker run --rm -d -p $port:5432 --name postgres-$name \
        -e POSTGRES_USER=$USER \
        -e POSTGRES_PASSWORD=$pgpass \
        -e POSTGRES_DB=$name \
        postgres:alpine
    set -gx DATABASE_URL "postgres://$USER:$pgpass@localhost:$port/$name?sslmode=disable"
    echo $DATABASE_URL
end

function pgstop -a name -d "stop a named postgres server"
    docker stop postgres-$name
end

function pgshell -a name
    docker exec -it postgres-$name psql -U$USER $name
end

# redis ------------------------------------------------------------------------
function rdlist
    docker ps | grep -i redis | cat
end

function rdstart -a name port
    docker run --rm -d -p $port:port --name redis-$name redis:alpine
    echo "redis://localhost:$port"
end

function rdstop -a name
    docker stop redis-$name
end

function rdshell -a name
    docker exec -it redis-$name redis-cli
end

# machine specific config ------------------------------------------------------
touch $HOME/.secret_stuff
source $HOME/.secret_stuff
