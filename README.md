# Diaspora Docker Compose

This respository is intended for those who want to quickly spin up a demo of [Diaspora](https://diapsorafoundation.org) locally.  You need docker-compose and all it's requirements installed on your machine.  One command should get you started:

```
docker-compose up
```

Once up, you can connect to the app server like so:

```
docker exec -it diasporatest_app_1 bash -l
```

And then run rails console

```
root@diasporatest_app_1:/app# bundle exec rails console
```

Have fun!