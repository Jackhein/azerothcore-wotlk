1/ dev structure branchs
update branch "azerothcore_master" with
merge branches "azerothcore_master" to "master"
test
merge branches "master" to "worldserver"
merge branches "master" to "authserver"
test
make a release
2/ how to do a release
check .github/workflows/docker.yml
check in github.com settings/actions/runners of project
check if runner is present : ~/actions-runner
check config is correct (token)
- to update:
- ./config.sh remove
- ./config.sh --url [URL] --token [TOKEN]
run ./run.sh
