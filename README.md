# [Backstage](https://backstage.io)

This is your newly scaffolded Backstage App, Good Luck!

To start the app, run:

```sh
yarn install
yarn start
```
only build
```
make docker-build
```

build container and push
```
make build-and-push-to-remote
```
or locally:
```
make build-to-k3s
```
run on docker
```
docker run -it -p 7007:7007 --env-file .env local/backstage-app
```

to debug plugins and change them see https://backstage.io/docs/next/tooling/local-dev/linking-local-packages/#generating-temporary-patches


LOG_LEVEL=debug yarn backstage-cli repo start --link ../../../backstage

LOG_LEVEL=debug yarn backstage-cli repo start --link ../../../backstage > ../../../backend.log 
tail -f backend.log

LOG_LEVEL=debug yarn backstage-cli repo start --link ../../../backstage > ../../../backend.log 


from packages/app :
LOG_LEVEL=debug yarn start --link ../../../backstage > ../../../frontend.log 
LOG_LEVEL=debug yarn start --link ../../../backstage
#tail -f frontend.log

in another terminal from packages/backend
#LOG_LEVEL=debug yarn backstage-cli package start packages/backend --link ../backstage > ../backend.log
LOG_LEVEL=debug yarn start --link ../../../backstage > ../../../backend.log
LOG_LEVEL=debug yarn start --link ../../../backstage

cat ../backend.log | grep kubernetes

cat ../backend.log | grep ROO

