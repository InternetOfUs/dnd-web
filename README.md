# dnd-web

DnD WeNet web "app".

## Setup

This project use [Just](https://github.com/casey/just) (a better makefile)

**Dependencies**

  - cargo 1.61
  - flutter >= 3, < 4
  - just 1.2.0

### pre-commits

A bunch of pre-commits are used in this project. Please install [pre-commit](https://pre-commit.com/) then install them `pre-commit install` and `pre-commit install --hook-type commit-msg`.

## Build

```bash
just build
```

## Prod variables

please provide .env file or set the following variables

```
WENET_SECRET=
WENET_BASE_URL="https://wenet.u-hopper.com/dev/"
FIREBASE_API_KEY=
FIREBASE_URL=
```

## Run

```bash
just run
```

Then connect to <http://localhost:8888>

## Misc - Available recipes

```bash
    build              # Build all
    build-back         # build the backend
    build-front        # build the frontend
    cargo CMD          # run given cargo CMD for the backend
    copy-front-to-back # copy builded frontend into the backend
    flutter CMD        # run given flutter CMD for the frontend
    run                # Run the app
    run-back           # run only the backend
    run-front          # run only the frontend
```
