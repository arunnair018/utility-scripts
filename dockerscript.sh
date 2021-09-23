
# change and uncomment to project directory if executing from root
# eval "cd ~/Documents/impressBot/"

# login to aws, sourcing the rc file
eval "source ~/.zshrc"

# to restart the server
if [[ $1 = "restart" ]]; then
    # down all containers
    echo "\nBringing down containers...";
    eval "docker-compose down"

    # up all containers
    echo "\Starting up containers...";
    eval "docker-compose up"

# to rebuild the server
elif [[ $1 = "rebuild" ]] ; then
    # stop all running containers
    echo '\nStopping running containers (if available)...'
    docker stop $(docker ps -aq)

    # remove all stopped containers
    echo '\nRemoving containers ...'
    docker rm $(docker ps -aq)

    # remove all images
    echo '\nRemoving images ...'
    docker rmi $(docker images -q)

    # remove all stray volumes if any
    echo '\nRevoming docker container volumes (if any)'
    docker volume rm $(docker volume ls -q)

    # remove all internal networks too
    echo '\nPruning docker system... (deleting internal networks and cached objects)'
    echo 'Some cases it might take time...'
    docker system prune -f

    # docker build
    echo "\n\n Building docker..."
    docker-compose build

    # up all services
    echo "\n\n Bringing up containers..."
    docker-compose up
else
    # if no argument provided
   echo "\n run  'sh dockerscript.sh restart/rebuild'"
   echo "\t restart - to compose down and up all the containers"
   echo "\t rebuild - to remove all container, images and volume, then rebuild fresh.\n"
fi;
