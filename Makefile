.ONESHELL:

SHELL = /bin/bash
CONDA_ACTIVATE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate
MODEL = dolphin-2.0-mistral-7b.Q8_0.gguf
CORES := $(shell grep -P '^core id\t' /proc/cpuinfo | sort -u | wc -l)


define deactivate_conda
	for i in $(seq ${CONDA_SHLVL}); do
		conda deactivate
	done
endef

get-model:
	wget https://huggingface.co/TheBloke/dolphin-2.0-mistral-7B-GGUF/resolve/main/dolphin-2.0-mistral-7b.Q8_0.gguf

install-llm-endpoint:
	# Requires OPENBLAS to be installed
	sudo apt-get install libopenblas-dev
	
	# clone the repo and navigate to it
	git clone --branch feature/minimal-llm-container https://github.com/andrewginns/LocalAI.git
	cd LocalAI

	# build the binary
	make BUILD_TYPE=openblas build

	# # Download gpt4all-j to models/
	# wget https://gpt4all.io/models/ggml-gpt4all-j.bin -O models/ggml-gpt4all-j

	# # Use a template from the examples
	# cp -rf prompt-templates/ggml-gpt4all-j.tmpl models/
	cp /home/ubuntu/LocalLLM/$(MODEL) models/

	# Run LocalAI
	./local-ai --models-path ./models/ --debug --threads 16

	# Now API is accessible at localhost:8080
	curl http://localhost:8080/v1/models

	curl http://localhost:8080/v1/chat/completions -H "Content-Type: application/json" -d '{
		"model": "$(MODEL)",
		"messages": [{"role": "user", "content": "How are you?"}],
		"temperature": 0.9 
	}'

install-privateGPT:
	# Remove previous env and re-create
	$(deactivate_conda)	
	conda remove --name privateGPT --all -y
	conda create --name privateGPT python=3.10 pip -y
	$(CONDA_ACTIVATE) activate privateGPT
	python -m pip install --upgrade pip
	
	# Install privateGPT and dependencies
	rm -rf privateGPT
	git clone https://github.com/go-skynet/privateGPT.git
	cd privateGPT
	python -m pip install -r requirements.txt --no-cache-dir
	
	# Set the default model to OpenAI so that we can use our local API
	sed -i "s/GPT4All/OpenAI/g" example.env
	
	# Set the default model name to our model for the OpenAI API
	sed -i "s/mythical-destroyer-v2-l2-13b.Q8_0/$(MODEL)/g" example.env
	
	# Replace the default embeddings model
	sed -i "s%all-MiniLM-L6-v2%BAAI/bge-large-en%g" example.env

ingest-privateGPT:
	$(deactivate_conda)
	$(CONDA_ACTIVATE) activate privateGPT
	cd privateGPT
	cp example.env .env
	python ingest.py
	
run-llm-endpoint:
	cd LocalAI
	# Run LocalAI
	./local-ai --models-path ./models/ --debug --threads $(CORES)

run-privateGPT:
	$(deactivate_conda)
	$(CONDA_ACTIVATE) activate privateGPT
	cd privateGPT
	cp example.env .env
	python privateGPT.py

test-LLM:
	curl --location 'http://localhost:8080/v1/completions' --header 'Content-Type: application/json' --data '{"model": "$(MODEL)","prompt": "Write a short compliment for someone called Andrew Ginns","max_tokens": 250,"temperature": 0.7}'
