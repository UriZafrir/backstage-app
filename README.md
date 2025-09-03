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