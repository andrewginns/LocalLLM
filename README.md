# Quickstart
Setup the ollama and litellm containers using the `Makefile`
* `make setup-containers`
* Optionally attempt to pull latest code for each container using `make setup-containers EXPERIMENTAL=True`

## Model Choice
By default the [ollama zephyr model](https://ollama.ai/library/zephyr:latest) is downloaded and used.

This can be changed to any other ollama model from the [supported list](https://ollama.ai/library) e.g.:
* `make setup-containers OLLAMA_MODEL=llama2:13b-chat`
