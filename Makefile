.ONESHELL:

SHELL = /bin/bash
CONDA_ACTIVATE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate

install-privateGPT:
	# Remove previous env and re-create
	mamba deactivate	
	mamba remove --name privateGPT --all
	mamba create --name privateGPT python pip -y
	$(CONDA_ACTIVATE) activate privateGPT
	python -m pip install --upgrade pip
	
	# Install privateGPT and dependencies
	rm -rf privateGPT
	git clone https://github.com/go-skynet/privateGPT.git
	cd privateGPT
	python -m pip install -r requirements.txt
	
	# Set the default model to OpenAI so that we can use our local API
	sed -i "s/GPT4All/OpenAI/g" example.env
	
	# Replace the default embeddings model
	sed -i "s%all-MiniLM-L6-v2%BAAI/bge-large-en%g" example.env

ingest-privateGPT:
	$(CONDA_ACTIVATE) activate privateGPT
	cd privateGPT
	cp example.env .env
	python ingest.py

run-privateGPT:
	$(CONDA_ACTIVATE) activate privateGPT
	cd privateGPT
	python privateGPT.py

test-LLM:
	curl --location 'http://172.22.33.216:8080/v1/completions' --header 'Content-Type: application/json' --data '{"model": "gpt-3.5-turbo","prompt": "Write a short compliment for someone called Andrew Ginns","max_tokens": 250,"temperature": 0.7}'