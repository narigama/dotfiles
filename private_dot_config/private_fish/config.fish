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

# prompt -----------------------------------------------------------------------
zoxide init fish | source
starship init fish | source
starship config git_metrics.disabled false
starship config kubernetes.disabled false

# postgres ---------------------------------------------------------------------
function pglist
    docker ps | grep -i postgres | cat
end

function pgstart -a name -d "start a named postgres server"
    docker run --rm -d -P --name postgres-$name \
        -e POSTGRES_USER=$USER \
        -e POSTGRES_PASSWORD=tescovalue \
        -e POSTGRES_DB=$name \
        postgres:alpine
    set pgpass (openssl rand -hex 32)
    set pgport (docker port postgres-$name 5432 | cut -d: -f2)
    set -gx DATABASE_URL "postgres://$USER:$pgpass@localhost:$pgport/$name?sslmode=disable"
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

function rdstart -a name
    docker run --rm -d -P --name redis-$name redis:alpine
    set rdport (docker port redis-$name 6379 | cut -d: -f2)
    echo "redis://localhost:$rdport"
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
