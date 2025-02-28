# Murloc Village Servers doc

## Branches
 - authserver:          modification for authserver
 - worldserver:         modification for worldserver
 - azerothcore-master:  for last modification of azerothcore-master
 - master:              current general state of servers without modifications
 - feature/*:           modules creation

## Updates
### Updates from azerothcore
If it's the first time, run `git remote add upstream https://github.com/azerothcore/azerothcore-wotlk`
Make sure you're on the `azerothcore-master` branch and then fetch modification from upstream and apply them to current branch:
```
git checkout azerothcore-master
git fetch upstream
git rebase upstream/master
git pull --rebase
```
Eventually, fix merge error on your favorite IDE then commit and push the modifications:
```
git commit -m "Sync from azerothcore YYYYMMDD" #Replace YYYYMMDD by current date
git push
```

Now we want to update master
```
git checkout master
git merge azerothcore-master master
# Solve potential conlicts, then commit with the correct date instead of YYYYMMDD
git commit -m "Merge from azerothcore-master YYYYMMDD"
git push
```
Do the same for the other branches (authserver/worldserver/features) from master instead of azerothcore-master
```
git checkout #branch
git merge master #branch
# Solve potential conlicts, then commit with the correct date instead of YYYYMMDD
git commit -m "Merge from azerothcore-master YYYYMMDD"
git push
```

### Module creation

### Module adding

## Testing docker
Choose branch to test and build image locally:
```
git checkout #branch
docker build . -t test_image
```
Check for error in build
Then create the volume:
```dockerignore
docker run -itd test_image:latest bash
#if necessary add volume to docker network environment
docker network connect server_azeroth #test_volume
#if necessary get/update conf file
docker cp /path/to/*.conf test_volume:/usr/local/etc/
docker attach test_volume
```
    On root of the project run `docker build .`
    Check any error

## Release updates docker images
