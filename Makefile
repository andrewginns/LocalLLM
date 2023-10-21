SHELL = /bin/bash
OLLAMA_MODEL = zephyr-custom

setup-ollama:
	nohup ollama serve > ollama.out 2>&1 &
	sleep 15
	# ollama pull zephyr
	ollama create $(OLLAMA_MODEL) -f Modelfile
	litellm --model ollama/$(OLLAMA_MODEL)