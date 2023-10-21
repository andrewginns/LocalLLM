FROM python:3.10

RUN pip install litellm
EXPOSE 8000
RUN curl https://ollama.ai/install.sh | sh
COPY Makefile Makefile
COPY Modelfile Modelfile
COPY zephyr-7b-alpha.Q8_0.gguf zephyr-7b-alpha.Q8_0.gguf
ENTRYPOINT [ "make", "setup-ollama" ]
# ENTRYPOINT ["litellm", "--model", "ollama/zephyr"]
# CMD ollama pull zephyr

# docker run -it -p 8000:8000 litellm
# docker exec -it container_name /bin/bash
# 'Router' object has no attribute 'model_names'
# LiteLLM.Exception: 'Router' object has no attribute 'model_names'
# INFO:     127.0.0.1:45402 - "POST /chat/completions HTTP/1.1" 500 Internal Server Error
# ERROR:    Exception in ASGI application
# Traceback (most recent call last):
#   File "/usr/local/lib/python3.10/site-packages/litellm/proxy/llm.py", line 138, in litellm_completion
#     if model_router and data["model"] in model_router.get_model_names():
#   File "/usr/local/lib/python3.10/site-packages/litellm/router.py", line 100, in get_model_names
#     return self.model_names
# AttributeError: 'Router' object has no attribute 'model_names'

# The above exception was the direct cause of the following exception:

# Traceback (most recent call last):
#   File "/usr/local/lib/python3.10/site-packages/uvicorn/protocols/http/h11_impl.py", line 408, in run_asgi
#     result = await app(  # type: ignore[func-returns-value]
#   File "/usr/local/lib/python3.10/site-packages/uvicorn/middleware/proxy_headers.py", line 84, in __call__
#     return await self.app(scope, receive, send)
#   File "/usr/local/lib/python3.10/site-packages/fastapi/applications.py", line 1115, in __call__
#     await super().__call__(scope, receive, send)
#   File "/usr/local/lib/python3.10/site-packages/starlette/applications.py", line 122, in __call__
#     await self.middleware_stack(scope, receive, send)
#   File "/usr/local/lib/python3.10/site-packages/starlette/middleware/errors.py", line 184, in __call__
#     raise exc
#   File "/usr/local/lib/python3.10/site-packages/starlette/middleware/errors.py", line 162, in __call__
#     await self.app(scope, receive, _send)
#   File "/usr/local/lib/python3.10/site-packages/starlette/middleware/cors.py", line 83, in __call__
#     await self.app(scope, receive, send)
#   File "/usr/local/lib/python3.10/site-packages/starlette/middleware/exceptions.py", line 79, in __call__
#     raise exc
#   File "/usr/local/lib/python3.10/site-packages/starlette/middleware/exceptions.py", line 68, in __call__
#     await self.app(scope, receive, sender)
#   File "/usr/local/lib/python3.10/site-packages/fastapi/middleware/asyncexitstack.py", line 20, in __call__
#     raise e
#   File "/usr/local/lib/python3.10/site-packages/fastapi/middleware/asyncexitstack.py", line 17, in __call__
#     await self.app(scope, receive, send)
#   File "/usr/local/lib/python3.10/site-packages/starlette/routing.py", line 718, in __call__
#     await route.handle(scope, receive, send)
#   File "/usr/local/lib/python3.10/site-packages/starlette/routing.py", line 276, in handle
#     await self.app(scope, receive, send)
#   File "/usr/local/lib/python3.10/site-packages/starlette/routing.py", line 66, in app
#     response = await func(request)
#   File "/usr/local/lib/python3.10/site-packages/fastapi/routing.py", line 274, in app
#     raw_response = await run_endpoint_function(
#   File "/usr/local/lib/python3.10/site-packages/fastapi/routing.py", line 191, in run_endpoint_function
#     return await dependant.call(**values)
#   File "/usr/local/lib/python3.10/site-packages/litellm/proxy/proxy_server.py", line 515, in chat_completion
#     return litellm_completion(data, type="chat_completion", user_model=user_model,
#   File "/usr/local/lib/python3.10/site-packages/backoff/_sync.py", line 105, in retry
#     ret = target(*args, **kwargs)
#   File "/usr/local/lib/python3.10/site-packages/backoff/_sync.py", line 105, in retry
#     ret = target(*args, **kwargs)
#   File "/usr/local/lib/python3.10/site-packages/litellm/proxy/llm.py", line 148, in litellm_completion
#     handle_llm_exception(e=e, user_api_base=user_api_base)
#   File "/usr/local/lib/python3.10/site-packages/litellm/proxy/llm.py", line 92, in handle_llm_exception
#     raise UnknownLLMError from e
# litellm.proxy.llm.UnknownLLMError