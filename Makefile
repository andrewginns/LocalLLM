SHELL = /bin/bash
OLLAMA_MODEL = zephyr
TARGETARCH = $(shell dpkg --print-architecture)
EXPERIMENTAL = false

setup-containers:
	# Cleanup before build
	rm -rf ollama
	docker stop ollama || true # Continue even if this command fails
	docker rm ollama || true # Continue even if this command fails
	
	# Build ollama
	$(if $(filter $(EXPERIMENTAL),true), \
		git clone https://github.com/jmorganca/ollama.git, \
		git clone https://github.com/jmorganca/ollama.git --branch v0.1.5 --single-branch \
	)
	cd ollama && docker build -t ollama/ollama . --build-arg="TARGETARCH=amd64"
	docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
	docker exec ollama /bin/bash -c "ollama pull $(OLLAMA_MODEL)"
	
	# Cleanup before build
	rm -rf litellm
	docker stop litellm || true # Continue even if this command fails
	docker rm litellm || true # Continue even if this command fails
	
	# Build litellm proxy
	$(if $(filter $(EXPERIMENTAL),true), \
		git clone https://github.com/BerriAI/litellm.git, \
		git clone https://github.com/BerriAI/litellm.git --branch v0.11.1 --single-branch \
	)
	cd litellm && docker build -t litellm .
	docker run -d -e PORT=8000 -p 8000:8000 --name litellm litellm

	# Setup docker network
	docker network rm LLMnet || true
	docker network create LLMnet
	docker network connect LLMnet ollama
	docker network connect LLMnet litellm
	
	# Test LLM via python API call
	$(MAKE) test


test:
	$(eval IP_ADDRESS := $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' ollama))
	docker cp test_ollama.py litellm:/app/openai-proxy
	docker exec litellm /bin/bash -c "python test_ollama.py --model=$(OLLAMA_MODEL) --host=$(IP_ADDRESS)"