import argparse
from litellm import completion


def main(model: str = 'zephyr', host: str = 'localhost') -> None:
    response = completion(
        model = f"ollama/{model}", 
        messages = [{ "content": "What does the term MLOps mean for data scientists?","role": "user"}], 
        api_base = f"http://{host}:11434"
    )
    print(response)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process input args')
    parser.add_argument('--model', type=str, default='zephyr',
                        help='Ollama model to use')
    parser.add_argument('--host', type=str, default='localhost',
                        help='IP address of the ollama host')

    args = parser.parse_args()
    main(args.model, args.host)