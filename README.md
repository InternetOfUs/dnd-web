# dnd-web

DnD WeNet web "app".

## Setup

This project use [Just](https://github.com/casey/just) (a better makefile)

### pre-commits

A bunch of pre-commits are used in this project. Please install [pre-commit](https://pre-commit.com/) then install them `pre-commit install` and `pre-commit install --hook-type commit-msg`.

## Debug the front-end

`just run-front` then connect to <http://localhost:8888>

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
